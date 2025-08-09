//
//  DiscoEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class DiscoEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var timer: Timer?
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
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
    }
    
    func stop(shouldUpdate: Bool) {
        isPlaying = false
        lightIds.forEach {
            BLEService.shared.effectWillStopForLightWith($0, shouldUpdate: shouldUpdate)
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private
    
    @objc private func loop() {
        guard isPlaying else { return }
        
        let instruction = generateNewIntruction()
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: instruction, lightId: $0)
        }
    }
    
    private func generateNewIntruction() -> Data {
        let hue = Int.random(in: 0...359)
        let stringValue = "5600,\(hue),100,100"
        return stringValue.data(using: .utf8)!
    }
}
