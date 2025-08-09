//
//  EffectLooper.swift
//  Slite
//
//  Created by Paul Marc on 27.05.2022.
//

import Foundation

protocol EffectHandler {
    func start()
    func stop(shouldUpdate: Bool)
    func removeLightId(_ id: String)
}

final class EffectLooper {
        
    static let shared = EffectLooper()
    private init() {}
    
    private var effectHandlers: [String: EffectHandler?] = [:]
    
    // MARK: - Start / Stop
    
    func startEffect(_ effect: LightData.Effect, lightId: String) {
        effectHandlers[lightId]??.stop(shouldUpdate: false)
        
        let handler = EffectHandlerFactory().getHandlerFor(effect, with: [lightId])
        effectHandlers[lightId] = handler
        handler.start()
    }
    
    func startEffect(_ effect: LightData.Effect, lightIds: [String], groupId: String) {
        effectHandlers[groupId]??.stop(shouldUpdate: false)
        
        let handler = EffectHandlerFactory().getHandlerFor(effect, with: lightIds)
        effectHandlers[groupId] = handler
        handler.start()
    }
    
    /// - Parameter shouldUpdate: pass true if an update is necessary to update with the latest values from the light. Should be false in case of a turnOff
    func stopEffect(lightId: String, shouldUpdate: Bool) {
        effectHandlers[lightId]??.stop(shouldUpdate: shouldUpdate)
        effectHandlers.removeValue(forKey: lightId)
    }
    
    func stopEffectOnLightWithId(_ lightId: String, fromGroupWith groupId: String) {
        effectHandlers[groupId]??.removeLightId(lightId)
    }
}
