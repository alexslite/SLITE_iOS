//
//  FireworksEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 31.05.2022.
//

import Foundation

final class FireworksEffectHandler: EffectHandler {
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
    
    private func fade() {
        let hue = Int.random(in: 1...360)
        
        for output in stride(from: 70, through: 100, by: 10) {
            write(data: generateNewIntruction(hue: hue, bright: output))
        }
        let endBrValue = Int.random(in: 0...75)
        for output in stride(from: endBrValue, through: 100, by: 5) {
            write(data: generateNewIntruction(hue: hue, bright: 100 - output))
        }
    }
    
    private func write(data: Data) {
        guard isPlaying else { return }
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
    
    @objc private func loop() {
        timer?.invalidate()
        
        var numberOfFireworks = 0
        let weight = Int.random(in: 0...100)
    
        if weight < 50 {
            numberOfFireworks = 1
        } else if weight < 75 {
            numberOfFireworks = 2
        } else if weight < 85 {
            numberOfFireworks = 3
        } else if weight < 95 {
            numberOfFireworks = 4
        } else {
            numberOfFireworks = 5
        }
        
        for _ in 0...numberOfFireworks {
            fade()
        }
        
        let time = Double.random(in: 1...5) as TimeInterval
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
    }
    
    private func generateNewIntruction(hue: Int, bright: Int) -> Data {
        let stringValue = "5600,\(hue),100,\(bright)"
        return stringValue.data(using: .utf8)!
    }
}
