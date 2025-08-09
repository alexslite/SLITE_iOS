//
//  Scene.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import Foundation
import SwiftUI

protocol SceneSnapshotDataSource: AnyObject {
    var isScenesEnable: Bool { get }
    var lightsSnapshot: [LightSnapshot] { get }
    var groupsSnapshot: [GroupSnapshot] { get }
}
protocol ScenesActionsDelegate: AnyObject {
    func updateLightWith(_ id: String, to mode: LightData.Mode, data: Data, effect: LightData.Effect?)
    func updateGroupWith(_ id: String, to mode: LightData.Mode, data: Data, effect: LightData.Effect?)
}

enum SceneState: Codable {
    case appllying
    case idle
}

struct Scene: Codable {
    var id: String
    var name: String
    var lights: [LightSnapshot]
    var groups: [GroupSnapshot]
    var state: SceneState = .idle
    
    var gradientColors: [Color] {
        let colors = lights.flatMap { $0.color } + groups.flatMap { $0.dataSnapshot.color }
        let sorted = colors.sorted { $0.decimalValue > $1.decimalValue }
        return sorted
    }
}
