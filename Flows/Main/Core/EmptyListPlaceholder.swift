//
//  ListPlaceholder.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import SwiftUIX

extension Core {
    
    struct EmptyListPlaceholder: View {

        let title: String
        let subtitle: String
        
        var body: some View {
            VStack {
                Image("empty_slite_glyph")
                    .renderingMode(.template)
                    .foregroundColor(.tertiaryForegorund)
                    .padding(.bottom, 24)
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(.secondaryForegorund)
                    .padding(.bottom, 8)
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.secondaryForegorund)
            }
        }
    }
    
    struct SettingsOverlay: View {
        
        let title: String
        let onSettingsPressed: () -> Void
        
        var body: some View {
            ZStack {
                VStack(alignment: .center) {
                    Image("no_device")
                        .renderingMode(.template)
                        .foregroundColor(.tertiaryForegorund)
                        .padding(.bottom, 24)
                    Text(title)
                        .multilineTextAlignment(.center)
                        .font(.Main.regular(size: 19))
                        .foregroundColor(.secondaryForegorund)
                        .padding(.bottom, 8)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            Buttons.FilledRoundedButton(title: Texts.SettingsOverlay.buttonTitle) {
                onSettingsPressed()
            }
            .padding([.horizontal, .bottom], 24)
            .frame(alignment: .bottom)
        }
    }
}
