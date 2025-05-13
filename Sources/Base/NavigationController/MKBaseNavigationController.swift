//
//  MKBaseNavigationController.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/6.
//

import UIKit

class MKBaseNavigationController:UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true;
        }
        super.pushViewController(viewController, animated: animated);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default;
    }
}
