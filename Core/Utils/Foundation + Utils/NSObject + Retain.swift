//
//  NSObject + Retain.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation

extension NSObjectProtocol {
    
    func retain(_ object:AnyObject) {
        objc_setAssociatedObject(self, UUID.init().uuidString, object, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @discardableResult
    func retained(by object: AnyObject) -> Self {
        objc_setAssociatedObject(self, UUID.init().uuidString, object, .OBJC_ASSOCIATION_RETAIN)
        return self
    }
}
