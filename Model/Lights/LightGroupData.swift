//
//  LightGroupData.swift
//  Slite
//
//  Created by Efraim Budusan on 07.02.2022.
//

import Foundation

struct LightGroupData: Codable {
    
    let id: String
    var name: String
    
    static func dummy() -> Self {
        return .init(id: UUID().uuidString, name: "Vlogging Setup")
    }
    
}
