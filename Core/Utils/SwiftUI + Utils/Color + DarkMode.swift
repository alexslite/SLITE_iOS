//
//  Color + Extension.swift
//  Wellory
//
//  Created by Efraim Budusan on 11.10.2021.
//  Copyright © 2021 Wellory. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import SwiftUIX

extension UIColor {
    convenience init(
        light lightModeColor: @escaping @autoclosure () -> UIColor,
        dark darkModeColor: @escaping @autoclosure () -> UIColor
     ) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
        }
    }
}


extension Color {
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        if #available(iOS 14.0, *) {
            self.init(UIColor(
                light: UIColor(lightModeColor()),
                dark: UIColor(darkModeColor())
            ))
        } else {
            self.init(UIColor(
                        light: lightModeColor().toUIColor() ?? .green,
                      dark: darkModeColor().toUIColor() ?? .green)
            )
        }
    }
}
