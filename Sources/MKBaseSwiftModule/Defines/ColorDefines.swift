//
//  MKColor.swift
//  MKPS101SwiftProject_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//
import UIKit

// 带有RGBA和RGB的颜色设置
func rgbaColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func rgbColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return rgbaColor(r, g, b, 1.0)
}

// 根据RGB16进制值获取颜色（16进制->10进制）
func RGB(_ rgbValue: UInt32) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
    let blue = CGFloat(rgbValue & 0xFF) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

// 获取随机色
var randomColor: UIColor {
    return UIColor(red: CGFloat(arc4random_uniform(256))/255.0,
                   green: CGFloat(arc4random_uniform(256))/255.0,
                   blue: CGFloat(arc4random_uniform(256))/255.0,
                   alpha: 1.0)
}

// 常用颜色
var black: UIColor {
    return RGB(0x333333)
}

var deepBlack: UIColor {
    return RGB(0x000000)
}

var blue: UIColor {
    return RGB(0x4790ef)
}

var skyBlue: UIColor {
    return RGB(0xf3f8fe)
}

var lightBlue: UIColor {
    return RGB(0x4490ee)
}

var gray: UIColor {
    return RGB(0x999999)
}

var lightGray: UIColor {
    return RGB(0xdddddd)
}

var lineColor: UIColor {
    return RGB(0xe5e5e5)
}

var red: UIColor {
    return RGB(0xff3400)
}

var lightRed: UIColor {
    return RGB(0xff4200)
}

var green: UIColor {
    return RGB(0x32b16c)
}

var buttonColorSure: UIColor {
    return rgbColor(75, 146, 236)
}

var fontColorBlack: UIColor {
    return rgbColor(51, 51, 51)
}

var white: UIColor {
    return rgbColor(255, 255, 255)
}

func fontColorWhite(_ alpha: CGFloat) -> UIColor {
    return rgbaColor(255, 255, 255, alpha)
}

var clearColor: UIColor {
    return fontColorWhite(0)
}

var cuttingLineColor: UIColor {
    return rgbColor(0xe8, 0xe8, 0xe8)
}

var navbarColor: UIColor {
    return RGB(0x2F84D0)
}

var defaultTextColor: UIColor {
    return RGB(0x353535)
}
