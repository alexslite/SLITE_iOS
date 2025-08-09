//
//  UIWindow + SafeArea.swift
//  Wellory
//
//  Created by Efraim Budusan on 4/13/21.
//  Copyright © 2021 Wellory. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIWindow {
    static var appKeyWindow:UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}

extension UIWindow {
    
    /// Use this method to obtain a padding value so that a minimum distance from the device screen edge is maintain when having elements having constant distances to safe area bounds.
    static func safeAreaPadding(from edge: Edge, safeAreaPadding padding: CGFloat = 0, minimumDistanceFromEdge minimum: CGFloat) -> CGFloat {
        guard let window = appKeyWindow else {
            return minimum
        }
        switch edge {
        case .top:
            return max(minimum - window.safeAreaInsets.top, padding)
        case .bottom:
            return max(minimum - window.safeAreaInsets.bottom, padding)
        case .leading:
            return max(minimum - window.safeAreaInsets.left, padding)
        case .trailing:
            return max(minimum - window.safeAreaInsets.right, padding)
        }
    }
    
    static func padding(from edge: Edge, withMinimumDistance miminum: CGFloat) -> CGFloat {
        return safeAreaPadding(from: edge, safeAreaPadding: 0, minimumDistanceFromEdge: miminum)
    }
    
    static func safeAreaPadding(from edge: Edge) -> CGFloat {
        guard let window = appKeyWindow else {
            return 0
        }
        switch edge {
        case .top:
            return window.safeAreaInsets.top
        case .bottom:
            return window.safeAreaInsets.bottom
        case .leading:
            return window.safeAreaInsets.left
        case .trailing:
            return window.safeAreaInsets.right
        }
    }
    
}


