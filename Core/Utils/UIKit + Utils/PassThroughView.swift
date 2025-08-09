//
//  PassThroughView.swift
//  Tap2Map
//
//  Created by Efraim Budusan on 2/13/19.
//  Copyright © 2019 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

class PassThroughView: UIView {

    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView === self {
            return nil
        }
        return hitView
    }
}

class PassThroughScrollView: UIScrollView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if view.point(inside: point, with: event) {
                return true
            }
        }
        return false
    }
}


class SubviewTouchForward: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if view.point(inside: point, with: event) {
                return true
            }
        }
        return false
    }
}

class PassThroughCollectionView: UICollectionView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < 0 {
            return false
        }
        return super.point(inside: point, with: event)
    }
}
