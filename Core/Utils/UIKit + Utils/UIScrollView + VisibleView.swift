//
//  UIScrollView + VisibleView.swift
//  AmberScript
//
//  Created by Efraim Budusan on 12/17/19.
//  Copyright © 2019 AmberScript. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIScrollView {
    
    func scrollVertically(toVisibleView view:UIView, offset:CGFloat, animated:Bool = true) {
        
        var pointToScroll = self.contentOffset
        let adjustedFrame = self.convert(view.frame, from: view.superview)
        let hasToBeVisibleY = adjustedFrame.maxY + offset
        guard hasToBeVisibleY > self.contentOffset.y + self.bounds.height else {
            return
        }
        guard self.contentSize.height > 0 else {
            return
        }
        pointToScroll.y = hasToBeVisibleY - self.bounds.height
        self.setContentOffset(pointToScroll, animated: animated)
    }
    
    
    func scrollHorizontally(toVisibleLocalRect rect:CGRect, offset:CGFloat, animated:Bool = true, contentInset: UIEdgeInsets? = nil) {
        
        var pointToScroll = self.contentOffset
        let adjustedFrame = rect

        guard self.contentSize.width > 0 else {
            return
        }
        let maxX = adjustedFrame.maxX + offset
        let minX = adjustedFrame.minX - offset
        if maxX > self.contentOffset.x + self.bounds.width {
            pointToScroll.x = maxX - self.bounds.width
            self.setContentOffset(pointToScroll, animated: animated)
        } else if minX < self.contentOffset.x {
            pointToScroll.x = max(0,minX)
            self.setContentOffset(pointToScroll, animated: animated)
        }
    }
    
    func scrollVertically(toVisibleLocalRect rect:CGRect, offset:CGFloat, animated:Bool = true, contentInset: UIEdgeInsets? = nil) {
        
        var pointToScroll = self.contentOffset
        let adjustedFrame = rect
        let contentInset = contentInset ?? self.contentInset
        guard self.contentSize.height > 0 else {
            return
        }
        let maxY = adjustedFrame.maxY + offset
        let minY = adjustedFrame.minY - offset
//        let height = self.bounds.height - (contentInset.top + contentInset.bottom)
        if maxY > self.contentOffset.y + self.bounds.height - contentInset.bottom {
            pointToScroll.y = maxY - self.bounds.height + contentInset.bottom
            self.setContentOffset(pointToScroll, animated: animated)
        } else if minY < self.contentOffset.y + contentInset.top {
            pointToScroll.y = max(0,minY - contentInset.top)
            self.setContentOffset(pointToScroll, animated: animated)
        }
    }

    func scrollToBottomIfNeeded(animated:Bool = true) {
        var pointToScroll = self.contentOffset
        guard contentOffset.y + self.bounds.height + self.contentInset.top > self.contentSize.height else {
            return
        }
        guard self.contentSize.height > 0 else {
            return
        }
        pointToScroll.y = self.contentSize.height - self.bounds.height
        self.setContentOffset(pointToScroll, animated: animated)
    }
    
    func scrollToBottomIfPossible(animated:Bool = true) {
        var pointToScroll = self.contentOffset
        guard self.contentSize.height + self.contentInset.top > self.bounds.height else {
            return
        }
        guard self.contentSize.height > 0 else {
            return
        }
        pointToScroll.y = self.contentSize.height - self.bounds.height + self.contentInset.bottom
        self.setContentOffset(pointToScroll, animated: animated)
    }
    
    func scrollToBottom(animated:Bool = true) {
        var pointToScroll = self.contentOffset
        pointToScroll.y = self.contentSize.height - self.bounds.height
        self.setContentOffset(pointToScroll, animated: animated)
    }
    
    var isScrolledAtBottom:Bool {
        return self.contentOffset.y >= self.contentSize.height - self.bounds.height
    }
    
    func scrollToTopIfNeeded() {
        if self.contentSize.height <= self.bounds.height {
            if self.contentOffset.y > 0 {
                self.contentOffset = CGPoint.zero
            }
        }
    }
    
    func page(horizontally: Bool = true) -> Int {
        if horizontally {
            if self.bounds.width == 0 { return 0 }
            return Int(self.contentOffset.x / self.bounds.width)
        } else {
            if self.bounds.height == 0 { return 0 }
            return Int(self.contentOffset.y / self.bounds.height)
        }
    }
    
    func scrollToPage(index:Int, animated:Bool = true, horizontally: Bool = true, fixedDuration: Bool = true) {
        var contentOffset = self.contentOffset
        if horizontally {
            contentOffset.x = self.frame.width * CGFloat(index)
        } else {
            contentOffset.y = self.frame.width * CGFloat(index)
        }
        if !fixedDuration {
            self.setContentOffset(contentOffset, animated: animated)
            return
        }
        let block = { [weak self] in
            self?.setContentOffset(contentOffset, animated: false)
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
                block()
            } completion: { finished in
                return
            }
        } else {
            block()
        }
    }
    
    
}
