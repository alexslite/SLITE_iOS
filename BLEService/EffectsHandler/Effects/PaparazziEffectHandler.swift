//
//  PaparazziEffecthandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class PaparazziEffectHandler: EffectHandler {
    
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
        
        let time: TimeInterval = Double.random(in: 0...0.8)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let self = self else { return }
            self.flicker()
        }
    }
    
    private func flicker() {
        write(data: generateNewIntruction(brightness: Int.random(in: 30...100)))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.write(data: self.generateOffInstruction())
            self.loop()
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
    
    private func generateOffInstruction() -> Data {
        let stringValue = "5600,0,0,0"
        return stringValue.data(using: .utf8)!
    }
}
