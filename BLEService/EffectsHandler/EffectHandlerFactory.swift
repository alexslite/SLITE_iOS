//
//  EffectHandlerFactory.swift
//  Slite
//
//  Created by Paul Marc on 27.05.2022.
//

import Foundation

final class EffectHandlerFactory {
    
    func getHandlerFor(_ effect: LightData.Effect, with lightIds: [String]) -> EffectHandler {
        switch effect {
        case .police:
            return PoliceEffectHandler(lightIds: lightIds)
        case .pulsing:
            return PulsingEffectHandler(lightIds: lightIds)
        case .paparazzi:
            return PaparazziEffectHandler(lightIds: lightIds)
        case .disco:
            return DiscoEffectHandler(lightIds: lightIds)
        case .tv:
            return TVEffectHandler(lightIds: lightIds)
        case .faulty:
            return FaultyGlobeEffectHandler(lightIds: lightIds)
        case .fire:
            return FireEffectHandler(lightIds: lightIds)
        case .strobe:
            return StrobeEffectHandler(lightIds: lightIds)
        case .lightning:
            return LightningEffectHandler(lightIds: lightIds)
        case .fireworks:
            return FireworksEffectHandler(lightIds: lightIds)
        }
    }
}
