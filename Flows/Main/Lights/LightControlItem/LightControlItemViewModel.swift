//
//  LightControlItemViewModel.swift
//  Slite
//
//  Created by Efraim Budusan on 07.02.2022.
//

import Foundation
import UIKit
import Combine
import SwiftUI

protocol LightControlViewModel: AnyObject, TypeErasedObservableObject {

    var data: LightData { get set }
    var isGroup: Bool { get }
    
    var brightness: PercentageRepresentableIntegerBinding { get }
    var temperature: PercentageRepresentableIntegerBinding { get }
    var saturation: PercentageRepresentableIntegerBinding { get }
    var hue: PercentageRepresentableIntegerBinding { get }
    
    var lightUpdateCallback: (() -> Void)? { get set } 
    
    func setBrightnessFromUserAction(percentage: CGFloat)
    func setTemperatureFromUserAction(percentage: CGFloat)
    func setSaturationFromUserAction(percentage: CGFloat)
    func setHueFromUserAction(percentage: CGFloat)
    func setHueAndSaturationFromUserAction(hueValue: Int, saturationPercentage: CGFloat)
    
    var effect: LightData.Effect? { get set }
    func startEffect(_ effect: LightData.Effect)
    func stopOngoingEffect()
    
    func updateToColorMode(colorHex: String, shouldWrite: Bool)
    func updateToWhiteColorMode(shouldWrite: Bool)
    func updateToEffectsMode(shouldWrite: Bool)
    func updateLightsToEffectMode(shouldWrite: Bool)
    
    func turnLightOff()
    func turnLightOn()
    
    var powerButtonGradient: LinearGradient { get }
    
    var showSubtitleIcon: Bool { get }
    var subtitle: String { get }
}
