//
//  UserDefaults+Extensions.swift
//  Slite
//
//  Created by Paul Marc on 11.03.2022.
//

import Foundation

extension UserDefaults {

    fileprivate static let applicationWasLaunchedKey = "application_was_launched"
    
    static var applicationWasLaunched: Bool {
        UserDefaults.standard.value(forKey: UserDefaults.applicationWasLaunchedKey) as? Bool ?? false
    }

    static func set(applicationWasLaunched: Bool) {
        UserDefaults.standard.set(applicationWasLaunched, forKey: UserDefaults.applicationWasLaunchedKey)
    }
}
