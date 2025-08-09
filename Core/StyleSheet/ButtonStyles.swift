//
//  ButtonStyles.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import SwiftUI

struct ButtonStyles {
    
    struct FilledRounded: ButtonStyle {
        
        let fillColor: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.white)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
                .font(.Main.medium(size: 15))
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 14, trailing: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(fillColor)
                )
        }
    }
}
