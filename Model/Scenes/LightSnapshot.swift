//
//  LightSnapshot.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import SwiftUI

struct LightSnapshot: Codable {
    var id: String   
    var dataOutput: Data
    var mode: LightData.Mode
    var effect: LightData.Effect?
    
    var color: [Color]
}
