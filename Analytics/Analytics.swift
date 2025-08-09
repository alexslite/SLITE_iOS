//
//  Analytics.swift
//  Slite
//
//  Created by Paul Marc on 07.07.2022.
//

import Foundation
import Mixpanel

enum MixpanelEvent: String {
    case lightAddedSuccessfully = "Light added successfully"
    case lightTurnedOn = "Light turned on"
    case lightTurnedOff = "Light turned off"
    case sceneCreatedSuccessfully = "Scene created successfully"
    case sceneAppliedSuccessfully = "Scene applied successfully"
    case groupCreatedSuccessfully = "Group created successfully"
    case groupTurnedOn = "Group turned on"
    case groupTurnedOff = "Groups turned off"
    
    case advancedModeWhite = "Advanced mode - white"
    case advancedModeColor = "Advanced mode - color"
    case advancedModeEffect = "Advanced mode - effects"
    
    case photoColorPicker = "Photo color picker usage"
    case cameraColorPicker = "Camera color picker usage"
}

final class Analytics {
    
    static let shared = Analytics()
    private init() {}
    
    func trackEvent(_ event: MixpanelEvent) {
        Mixpanel.mainInstance().track(event: event.rawValue)
    }
    
    func trackEvent(_ event: MixpanelEvent, properties: [String: MixpanelType]) {
//        print("\nMIXPANEL: \(event.rawValue) -> \(properties)\n")
        Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
    }
}
