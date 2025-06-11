//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/11.
//

import UIKit

public struct OptionalConfiguration {
    var arrowSize: CGFloat
    var marginXSpacing: CGFloat
    var marginYSpacing: CGFloat
    var intervalSpacing: CGFloat
    var menuCornerRadius: CGFloat
    var maskToBackground: Bool
    var shadowOfMenu: Bool
    var hasSeperatorLine: Bool
    var seperatorLineHasInsets: Bool
    var textColor: UIColor
    var menuBackgroundColor: UIColor
    
    public init(
        arrowSize: CGFloat = 10,
        marginXSpacing: CGFloat = 10,
        marginYSpacing: CGFloat = 5,
        intervalSpacing: CGFloat = 10,
        menuCornerRadius: CGFloat = 4,
        maskToBackground: Bool = true,
        shadowOfMenu: Bool = true,
        hasSeperatorLine: Bool = true,
        seperatorLineHasInsets: Bool = false,
        textColor: UIColor = Color.rgb(0, 0, 0),
        menuBackgroundColor: UIColor = Color.rgb(1, 1, 1)
    ) {
        self.arrowSize = arrowSize
        self.marginXSpacing = marginXSpacing
        self.marginYSpacing = marginYSpacing
        self.intervalSpacing = intervalSpacing
        self.menuCornerRadius = menuCornerRadius
        self.maskToBackground = maskToBackground
        self.shadowOfMenu = shadowOfMenu
        self.hasSeperatorLine = hasSeperatorLine
        self.seperatorLineHasInsets = seperatorLineHasInsets
        self.textColor = textColor
        self.menuBackgroundColor = menuBackgroundColor
    }
}

// MARK: - KxMenuItem

public class KxMenuItem {
    var image: UIImage?
    var title: String
    weak var target: AnyObject?
    var action: Selector?
    var foreColor: UIColor?
    var alignment: NSTextAlignment
    
    public init(title: String, image: UIImage?, target: AnyObject?, action: Selector?) {
        self.title = title
        self.image = image
        self.target = target
        self.action = action
        self.alignment = .left
        self.foreColor = nil
    }
    
    public class func menuItem(title: String, image: UIImage?, target: AnyObject?, action: Selector?) -> KxMenuItem {
        return KxMenuItem(title: title, image: image, target: target, action: action)
    }
    
    var enabled: Bool {
        target != nil && action != nil
    }
    
    func performAction() {
        guard let target = target, let action = action else { return }
        
        if target.responds(to: action) {
            target.performSelector(onMainThread: action, with: self, waitUntilDone: true)
        }
    }
}

// MARK: - KxMenuOverlay

private class KxMenuOverlay: UIView {
    var maskSetting: Bool
    
    init(frame: CGRect, maskSetting: Bool) {
        self.maskSetting = maskSetting
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = maskSetting ? UIColor.black.withAlphaComponent(0.17) : .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func singleTap(_ recognizer: UITapGestureRecognizer) {
        for subview in subviews {
            if let menuView = subview as? KxMenuView {
                menuView.dismissMenu(animated: true)
            }
        }
    }
}

// MARK: - KxMenuView

private class KxMenuView: UIView {
    enum ArrowDirection {
        case none
        case up
        case down
        case left
        case right
    }
    
    var options: OptionalConfiguration = OptionalConfiguration()
    private var arrowDirection: ArrowDirection = .none
    private var arrowPosition: CGFloat = 0
    private var contentView: UIView!
    private var menuItems: [KxMenuItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = true
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showMenu(in view: UIView, from rect: CGRect, menuItems: [KxMenuItem], with options: OptionalConfiguration) {
        self.options = options
        self.menuItems = menuItems
        
        contentView = mkContentView()
        addSubview(contentView)
        
        setupFrame(in: view, from: rect)
        
        let overlay = KxMenuOverlay(frame: view.bounds, maskSetting: options.maskToBackground)
        overlay.addSubview(self)
        view.addSubview(overlay)
        
        contentView.isHidden = true
        let toFrame = self.frame
        self.frame = CGRect(origin: arrowPoint, size: CGSize(width: 1, height: 1))
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
            self.frame = toFrame
        } completion: { _ in
            self.contentView.isHidden = false
        }
    }
    
    func dismissMenu(animated: Bool) {
        if animated {
            let toFrame = CGRect(origin: arrowPoint, size: CGSize(width: 1, height: 1))
            contentView.isHidden = true
            
            UIView.animate(withDuration: 0.1) {
                self.alpha = 0
                self.frame = toFrame
            } completion: { _ in
                if let overlay = self.superview as? KxMenuOverlay {
                    overlay.removeFromSuperview()
                }
                self.removeFromSuperview()
            }
        } else {
            if let overlay = self.superview as? KxMenuOverlay {
                overlay.removeFromSuperview()
            }
            self.removeFromSuperview()
        }
    }
    
    private func setupFrame(in view: UIView, from rect: CGRect) {
        let contentSize = contentView.frame.size
        
        let outerWidth = view.bounds.width
        let outerHeight = view.bounds.height
        
        let rectX0 = rect.origin.x
        let rectX1 = rect.origin.x + rect.width
        let rectXM = rect.origin.x + rect.width * 0.5
        let rectY0 = rect.origin.y
        let rectY1 = rect.origin.y + rect.height
        let rectYM = rect.origin.y + rect.height * 0.5
        
        let widthPlusArrow = contentSize.width + options.arrowSize
        let heightPlusArrow = contentSize.height + options.arrowSize
        let widthHalf = contentSize.width * 0.5
        let heightHalf = contentSize.height * 0.5
        
        let kMargin: CGFloat = 5.0
        
        if options.shadowOfMenu {
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowRadius = 2
            layer.shadowColor = UIColor.black.cgColor
        }
        
        if heightPlusArrow < (outerHeight - rectY1) {
            arrowDirection = .up
            var point = CGPoint(x: rectXM - widthHalf, y: rectY1)
            
            if point.x < kMargin { point.x = kMargin }
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            contentView.frame = CGRect(x: 0, y: options.arrowSize, width: contentSize.width, height: contentSize.height)
            
            self.frame = CGRect(x: point.x, y: point.y, width: contentSize.width, height: contentSize.height + options.arrowSize)
        } else if heightPlusArrow < rectY0 {
            arrowDirection = .down
            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow)
            
            if point.x < kMargin { point.x = kMargin }
            if (point.x + contentSize.width + kMargin) > outerWidth {
                point.x = outerWidth - contentSize.width - kMargin
            }
            
            arrowPosition = rectXM - point.x
            contentView.frame = CGRect(origin: .zero, size: contentSize)
            
            self.frame = CGRect(x: point.x, y: point.y, width: contentSize.width, height: contentSize.height + options.arrowSize)
        } else if widthPlusArrow < (outerWidth - rectX1) {
            arrowDirection = .left
            var point = CGPoint(x: rectX1, y: rectYM - heightHalf)
            
            if point.y < kMargin { point.y = kMargin }
            if (point.y + contentSize.height + kMargin) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            contentView.frame = CGRect(x: options.arrowSize, y: 0, width: contentSize.width, height: contentSize.height)
            
            self.frame = CGRect(x: point.x, y: point.y, width: contentSize.width + options.arrowSize, height: contentSize.height)
        } else if widthPlusArrow < rectX0 {
            arrowDirection = .right
            var point = CGPoint(x: rectX0 - widthPlusArrow, y: rectYM - heightHalf)
            
            if point.y < kMargin { point.y = kMargin }
            if (point.y + contentSize.height + 5) > outerHeight {
                point.y = outerHeight - contentSize.height - kMargin
            }
            
            arrowPosition = rectYM - point.y
            contentView.frame = CGRect(origin: .zero, size: contentSize)
            
            self.frame = CGRect(x: point.x, y: point.y, width: contentSize.width + options.arrowSize, height: contentSize.height)
        } else {
            arrowDirection = .none
            self.frame = CGRect(
                x: (outerWidth - contentSize.width) * 0.5,
                y: (outerHeight - contentSize.height) * 0.5,
                width: contentSize.width,
                height: contentSize.height
            )
        }
    }
    
    private var arrowPoint: CGPoint {
        var point = CGPoint.zero
        
        switch arrowDirection {
        case .up:
            point = CGPoint(x: frame.minX + arrowPosition, y: frame.minY)
        case .down:
            point = CGPoint(x: frame.minX + arrowPosition, y: frame.maxY)
        case .left:
            point = CGPoint(x: frame.minX, y: frame.minY + arrowPosition)
        case .right:
            point = CGPoint(x: frame.maxX, y: frame.minY + arrowPosition)
        case .none:
            point = center
        }
        
        return point
    }
    
    private func mkContentView() -> UIView {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        guard !menuItems.isEmpty else { return UIView() }
        
        let kMinMenuItemHeight: CGFloat = 32.0
        let kMinMenuItemWidth: CGFloat = 32.0
        let kMarginX = options.marginXSpacing
        let kMarginY = options.marginYSpacing
        
        var titleFont = KxMenu.titleFont ?? UIFont.boldSystemFont(ofSize: 16)
        
        var maxImageWidth: CGFloat = 0
        var maxItemHeight: CGFloat = 0
        var maxItemWidth: CGFloat = 0
        
        // Calculate max image width
        for menuItem in menuItems {
            let imageSize = menuItem.image?.size ?? .zero
            if imageSize.width > maxImageWidth {
                maxImageWidth = imageSize.width
            }
        }
        
        if maxImageWidth > 0 {
            maxImageWidth += kMarginX
        }
        
        // Calculate max item size
        for menuItem in menuItems {
            let titleSize = menuItem.title.size(withAttributes: [.font: titleFont])
            let imageSize = menuItem.image?.size ?? .zero
            
            let itemHeight = max(titleSize.height, imageSize.height) + kMarginY * 2
            let itemWidth = ((!menuItem.enabled && menuItem.image == nil) ? titleSize.width : maxImageWidth + titleSize.width) + kMarginX * 2 + options.intervalSpacing
            
            if itemHeight > maxItemHeight { maxItemHeight = itemHeight }
            if itemWidth > maxItemWidth { maxItemWidth = itemWidth }
        }
        
        maxItemWidth = max(maxItemWidth, kMinMenuItemWidth)
        maxItemHeight = max(maxItemHeight, kMinMenuItemHeight)
        
        let titleX = maxImageWidth + options.intervalSpacing
        let titleWidth = maxItemWidth - titleX - kMarginX * 2
        
        let insets: CGFloat = options.seperatorLineHasInsets ? 4 : 0
        let gradientLine = KxMenuView.gradientLine(size: CGSize(width: maxItemWidth - kMarginX * insets, height: 0.4))
        
        let contentView = UIView(frame: .zero)
        contentView.autoresizingMask = []
        contentView.backgroundColor = .clear
        contentView.isOpaque = false
        
        var itemY: CGFloat = kMarginY * 2
        var itemNum = 0
        
        for menuItem in menuItems {
            let itemFrame = CGRect(x: 0, y: itemY - kMarginY * 2 + options.menuCornerRadius, width: maxItemWidth, height: maxItemHeight)
            
            let itemView = UIView(frame: itemFrame)
            itemView.autoresizingMask = []
            itemView.isOpaque = false
            contentView.addSubview(itemView)
            
            if menuItem.enabled {
                let button = UIButton(type: .custom)
                button.tag = itemNum
                button.frame = itemView.bounds
                button.isEnabled = menuItem.enabled
                button.backgroundColor = .clear
                button.isOpaque = false
                button.autoresizingMask = []
                button.addTarget(self, action: #selector(performAction(_:)), for: .touchUpInside)
                itemView.addSubview(button)
            }
            
            if !menuItem.title.isEmpty {
                let titleFrame: CGRect
                
                if !menuItem.enabled && menuItem.image == nil {
                    titleFrame = CGRect(x: kMarginX * 2, y: kMarginY, width: maxItemWidth - kMarginX * 4, height: maxItemHeight - kMarginY * 2)
                } else {
                    titleFrame = CGRect(x: titleX, y: kMarginY, width: titleWidth, height: maxItemHeight - kMarginY * 2)
                }
                
                let titleLabel = UILabel(frame: titleFrame)
                titleLabel.text = menuItem.title
                titleLabel.font = titleFont
                titleLabel.textAlignment = menuItem.alignment
                titleLabel.textColor = options.textColor
                titleLabel.backgroundColor = .clear
                titleLabel.autoresizingMask = []
                itemView.addSubview(titleLabel)
            }
            
            if let image = menuItem.image {
                let imageFrame = CGRect(x: kMarginX * 2, y: kMarginY, width: maxImageWidth, height: maxItemHeight - kMarginY * 2)
                let imageView = UIImageView(frame: imageFrame)
                imageView.image = image
                imageView.clipsToBounds = true
                imageView.contentMode = .center
                imageView.autoresizingMask = []
                itemView.addSubview(imageView)
            }
            
            if itemNum < menuItems.count - 1 && options.hasSeperatorLine {
                let gradientView = UIImageView(image: gradientLine)
                
                if options.seperatorLineHasInsets {
                    gradientView.frame = CGRect(x: kMarginX * 2, y: maxItemHeight + 1, width: gradientLine?.size.width ?? 0, height: gradientLine?.size.height ?? 0)
                } else {
                    gradientView.frame = CGRect(x: 0, y: maxItemHeight + 1, width: gradientLine?.size.width ?? 0, height: gradientLine?.size.height ?? 0)
                }
                
                gradientView.contentMode = .left
                itemView.addSubview(gradientView)
                itemY += 2
            }
            
            itemY += maxItemHeight
            itemNum += 1
        }
        
        itemY += options.menuCornerRadius
        
        contentView.frame = CGRect(x: 0, y: 0, width: maxItemWidth, height: itemY + kMarginY * 2 + 5.5 + options.menuCornerRadius)
        
        return contentView
    }
    
    @objc private func performAction(_ sender: UIButton) {
        dismissMenu(animated: true)
        
        let menuItem = menuItems[sender.tag]
        menuItem.performAction()
    }
    
    private static func gradientLine(size: CGSize) -> UIImage? {
        let locations: [CGFloat] = [0, 0.2, 0.5, 0.8, 1]
        let R: CGFloat = 0.890
        let G: CGFloat = 0.890
        let B: CGFloat = 0.890
        
        let components: [CGFloat] = [
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1,
            R, G, B, 1
        ]
        
        return gradientImage(size: size, locations: locations, components: components, count: 5)
    }
    
    private static func gradientImage(size: CGSize, locations: [CGFloat], components: [CGFloat], count: Int) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorSpace: colorSpace,
                                       colorComponents: components,
                                       locations: locations,
                                       count: count) else { return nil }
        
        context.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: size.width, y: 0),
                                  options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func draw(_ rect: CGRect) {
        drawBackground(rect, in: UIGraphicsGetCurrentContext()!)
    }
    
    private func drawBackground(_ frame: CGRect, in context: CGContext) {
        var R0: CGFloat = 0
        var G0: CGFloat = 0
        var B0: CGFloat = 0
        var alpha: CGFloat = 0
        
        options.menuBackgroundColor.getRed(&R0, green: &G0, blue: &B0, alpha: &alpha)
        
        let R1 = R0
        let G1 = G0
        let B1 = B0
        
        if let tintColor = KxMenu.tintColor {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            tintColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            R0 = r
            G0 = g
            B0 = b
        }
        
        let X0 = frame.origin.x
        let X1 = frame.origin.x + frame.width
        let Y0 = frame.origin.y
        let Y1 = frame.origin.y + frame.height
        
        // Render arrow
        let arrowPath = UIBezierPath()
        let kEmbedFix: CGFloat = 3.0
        
        switch arrowDirection {
        case .up:
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - options.arrowSize
            let arrowX1 = arrowXM + options.arrowSize
            let arrowY0 = Y0
            let arrowY1 = Y0 + options.arrowSize + kEmbedFix
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY0))
            
            UIColor(red: R0, green: G0, blue: B0, alpha: 1).setFill()
            
        case .down:
            let arrowXM = arrowPosition
            let arrowX0 = arrowXM - options.arrowSize
            let arrowX1 = arrowXM + options.arrowSize
            let arrowY0 = Y1 - options.arrowSize - kEmbedFix
            let arrowY1 = Y1
            
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY1))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).setFill()
            
        case .left:
            let arrowYM = arrowPosition
            let arrowX0 = X0
            let arrowX1 = X0 + options.arrowSize + kEmbedFix
            let arrowY0 = arrowYM - options.arrowSize
            let arrowY1 = arrowYM + options.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            UIColor(red: R0, green: G0, blue: B0, alpha: 1).setFill()
            
        case .right:
            let arrowYM = arrowPosition
            let arrowX0 = X1
            let arrowX1 = X1 - options.arrowSize - kEmbedFix
            let arrowY0 = arrowYM - options.arrowSize
            let arrowY1 = arrowYM + options.arrowSize
            
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).setFill()
            
        case .none:
            break
        }
        
        arrowPath.fill()
        
        // Render body
        let bodyFrame = CGRect(x: X0, y: Y0, width: X1 - X0, height: Y1 - Y0)
        let borderPath = UIBezierPath(roundedRect: bodyFrame, cornerRadius: options.menuCornerRadius)
        
        let locations: [CGFloat] = [0, 1]
        let components: [CGFloat] = [
            R0, G0, B0, 1,
            R1, G1, B1, 1
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorSpace: colorSpace,
                                       colorComponents: components,
                                       locations: locations,
                                       count: 2) else { return }
        
        borderPath.addClip()
        
        let start: CGPoint
        let end: CGPoint
        
        if arrowDirection == .left || arrowDirection == .right {
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X1, y: Y0)
        } else {
            start = CGPoint(x: X0, y: Y0)
            end = CGPoint(x: X0, y: Y1)
        }
        
        context.drawLinearGradient(gradient, start: start, end: end, options: [])
    }
}

// MARK: - KxMenu

@MainActor public class KxMenu {
    public private(set) static var tintColor: UIColor?
    public private(set) static var titleFont: UIFont?
    
    private var menuView: KxMenuView?
    private var observing = false
    
    private static let shared = KxMenu()
    
    private init() {}
    
    deinit {
        if observing {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    public static func showMenu(in view: UIView, from rect: CGRect, menuItems: [KxMenuItem], with options: OptionalConfiguration = OptionalConfiguration()) {
        shared.showMenu(in: view, from: rect, menuItems: menuItems, with: options)
    }
    
    public static func dismissMenu() {
        shared.dismissMenu()
    }
    
    public static func setTintColor(_ color: UIColor) {
        tintColor = color
    }
    
    public static func setTitleFont(_ font: UIFont) {
        titleFont = font
    }
    
    private func showMenu(in view: UIView, from rect: CGRect, menuItems: [KxMenuItem], with options: OptionalConfiguration) {
        guard !menuItems.isEmpty else { return }
        
        if let menuView = menuView {
            menuView.dismissMenu(animated: false)
            self.menuView = nil
        }
        
        if !observing {
            observing = true
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(orientationWillChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        menuView = KxMenuView()
        menuView?.showMenu(in: view, from: rect, menuItems: menuItems, with: options)
    }
    
    private func dismissMenu() {
        if let menuView = menuView {
            menuView.dismissMenu(animated: false)
            self.menuView = nil
        }
        
        if observing {
            observing = false
            NotificationCenter.default.removeObserver(self)
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    @objc private func orientationWillChange() {
        dismissMenu()
    }
}
