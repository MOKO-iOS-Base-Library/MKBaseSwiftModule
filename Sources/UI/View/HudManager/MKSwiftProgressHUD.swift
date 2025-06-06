//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/5.
//

import UIKit

public let MKProgressMaxOffset: CGFloat = 1_000_000.0

public enum MKSwiftProgressHUDMode {
    case indeterminate
    case determinate
    case determinateHorizontalBar
    case annularDeterminate
    case customView
    case text
}

public enum MKSwiftProgressHUDAnimation {
    case fade
    case zoom
    case zoomOut
    case zoomIn
}

public enum MKSwiftProgressHUDBackgroundStyle {
    case solidColor
    case blur
}

public typealias MKSwiftProgressHUDCompletionBlock = () -> Void

public protocol MKSwiftProgressHUDDelegate: AnyObject {
    func hudWasHidden(_ hud: MKSwiftProgressHUD)
}

public protocol MKProgressReporting: AnyObject {
    var progress: Float { get set }
}

@MainActor
public final class MKSwiftProgressHUD: UIView {
    
    // MARK: - Properties
    
    public weak var delegate: MKSwiftProgressHUDDelegate?
    public var completionBlock: MKSwiftProgressHUDCompletionBlock?
    
    public var graceTime: TimeInterval = 0
    public var minShowTime: TimeInterval = 0
    public var removeFromSuperViewOnHide = false
    
    public var mode: MKSwiftProgressHUDMode = .indeterminate {
        didSet { updateIndicators() }
    }
    
    public var contentColor: UIColor? {
        didSet { updateViews(for: contentColor) }
    }
    
    public var animationType: MKSwiftProgressHUDAnimation = .fade
    public var offset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }
    
    public var margin: CGFloat = 20.0 {
        didSet { setNeedsUpdateConstraints() }
    }
    
    public var minSize: CGSize = .zero {
        didSet { setNeedsUpdateConstraints() }
    }
    
    public var isSquare = false {
        didSet { setNeedsUpdateConstraints() }
    }
    
    public var defaultMotionEffectsEnabled = false {
        didSet { updateBezelMotionEffects() }
    }
    
    public var progress: Float = 0 {
        didSet {
            guard let indicator = indicator else { return }
            if let progressView = indicator as? MKRoundProgressView {
                progressView.progress = progress
            } else if let progressView = indicator as? MKBarProgressView {
                progressView.progress = progress
            }
        }
    }
    
    public var progressObject: Progress? {
        didSet { setNSProgressDisplayLink(enabled: true) }
    }
    
    public let bezelView: MKBackgroundView
    public let backgroundView: MKBackgroundView
    public var customView: UIView? {
        didSet {
            if mode == .customView {
                updateIndicators()
            }
        }
    }
    
    public let label: UILabel
    public let detailsLabel: UILabel
    public let button: MKHUDRoundedButton
    
    private var useAnimation = false
    private var hasFinished = false
    private var indicator: UIView?
    private var showStarted: Date?
    private var paddingConstraints: [NSLayoutConstraint] = []
    private var bezelConstraints: [NSLayoutConstraint] = []
    private let topSpacer = UIView()
    private let bottomSpacer = UIView()
    private var bezelMotionEffects: UIMotionEffectGroup?
    private var graceTimer: Timer?
    private var minShowTimer: Timer?
    private var hideDelayTimer: Timer?
    private var progressObjectDisplayLink: CADisplayLink?
    
    // MARK: - Lifecycle
    
    public init(view: UIView) {
        bezelView = MKBackgroundView()
        backgroundView = MKBackgroundView()
        label = UILabel()
        detailsLabel = UILabel()
        button = MKHUDRoundedButton(type: .custom)
        
        super.init(frame: view.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func commonInit() {
        setupDefaults()
        setupViews()
        updateIndicators()
        registerForNotifications()
    }
    
    // MARK: - Public Methods
    
    public static func show(addedTo view: UIView, animated: Bool) -> MKSwiftProgressHUD {
        let hud = MKSwiftProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated: animated)
        return hud
    }
    
    public static func hide(for view: UIView, animated: Bool) -> Bool {
        if let hud = HUD(for: view) {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: animated)
            return true
        }
        return false
    }
    
    public static func HUD(for view: UIView) -> MKSwiftProgressHUD? {
        view.subviews.reversed().first {
            if let hud = $0 as? MKSwiftProgressHUD, !hud.hasFinished {
                return true
            }
            return false
        } as? MKSwiftProgressHUD
    }
    
    public func show(animated: Bool) {
        assert(Thread.isMainThread, "Must be called on main thread")
        minShowTimer?.invalidate()
        useAnimation = animated
        hasFinished = false
        
        if graceTime > 0 {
            graceTimer = Timer.scheduledTimer(
                timeInterval: graceTime,
                target: self,
                selector: #selector(handleGraceTimer),
                userInfo: nil,
                repeats: false
            )
        } else {
            show(usingAnimation: useAnimation)
        }
    }
    
    public func hide(animated: Bool) {
        assert(Thread.isMainThread, "Must be called on main thread")
        graceTimer?.invalidate()
        useAnimation = animated
        hasFinished = true
        
        if minShowTime > 0, let showStarted = showStarted {
            let interval = Date().timeIntervalSince(showStarted)
            if interval < minShowTime {
                minShowTimer = Timer.scheduledTimer(
                    timeInterval: minShowTime - interval,
                    target: self,
                    selector: #selector(handleMinShowTimer),
                    userInfo: nil,
                    repeats: false
                )
                return
            }
        }
        hide(usingAnimation: useAnimation)
    }
    
    public func hide(animated: Bool, afterDelay delay: TimeInterval) {
        hideDelayTimer?.invalidate()
        hideDelayTimer = Timer.scheduledTimer(
            timeInterval: delay,
            target: self,
            selector: #selector(handleHideTimer),
            userInfo: animated,
            repeats: false
        )
    }
    
    // MARK: - Private Methods
    
    private func setupDefaults() {
        if #available(iOS 13.0, *) {
            contentColor = UIColor.label.withAlphaComponent(0.7)
        } else {
            contentColor = UIColor(white: 0, alpha: 0.7)
        }
        
        isOpaque = false
        backgroundColor = .clear
        alpha = 0.0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.allowsGroupOpacity = false
    }
    
    private func setupViews() {
        backgroundView.style = .solidColor
        backgroundView.backgroundColor = .clear
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        bezelView.translatesAutoresizingMaskIntoConstraints = false
        bezelView.layer.cornerRadius = 5.0
        bezelView.alpha = 0
        addSubview(bezelView)
        
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .center
        label.textColor = contentColor
        label.font = .boldSystemFont(ofSize: 16)
        label.isOpaque = false
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        bezelView.addSubview(label)
        
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = .center
        detailsLabel.textColor = contentColor
        detailsLabel.numberOfLines = 0
        detailsLabel.font = .boldSystemFont(ofSize: 12)
        detailsLabel.isOpaque = false
        detailsLabel.backgroundColor = .clear
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        bezelView.addSubview(detailsLabel)
        
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.setTitleColor(contentColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        bezelView.addSubview(button)
        
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacer.isHidden = true
        bezelView.addSubview(topSpacer)
        
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.isHidden = true
        bezelView.addSubview(bottomSpacer)
    }
    
    private func updateIndicators() {
        switch mode {
        case .indeterminate:
            let activityIndicator: UIActivityIndicatorView
            if #available(iOS 13.0, *) {
                activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.color = .white
            } else {
                activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            }
            activityIndicator.startAnimating()
            setIndicator(activityIndicator)
            
        case .determinateHorizontalBar:
            setIndicator(MKBarProgressView())
            
        case .determinate:
            setIndicator(MKRoundProgressView())
            
        case .annularDeterminate:
            let progressView = MKRoundProgressView()
            progressView.isAnnular = true
            setIndicator(progressView)
            
        case .customView:
            setIndicator(customView)
            
        case .text:
            setIndicator(nil)
        }
    }
    
    private func setIndicator(_ newIndicator: UIView?) {
        indicator?.removeFromSuperview()
        indicator = newIndicator
        
        if let newIndicator = newIndicator {
            newIndicator.translatesAutoresizingMaskIntoConstraints = false
            bezelView.addSubview(newIndicator)
            updateViews(for: contentColor)
        }
    }
    
    private func updateViews(for color: UIColor?) {
        guard let color = color else { return }
        
        label.textColor = color
        detailsLabel.textColor = color
        button.setTitleColor(color, for: .normal)
        
        if let activityIndicator = indicator as? UIActivityIndicatorView {
            activityIndicator.color = color
        } else if let roundProgress = indicator as? MKRoundProgressView {
            roundProgress.progressTintColor = color
            roundProgress.backgroundTintColor = color.withAlphaComponent(0.1)
        } else if let barProgress = indicator as? MKBarProgressView {
            barProgress.progressColor = color
            barProgress.lineColor = color
        } else {
            indicator?.tintColor = color
        }
    }
    
    private func updateBezelMotionEffects() {
        if defaultMotionEffectsEnabled, bezelMotionEffects == nil {
            let effectOffset: CGFloat = 10.0
            let effectX = UIInterpolatingMotionEffect(
                keyPath: "center.x",
                type: .tiltAlongHorizontalAxis
            )
            effectX.maximumRelativeValue = effectOffset
            effectX.minimumRelativeValue = -effectOffset
            
            let effectY = UIInterpolatingMotionEffect(
                keyPath: "center.y",
                type: .tiltAlongVerticalAxis
            )
            effectY.maximumRelativeValue = effectOffset
            effectY.minimumRelativeValue = -effectOffset
            
            let group = UIMotionEffectGroup()
            group.motionEffects = [effectX, effectY]
            bezelMotionEffects = group
            bezelView.addMotionEffect(group)
        } else if let effects = bezelMotionEffects {
            bezelMotionEffects = nil
            bezelView.removeMotionEffect(effects)
        }
    }
    
    private func show(usingAnimation animated: Bool) {
        bezelView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        hideDelayTimer?.invalidate()
        
        showStarted = Date()
        alpha = 1.0
        
        setNSProgressDisplayLink(enabled: true)
        updateBezelMotionEffects()
        
        if animated {
            animateIn(true, with: animationType, completion: nil)
        } else {
            bezelView.alpha = 1.0
            backgroundView.alpha = 1.0
        }
    }
    
    private func hide(usingAnimation animated: Bool) {
        hideDelayTimer?.invalidate()
        
        if animated, showStarted != nil {
            showStarted = nil
            animateIn(false, with: animationType) { [weak self] _ in
                self?.done()
            }
        } else {
            showStarted = nil
            bezelView.alpha = 0.0
            backgroundView.alpha = 1.0
            done()
        }
    }
    
    private func animateIn(_ animatingIn: Bool, with type: MKSwiftProgressHUDAnimation, completion: ((Bool) -> Void)?) {
        var animationType = type
        if type == .zoom {
            animationType = animatingIn ? .zoomIn : .zoomOut
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let large = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        if animatingIn && bezelView.alpha == 0 {
            switch animationType {
            case .zoomIn: bezelView.transform = small
            case .zoomOut: bezelView.transform = large
            default: break
            }
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: {
                if animatingIn {
                    self.bezelView.transform = .identity
                } else {
                    switch animationType {
                    case .zoomIn: self.bezelView.transform = large
                    case .zoomOut: self.bezelView.transform = small
                    default: break
                    }
                }
                
                let alpha: CGFloat = animatingIn ? 1.0 : 0.0
                self.bezelView.alpha = alpha
                self.backgroundView.alpha = alpha
            },
            completion: completion
        )
    }
    
    private func done() {
        setNSProgressDisplayLink(enabled: false)
        
        if hasFinished {
            alpha = 0.0
            if removeFromSuperViewOnHide {
                removeFromSuperview()
            }
        }
        
        completionBlock?()
        delegate?.hudWasHidden(self)
    }
    
    private func setNSProgressDisplayLink(enabled: Bool) {
        if enabled, progressObject != nil {
            if progressObjectDisplayLink == nil {
                progressObjectDisplayLink = CADisplayLink(
                    target: self,
                    selector: #selector(updateProgressFromProgressObject)
                )
                progressObjectDisplayLink?.add(to: .main, forMode: .default)
            }
        } else {
            progressObjectDisplayLink?.invalidate()
            progressObjectDisplayLink = nil
        }
    }
    
    @objc private func updateProgressFromProgressObject() {
        progress = Float(progressObject?.fractionCompleted ?? 0)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statusBarOrientationDidChange),
            name: UIApplication.didChangeStatusBarOrientationNotification,
            object: nil
        )
    }
    
    @objc private func statusBarOrientationDidChange() {
        frame = superview?.bounds ?? .zero
    }
    
    @objc private func handleGraceTimer(_ timer: Timer) {
        if !hasFinished {
            show(usingAnimation: useAnimation)
        }
    }
    
    @objc private func handleMinShowTimer(_ timer: Timer) {
        hide(usingAnimation: useAnimation)
    }
    
    @objc private func handleHideTimer(_ timer: Timer) {
        guard let animated = timer.userInfo as? Bool else { return }
        hide(animated: animated)
    }
}

// MARK: - Supporting Types

private protocol ProgressReporting {
    var progress: Float { get set }
}

public final class MKRoundProgressView: UIView, @preconcurrency ProgressReporting {
    public var progress: Float = 0 {
        didSet { setNeedsDisplay() }
    }
    
    public var progressTintColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    public var backgroundTintColor: UIColor = UIColor(white: 1, alpha: 0.1) {
        didSet { setNeedsDisplay() }
    }
    
    public var isAnnular = false {
        didSet { setNeedsDisplay() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 37, height: 37)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isAnnular {
            drawAnnularProgress(in: rect, context: context)
        } else {
            drawCircleProgress(in: rect, context: context)
        }
    }
    
    private func drawAnnularProgress(in rect: CGRect, context: CGContext) {
        let lineWidth: CGFloat = 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (rect.width - lineWidth) / 2
        let startAngle = -CGFloat.pi / 2
        
        // Background
        let backgroundPath = UIBezierPath()
        backgroundPath.lineWidth = lineWidth
        backgroundPath.lineCapStyle = .butt
        backgroundPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: 2 * .pi + startAngle,
            clockwise: true
        )
        backgroundTintColor.set()
        backgroundPath.stroke()
        
        // Progress
        let progressPath = UIBezierPath()
        progressPath.lineCapStyle = .square
        progressPath.lineWidth = lineWidth
        progressPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: CGFloat(progress) * 2 * .pi + startAngle,
            clockwise: true
        )
        progressTintColor.set()
        progressPath.stroke()
    }
    
    private func drawCircleProgress(in rect: CGRect, context: CGContext) {
        let lineWidth: CGFloat = 2.0
        let circleRect = rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Background
        progressTintColor.setStroke()
        backgroundTintColor.setFill()
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: circleRect)
        
        // Progress
        let startAngle = -CGFloat.pi / 2
        let progressPath = UIBezierPath()
        progressPath.lineCapStyle = .butt
        progressPath.lineWidth = lineWidth * 2
        let radius = (rect.width / 2) - (progressPath.lineWidth / 2)
        let endAngle = CGFloat(progress) * 2 * .pi + startAngle
        
        progressPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        context.setBlendMode(.copy)
        progressTintColor.set()
        progressPath.stroke()
    }
}

public final class MKBarProgressView: UIView, @preconcurrency ProgressReporting {
    public var progress: Float = 0 {
        didSet { setNeedsDisplay() }
    }
    
    public var lineColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    public var progressRemainingColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }
    
    public var progressColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 10)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawBackgroundAndBorder(in: rect, context: context)
        drawProgress(in: rect, context: context)
    }
    
    private func drawBackgroundAndBorder(in rect: CGRect, context: CGContext) {
        context.setLineWidth(2)
        context.setStrokeColor(lineColor.cgColor)
        context.setFillColor(progressRemainingColor.cgColor)
        
        let radius = (rect.height / 2) - 2
        context.move(to: CGPoint(x: 2, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 2, y: 2),
            tangent2End: CGPoint(x: radius + 2, y: 2),
            radius: radius
        )
        context.addArc(
            tangent1End: CGPoint(x: rect.width - 2, y: 2),
            tangent2End: CGPoint(x: rect.width - 2, y: rect.height / 2),
            radius: radius
        )
        context.addArc(
            tangent1End: CGPoint(x: rect.width - 2, y: rect.height - 2),
            tangent2End: CGPoint(x: rect.width - radius - 2, y: rect.height - 2),
            radius: radius
        )
        context.addArc(
            tangent1End: CGPoint(x: 2, y: rect.height - 2),
            tangent2End: CGPoint(x: 2, y: rect.height/2),
            radius: radius
        )
        context.drawPath(using: .fillStroke)
    }
    
    private func drawProgress(in rect: CGRect, context: CGContext) {
        context.setFillColor(progressColor.cgColor)
        let radius = (rect.height / 2) - 4
        let amount = CGFloat(progress) * rect.width
        
        if amount >= radius + 4 && amount <= (rect.width - radius - 4) {
            drawMiddleProgress(rect: rect, radius: radius, amount: amount, context: context)
        } else if amount > radius + 4 {
            drawRightArcProgress(rect: rect, radius: radius, amount: amount, context: context)
        } else if amount < radius + 4 && amount > 0 {
            drawLeftArcProgress(rect: rect, radius: radius, amount: amount, context: context)
        }
    }
    
    private func drawMiddleProgress(rect: CGRect, radius: CGFloat, amount: CGFloat, context: CGContext) {
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: 4),
            tangent2End: CGPoint(x: radius + 4, y: 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: amount, y: 4))
        context.addLine(to: CGPoint(x: amount, y: radius + 4))
        
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: rect.height - 4),
            tangent2End: CGPoint(x: radius + 4, y: rect.height - 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: amount, y: rect.height - 4))
        context.addLine(to: CGPoint(x: amount, y: radius + 4))
        
        context.fillPath()
    }
    
    private func drawRightArcProgress(rect: CGRect, radius: CGFloat, amount: CGFloat, context: CGContext) {
        let x = amount - (rect.width - radius - 4)
        
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: 4),
            tangent2End: CGPoint(x: radius + 4, y: 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: rect.width - radius - 4, y: 4))
        
        var angle = -acos(x/radius)
        if angle.isNaN { angle = 0 }
        
        context.addArc(
            center: CGPoint(x: rect.width - radius - 4, y: rect.height/2),
            radius: radius,
            startAngle: .pi,
            endAngle: angle,
            clockwise: false
        )
        context.addLine(to: CGPoint(x: amount, y: rect.height/2))
        
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: rect.height - 4),
            tangent2End: CGPoint(x: radius + 4, y: rect.height - 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: rect.width - radius - 4, y: rect.height - 4))
        
        angle = acos(x/radius)
        if angle.isNaN { angle = 0 }
        
        context.addArc(
            center: CGPoint(x: rect.width - radius - 4, y: rect.height/2),
            radius: radius,
            startAngle: -.pi,
            endAngle: angle,
            clockwise: true
        )
        context.addLine(to: CGPoint(x: amount, y: rect.height/2))
        
        context.fillPath()
    }
    
    private func drawLeftArcProgress(rect: CGRect, radius: CGFloat, amount: CGFloat, context: CGContext) {
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: 4),
            tangent2End: CGPoint(x: radius + 4, y: 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: radius + 4, y: rect.height/2))
        
        context.move(to: CGPoint(x: 4, y: rect.height/2))
        context.addArc(
            tangent1End: CGPoint(x: 4, y: rect.height - 4),
            tangent2End: CGPoint(x: radius + 4, y: rect.height - 4),
            radius: radius
        )
        context.addLine(to: CGPoint(x: radius + 4, y: rect.height/2))
        
        context.fillPath()
    }
}

public final class MKBackgroundView: UIView {
    public var style: MKSwiftProgressHUDBackgroundStyle = .blur {
        didSet { updateForBackgroundStyle() }
    }
    
    public var blurEffectStyle: UIBlurEffect.Style = {
        if #available(iOS 13.0, *) {
            #if targetEnvironment(macCatalyst)
            return .regular
            #else
            return .systemThickMaterial
            #endif
        } else {
            return .light
        }
    }() {
        didSet { updateForBackgroundStyle() }
    }
    
    public var color: UIColor? = {
        if #available(iOS 13.0, *) {
            return nil
        } else {
            return UIColor(white: 0.8, alpha: 0.6)
        }
    }() {
        didSet { updateViews(for: color) }
    }
    
    private var effectView: UIVisualEffectView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    public override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func updateForBackgroundStyle() {
        effectView?.removeFromSuperview()
        effectView = nil
        
        if style == .blur {
            let effect = UIBlurEffect(style: blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            insertSubview(effectView, at: 0)
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundColor = color
            layer.allowsGroupOpacity = false
            self.effectView = effectView
        } else {
            backgroundColor = color
        }
    }
    
    private func updateViews(for color: UIColor?) {
        if style == .blur {
            backgroundColor = self.color
        } else {
            backgroundColor = self.color
        }
    }
}

public final class MKHUDRoundedButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layer.borderWidth = 1
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    public override var intrinsicContentSize: CGSize {
        guard allControlEvents != .init() && title(for: .normal) != nil else {
            return .zero
        }
        var size = super.intrinsicContentSize
        size.width += 20
        return size
    }
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        layer.borderColor = color?.cgColor
    }
    
    public override var isHighlighted: Bool {
        didSet {
            let baseColor = titleColor(for: .selected)
            backgroundColor = isHighlighted ? baseColor?.withAlphaComponent(0.1) : .clear
        }
    }
}
