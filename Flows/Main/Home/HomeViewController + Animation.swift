//
//  MainTabBarViewController + Animation.swift
//  Wellory
//
//  Created by Efraim Budusan on 05.10.2021.
//  Copyright © 2021 Wellory. All rights reserved.
//

import UIKit

class TabBarAnimationConatiner: UIView {
    
    weak var currentViewController: UIViewController?
    weak var parent: UIViewController?
    
    var transaction: UUID = UUID()
    
    enum Animation {
        case left
        case right
    }
    
    var animator: UIViewPropertyAnimator!
    
    func setNewContent(viewController: UIViewController, animation: Animation? = nil) {
        
        guard let parent = self.parent else {
            return
        }
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewController.view)
        viewController.view.constrainAllMargins(with: self)
        viewController.willMove(toParent: parent)
        currentViewController?.willMove(toParent: nil)
        currentViewController?.removeFromParent()
        parent.addChild(viewController)
        
        transaction = UUID()
        
        let completion = {  [currentViewController] in
            viewController.didMove(toParent: parent)
            if let current = currentViewController {
                current.didMove(toParent: nil)
                current.view.transform = CGAffineTransform.identity
                current.view.removeFromSuperview()
            }
        }
        
        if let animation = animation, let current = self.currentViewController {
            let offset = animation == .right ? self.bounds.width : -self.bounds.width
            viewController.view.transform = CGAffineTransform.identity.translatedBy(x: offset, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                current.view.transform = CGAffineTransform.identity.translatedBy(x: -offset, y: 0)
                viewController.view.transform = CGAffineTransform.identity
            } completion: { [transaction] finished in
                if transaction == self.transaction {
                    completion()
                }
            }
        } else {
            completion()
        }
        self.currentViewController = viewController
        
    }
}
