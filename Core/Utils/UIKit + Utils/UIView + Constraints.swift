//
//  UIView + Constraints.swift
//  Tap2Map
//
//  Created by Efraim Budusan on 7/3/19.
//  Copyright © 2019 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func constrainAllMargins(with other:UIView) {
        self.topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
    }
    
    func constrainToCenter(of other:UIView, verticalPadding:CGFloat, horizontalPadding:CGFloat) {
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: other.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: other.centerXAnchor),
            self.heightAnchor.constraint(lessThanOrEqualTo: other.heightAnchor, constant: verticalPadding * 2.0),
            self.widthAnchor.constraint(lessThanOrEqualTo: other.widthAnchor, constant: horizontalPadding * 2.0)
        ])
    }
    
    func addSubviewWithConstraints(_ subview:UIView) {
        subview.frame = self.bounds
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.constrainAllMargins(with: self)
    }
}

extension NSLayoutConstraint {
    
    static func activate( @ConstraintsBuilder builder: () -> [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(builder())
    }
}

@resultBuilder
struct ConstraintsBuilder {
    
    static func buildBlock() -> [NSLayoutConstraint] { [] }
    
    static func buildBlock(_ content: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        return content
    }
    
    static func buildBlock(_ values: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        return values
    }
}
