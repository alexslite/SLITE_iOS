//
//  DispatchQueue + Utils.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

extension DispatchQueue {
    public func after(seconds: Double, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}
