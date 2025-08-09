//
//  PercentageRepresentedValue.swift
//  Slite
//
//  Created by Efraim Budusan on 21.02.2022.
//

import Foundation
import SwiftUI

@propertyWrapper
struct PercentageRepresentableIntegerBinding {
    
    private var get: () -> Int
    private var set: (Int) -> Void
    
    var minimumValue: Int
    var maximumValue: Int
    
    var wrappedValue: Int {
        get {
            return get()
        }
        set {
            set(value: newValue)
        }
    }
    
    func set(value: Int) {
        let newValue = min(maximumValue, max(minimumValue, value))
        set(newValue)
    }
    
    func set(percentage: CGFloat) {
        let newValue = minimumValue + Int(percentage * CGFloat(maximumValue - minimumValue))
        set(newValue)
    }
    
    var percentage: CGFloat {
        let percentage = CGFloat(get() - minimumValue)  / CGFloat(maximumValue - minimumValue)
        return max(min(percentage, 1), 0)
    }
    
    init(minimumValue: Int, maximumValue: Int,  get: @escaping () -> Int, set: @escaping  (Int) -> Void) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.get = get
        self.set = set
    }
}
