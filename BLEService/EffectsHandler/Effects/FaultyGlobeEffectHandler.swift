//
//  FaultyGlobeEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class FaultyGlobeEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var isPlaying = true
    
    // MARK: - init
    
    init(lightIds: [String]) {
        self.lightIds = lightIds
    }
    
    func removeLightId(_ id: String) {
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
        guard isPlaying else { return }
        let dimValue = Int.random(in: 0...50)
        let dimTime = Double.random(in: 0...1.5)
        let backToFullTime = Double.random(in: 0...0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dimTime) { [weak self] in
            guard let self = self else { return }
            self.write(data: self.generateNewIntruction(brightness: dimValue))
            DispatchQueue.main.asyncAfter(deadline: .now() + backToFullTime) {
                self.write(data: self.generateFullInstruction())
                self.loop()
            }
        }
    }
    
    private func write(data: Data) {
        guard isPlaying else { return }
        
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
    
    private func generateNewIntruction(brightness: Int) -> Data {
        let stringValue = "5600,0,0,\(brightness)"
        return stringValue.data(using: .utf8)!
    }
    
    private func generateFullInstruction() -> Data {
        let stringValue = "5600,0,0,100"
        return stringValue.data(using: .utf8)!
    }
}
