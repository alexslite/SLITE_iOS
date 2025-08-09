//
//  UIColor + Extensions.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit
import SwiftUI

//Use coolor.co to help you name colors. (https://coolors.co/b9693c)

extension UIColor {
    
    static let coral = UIColor(named: "Coral") ?? .green
    static let eerieBlack = UIColor(named: "EerieBlack") ?? .green
    static let midnightGreen = UIColor(named: "MidnightGreen") ?? .green
    static let sonicSilver = UIColor(named: "SonicSilver") ?? .green
    static let tartRed = UIColor(named: "TartRed") ?? .green
    
    static let primaryForeground = UIColor(light: .black, dark: .white)
    static let secondaryForegorund = UIColor(light: .eerieBlack, dark: .sonicSilver)
    static let tertiaryForegorund = UIColor(light: .sonicSilver, dark: .eerieBlack)
    
    static let primaryBackground = UIColor(light: .white, dark: .black)
    static let secondaryBackground = UIColor(light: .sonicSilver, dark: .eerieBlack)
    
}

extension Color {
    
    static let coral = Color("Coral")
    static let eerieBlack = Color("EerieBlack")
    static let midnightGreen = Color("MidnightGreen")
    static let sonicSilver = Color("SonicSilver")
    static let tartRed = Color("TartRed")
    static let grey = Color("Grey")
    
    static let primaryForeground = Color(light: .black, dark: .white)
    static let secondaryForegorund = Color(light: .eerieBlack, dark: .sonicSilver)
    static let tertiaryForegorund = Color(light: .sonicSilver, dark: .eerieBlack)
    
    static let primaryBackground = Color(light: .white, dark: .black)
    static let secondaryBackground = Color(light: .sonicSilver, dark: .eerieBlack)
}

extension Color {
    init(temperature: CGFloat) {
        let percentKelvin = temperature / 100;
        let red, green, blue: CGFloat

        red =   Self.clamp(percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)));
        green = Self.clamp(percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin - 60, -0.0755148492));
        blue =  Self.clamp(percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307));

        self.init(red: red / 255, green: green / 255, blue: blue / 255)
    }

    private static func clamp(_ value: CGFloat) -> CGFloat {
        return value > 255 ? 255 : (value < 0 ? 0 : value);
    }
    
    var hexValue: String {
        let components = self.cgColor?.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        
        return hexString
     }
    
    var decimalValue: UInt64 {
        UInt64(hexValue.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0
    }
}

extension UIColor {
    
    public convenience init(_ rgbValue: UInt,_ alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    convenience init(temperature: CGFloat) {
        let percentKelvin = temperature / 100;
        let red, green, blue: CGFloat

        red =   Self.clamp(percentKelvin <= 66 ? 255 : (329.698727446 * pow(percentKelvin - 60, -0.1332047592)));
        green = Self.clamp(percentKelvin <= 66 ? (99.4708025861 * log(percentKelvin) - 161.1195681661) : 288.1221695283 * pow(percentKelvin, -0.0755148492));
        blue =  Self.clamp(percentKelvin >= 66 ? 255 : (percentKelvin <= 19 ? 0 : 138.5177312231 * log(percentKelvin - 10) - 305.0447927307));

        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    private static func clamp(_ value: CGFloat) -> CGFloat {
        return value > 255 ? 255 : (value < 0 ? 0 : value);
    }
    
    var hexValue: String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        
        return hexString
     }
}

