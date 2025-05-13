# MKBaseSwiftModule

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS 14+](https://img.shields.io/badge/iOS-14%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

MOKO 项目的 Swift 基础组件库，提供高效、稳定的 iOS 开发基础设施。

## 🚀 功能特性

- **核心组件**：网络层、本地存储、设备工具类
- **UI 工具箱**：预置表单控件、弹窗管理器、主题引擎
- **扩展集合**：200+ 常用 Swift 扩展方法
- **零依赖**：除标注模块外不依赖第三方库

## 📦 安装

### Swift Package Manager

1. 在 Xcode 中：
   - 选择 `File > Add Packages...`
   - 输入仓库 URL：  
     `https://github.com/MOKO-iOS-Base-Library/MKBaseSwiftModule.git`
   - 选择版本规则（推荐 `Up to Next Major`）

2. 或直接在 `Package.swift` 添加：
```swift
dependencies: [
    .package(
        url: "https://github.com/MOKO-iOS-Base-Library/MKBaseSwiftModule.git", 
        from: "2.3.0"
    )
]
