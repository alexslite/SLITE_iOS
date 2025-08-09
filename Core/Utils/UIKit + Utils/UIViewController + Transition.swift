//
//  UIViewController + Transition.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import UIKit

class CustomTransitionHandler: NSObject, UIViewControllerTransitioningDelegate {
    
    struct TransitionInfo {
        let aniamted: Bool
        let duration: TimeInterval
        let completion: () -> Void
    }
    
    let duration: TimeInterval
    let onPresent: (TransitionInfo) -> Void
    let onDismiss: (TransitionInfo) -> Void
    
    init(viewController: UIViewController, duration: TimeInterval, onPresent: @escaping (TransitionInfo) -> Void, onDismiss: @escaping (TransitionInfo) -> Void) {
        self.duration = duration
        self.onPresent = onPresent
        self.onDismiss = onDismiss
        super.init()
        viewController.retain(self)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedTransitioning(duration: duration, isDismissal: false, animationBlock: onPresent)
    }

    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedTransitioning(duration: duration, isDismissal: true, animationBlock: onDismiss)
    }
    
    class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        
        let duration: TimeInterval
        var isDismissal: Bool
        let animationBlock: (TransitionInfo) -> Void
        
        
        init(duration: TimeInterval, isDismissal: Bool, animationBlock: @escaping (TransitionInfo) -> Void) {
            self.duration = duration
            self.isDismissal = isDismissal
            self.animationBlock = animationBlock
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            
            if !isDismissal {
                toViewController.view.translatesAutoresizingMaskIntoConstraints = false
                transitionContext.containerView.addSubview(toViewController.view)
                toViewController.view.constrainAllMargins(with: transitionContext.containerView)
            }
            animationBlock(.init(aniamted: transitionContext.isAnimated, duration: duration) {
                toViewController.view.layer.mask = nil
                transitionContext.completeTransition(true)
        
            })
        }
    }
}
