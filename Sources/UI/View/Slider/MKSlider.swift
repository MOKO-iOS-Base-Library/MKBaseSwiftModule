//
//  MKSlider.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/11.
//

import UIKit

class MKSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setThumbImage(UIImage(named: "mk_sliderThumbIcon"), for: .normal)
        self.setThumbImage(UIImage(named: "mk_sliderThumbIcon"), for: .highlighted)
        self.setMinimumTrackImage(UIImage(named: "mk_sliderMinimumTrackIcon"), for: .normal)
        self.setMaximumTrackImage(UIImage(named: "mk_sliderMaximumTrackImage"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
