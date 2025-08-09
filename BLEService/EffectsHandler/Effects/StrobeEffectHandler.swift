//
//  StrobeEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class StrobeEffectHandler: EffectHandler {
    
    private var lightIds: [String]
    private let ph1 = "5600,0,0,100".data(using: .utf8)!
    private let ph2 = "5600,0,0,0".data(using: .utf8)!
    
    private var timer: Timer?
    private var isPlaying = true
    
    // on / off status for each light
    private var isOff: [String: Bool] = [:]
    
    init(lightIds: [String]) {
        self.lightIds = lightIds
    }
    
    func removeLightId(_ id: String) {
        lightIds.remove(object: id)
    }
    
    func start() {
        lightIds.forEach {
            setUpdateCallback(for: $0)
        }
        
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: self.ph1, lightId: $0)
        }
    }
    
    func setUpdateCallback(for lightId: String) {
        BLEService.shared.setUpdateCallbackForEffectOnLightWith(lightId) { [weak self] in
            guard let self = self else { return }
            if self.isOff[lightId] == true {
                BLEService.shared.writeEffectInstruction(data: self.ph1, lightId: lightId)
                self.isOff[lightId] = false
            } else {
                BLEService.shared.writeEffectInstruction(data: self.ph2, lightId: lightId)
                self.isOff[lightId] = true
            }
        }
    }
    
    func stop(shouldUpdate: Bool) {
        isPlaying = false
        lightIds.forEach {
            BLEService.shared.effectWillStopForLightWith($0, shouldUpdate: shouldUpdate)
        }
        timer?.invalidate()
        timer = nil
    }
}
