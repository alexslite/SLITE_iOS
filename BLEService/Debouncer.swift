//
//  Debouncer.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class Debouncer {
    // MARK: - Properties
    
    private let timeInterval: TimeInterval
    private var shouldTriggerHandler = true
    
    // MARK: - Init
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    func execute(_ handler: () -> Void) {
        guard shouldTriggerHandler else {
            return
        }
        
        handler()
        shouldTriggerHandler = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.shouldTriggerHandler = true
        }
    }
}
