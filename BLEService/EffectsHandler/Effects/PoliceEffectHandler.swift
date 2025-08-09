//
//  PoliceEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 27.05.2022.
//

import Foundation

final class PoliceEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private let instructions: [Data] = [
        "5600,359,100,100".data(using: .utf8)!,
        "5600,359,100,0".data(using: .utf8)!,
        "5600,359,100,100".data(using: .utf8)!,
        "5600,359,100,0".data(using: .utf8)!,
        "5600,242,100,100".data(using: .utf8)!,
        "5600,242,100,0".data(using: .utf8)!,
        "5600,242,100,100".data(using: .utf8)!,
        "5600,242,100,0".data(using: .utf8)!]
    
    private var isPlaying = true
    private var phaseIndex: [String: Int] = [:]
    
    // MARK: - init
    
    init(lightIds: [String]) {
        self.lightIds = lightIds
        
        lightIds.forEach {
            phaseIndex[$0] = 0
        }
    }
    
    func removeLightId(_ id: String) {
        print("BLEServiceC: id was removed")
        lightIds.remove(object: id)
    }
    
    // MARK: - EffectHandler
     
    func start() {
        loop()
    }
    
    func stop(shouldUpdate: Bool) {
        isPlaying = false
        lightIds.forEach {
            BLEService.shared.effectWillStopForLightWith($0, shouldUpdate: shouldUpdate)
        }
    }
    
    // MARK: - Private
    
    @objc private func loop() {
        lightIds.forEach {
            setUpdateCallback(for: $0)
        }
        lightIds.forEach {
            write(data: instructions[0], lightId: $0)
        }
    }
    
    private func setUpdateCallback(for lightId: String) {
        BLEService.shared.setUpdateCallbackForEffectOnLightWith(lightId) { [weak self] in
            guard let self = self, self.isPlaying, var index = self.phaseIndex[lightId] else { return }
            
            index += 1
            if index == self.instructions.count { index = 0 }
            
            let timeInterval: TimeInterval = !index.isMultiple(of: 2) ? 0.15 : 0
            self.phaseIndex[lightId] = index
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                self.write(data: self.instructions[index], lightId: lightId)
            }
        }
    }
    
    private func write(data: Data, lightId: String) {
        guard isPlaying else { return }
        BLEService.shared.writeEffectInstruction(data: data, lightId: lightId)
    }
}
