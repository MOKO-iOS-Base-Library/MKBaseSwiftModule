//
//  MKSwiftSlider.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/11.
//

import UIKit

class MKSwiftSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setThumbImage(loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftSlider", imageName: "mk_swift_sliderThumbIcon.png"), for: .normal)
        self.setThumbImage(loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftSlider", imageName: "mk_swift_sliderThumbIcon.png"), for: .highlighted)
        self.setMinimumTrackImage(loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftSlider", imageName: "mk_swift_sliderMinimumTrackIcon.png"), for: .normal)
        self.setMaximumTrackImage(loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftSlider", imageName: "mk_swift_sliderMaximumTrackImage.png"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
