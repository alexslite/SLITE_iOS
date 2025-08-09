//
//  UIViewController + Child.swift
//  Tap2Map
//
//  Created by Efraim Budusan on 7/3/19.
//  Copyright © 2019 Tapptitude. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    @objc func addChild(controller:UIViewController, to containerView:UIView? = nil) {
        let container = containerView ?? self.view!
        controller.view.frame = container.bounds
        container.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.constrainAllMargins(with: container)
        controller.willMove(toParent: self)
        self.addChild(controller)
        controller.didMove(toParent: self)
    }
    
    @objc func removeChild(controller:UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        controller.didMove(toParent: nil)
    }
    
    @objc func _removeFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        didMove(toParent: nil)
    }
}


