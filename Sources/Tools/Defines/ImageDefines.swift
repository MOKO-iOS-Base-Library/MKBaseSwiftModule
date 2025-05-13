//
//  ImageDefines.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/29.
//

import Foundation

import UIKit

func imageWithColor(color: UIColor,size: CGSize) -> UIImage? {
    let rect = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    context.setFillColor(color.cgColor)
    context.fill(rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
}
