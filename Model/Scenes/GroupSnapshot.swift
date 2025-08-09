//
//  GroupSnapshot.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import SwiftUI

struct GroupSnapshot: Codable {
    var id: String
    var dataSnapshot: LightSnapshot
    var lights: [LightSnapshot]
}
