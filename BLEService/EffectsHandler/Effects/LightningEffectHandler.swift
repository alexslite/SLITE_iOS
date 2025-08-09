//
//  LightningEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 30.05.2022.
//

import Foundation

final class LightningEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var isPlaying = true
    private var numberOfFlashes = 0
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
        let time: TimeInterval = Double(Int.random(in: 0...5))
        let weight = Int.random(in: 1...2)
        if weight == 1 {
            numberOfFlashes = Int.random(in: 1...3)
        } else {
            numberOfFlashes = Int.random(in: 3...10)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let self = self else { return }
            self.startFlickers(completion: {
                self.loop()
            })
        }
    }
    
    private func startFlickers(completion: (() -> Void)? = nil) {
        flicker { [weak self] in
            guard let self = self else { return }
            self.numberOfFlashes -= 1
            if self.numberOfFlashes > 0 {
                self.startFlickers(completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    private func flicker(completion: @escaping () -> Void) {
        write(data: generateNewIntruction())
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.05...0.3)) { [weak self] in
            guard let self = self else { return }
            self.write(data: self.generateOffInstruction())
            completion()
        }
    }
    
    private func write(data: Data) {
        guard isPlaying else { return }
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
    
    private func generateNewIntruction() -> Data {
        let brightness = Int.random(in: 30...100)
        
        let stringValue = "5600,0,0,\(brightness)"
        return stringValue.data(using: .utf8)!
    }
    
    private func generateOffInstruction() -> Data {
        let stringValue = "5600,0,0,0"
        return stringValue.data(using: .utf8)!
    }
}
