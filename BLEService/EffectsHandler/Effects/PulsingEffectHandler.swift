//
//  PulsingEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class PulsingEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var timer: Timer?
    private var isPlaying = true
    
    var instructionsArray: [String: [Data]] = [:]
    var isWaiting = false
    
    // MARK: - init
    
    init(lightIds: [String]) {
        self.lightIds = lightIds
        
        lightIds.forEach {
            instructionsArray[$0] = []
        }
    }
    
    func removeLightId(_ id: String) {
        lightIds.remove(object: id)
    }
    
    // MARK: - EffectHandler
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
        
        lightIds.forEach {
            setUpdateCallback(for: $0)
        }
        
        loop()
    }
    
    func stop(shouldUpdate: Bool) {
        isPlaying = false
        lightIds.forEach {
            BLEService.shared.effectWillStopForLightWith($0, shouldUpdate: shouldUpdate)
        }
        
        instructionsArray.removeAll()
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private
    
    @objc private func loop() {
        guard isPlaying else { return }
        
        for value in stride(from: 0, through: 359, by: 4) {
            write(data: generateNewIntruction(hue: value, brightness: 100))
        }
    }
    
    private func generateNewIntruction(hue: Int, brightness: Int) -> Data {
        let stringValue = "5600,\(hue),100,\(brightness)"
        return stringValue.data(using: .utf8)!
    }
    
    private func write(data: Data) {
        guard isPlaying else { return }
        
        lightIds.forEach {
            instructionsArray[$0]?.append(data)
        }
        
        guard !isWaiting else { return }
        isWaiting = true
        
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
    
    func setUpdateCallback(for lightId: String) {
        BLEService.shared.setUpdateCallbackForEffectOnLightWith(lightId) { [weak self] in
            guard let self = self, self.isPlaying, let data = self.instructionsArray[lightId]?.first else { return }
            BLEService.shared.writeEffectInstruction(data: data, lightId: lightId)
            self.instructionsArray[lightId]?.remove(at: 0)
        }
    }
}
