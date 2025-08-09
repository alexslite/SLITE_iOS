//
//  TVEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class TVEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var isPlaying = true
    
    private var brightness = 80
    private var hue = 150
    private var saturation = 30
    
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
    
    private func loop() {
        guard isPlaying else {
            return
        }
        
        let time = Double.random(in: 0...1)
        
        let weight = Int.random(in: 0...100)
        print("\nSXR: \(weight)\n")
        if weight > 90 {
            let offset = Int.random(in: -15...15)
            let newBrightness = brightness + offset
            
            let instruction = generateNewIntruction(brightness: newBrightness)
            write(data: instruction)
        } else {
            hue = Int.random(in: 0...359)
            saturation = Int.random(in: 0...30)
            brightness = Int.random(in: 30...100)
            
            let instruction = generateNewIntruction(brightness: brightness)
            write(data: instruction)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            self?.loop()
        }
    }
    
    private func write(data: Data) {
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
    
    private func generateNewIntruction(brightness: Int) -> Data {
        let stringValue = "5600,\(hue),\(saturation),\(brightness)"
        return stringValue.data(using: .utf8)!
    }
}
