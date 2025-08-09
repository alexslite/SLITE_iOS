//
//  FireEffectHandler.swift
//  Slite
//
//  Created by Paul Marc on 27.05.2022.
//

import Foundation

final class FireEffectHandler: EffectHandler {
    // MARK: - Properties
    
    private var lightIds: [String]
    private var lastHue: Int?
    private var isPlaying = true
    private var lastBrightness = 0
    
    let colors = [RGB(hexadecimal: "#FB8C00").hsv.h,
                  RGB(hexadecimal: "#FF9800").hsv.h,
                  RGB(hexadecimal: "#F57C00").hsv.h,
                  RGB(hexadecimal: "#E88504").hsv.h]
    
    
    // MARK: - ini
    
    init(lightIds: [String]) {
        self.lightIds = lightIds
    }
    
    func removeLightId(_ id: String) {
        lightIds.remove(object: id)
    }
    
    // MARK: - EffectHandler
    
    func start() {
        isPlaying = true
        loop()
    }
    
    func stop(shouldUpdate: Bool) {
        lightIds.forEach {
            BLEService.shared.effectWillStopForLightWith($0, shouldUpdate: shouldUpdate)
        }
        
        isPlaying = false
    }
    
    // MARK: - Private
    
    @objc private func loop() {
        guard isPlaying else { return }
        
        let fr = Double.random(in: 1...3) as TimeInterval
        
        let hue = lastHue ?? Int(colors.randomElement()!)
        let secondHue = Int(colors.randomElement()!)
        
        self.writeInterpolatedValues(hue: hue, nextHue: secondHue, brightness: 100)

        flicker()
        
        
        lastHue = secondHue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fr) { [weak self] in
            self?.loop()
        }
    }
    
    private func flicker() {
        guard let lastHue = lastHue else {
            return
        }

        write(data: generateNewIntruction(hue: lastHue, brightness: 95))
        write(data: generateNewIntruction(hue: lastHue, brightness: 90))
        write(data: generateNewIntruction(hue: lastHue, brightness: 85))
        write(data: generateNewIntruction(hue: lastHue, brightness: 80))
        write(data: generateNewIntruction(hue: lastHue, brightness: 75))
        write(data: generateNewIntruction(hue: lastHue, brightness: 70))
        
        write(data: generateNewIntruction(hue: lastHue, brightness: 70))
        write(data: generateNewIntruction(hue: lastHue, brightness: 75))
        write(data: generateNewIntruction(hue: lastHue, brightness: 80))
        write(data: generateNewIntruction(hue: lastHue, brightness: 85))
        write(data: generateNewIntruction(hue: lastHue, brightness: 90))
        write(data: generateNewIntruction(hue: lastHue, brightness: 95))
        
    }
    
    private func writeInterpolatedValues(hue: Int, nextHue: Int, brightness: Int) {
        
        if hue > nextHue {
            for value in stride(from: nextHue, through: hue, by: 1) {
                let data = self.generateNewIntruction(hue: value, brightness: brightness)
                self.write(data: data)
            }
        } else {
            for value in stride(from: hue, through: nextHue, by: 1) {
                let data = self.generateNewIntruction(hue: value, brightness: brightness)
                self.write(data: data)
            }
        }
    }
    
    private func generateNewIntruction(hue: Int, brightness: Int) -> Data {
        lastBrightness = brightness
        
        let stringValue = "5600,\(hue),100,\(brightness)"
        return stringValue.data(using: .utf8)!
    }
    
    private func write(data: Data) {
        guard isPlaying else { return }
        lightIds.forEach {
            BLEService.shared.writeEffectInstruction(data: data, lightId: $0)
        }
    }
}
