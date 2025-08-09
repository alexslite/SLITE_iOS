//
//  Buttons.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import SwiftUI

struct Buttons {
    
    struct FilledRoundedButton: View {
        
        let title: String
        var isEnabled: Bool = true
        var isLoading: Bool = false
        var fillColor: Color = .tartRed
        let action: () -> Void
        
        var body: some View {
            Button(action: {
                action()
            }, label: {
                Text(title)
            })
            .frame(height: 48)
            .buttonStyle(ButtonStyles.FilledRounded(fillColor: fillColor))
            .disabled(!isEnabled)
            .overlay(
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
                    xSpacer
                    if isLoading {
                        ProgressView()
                            .foregroundColor(.white)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                })
                .padding(.trailing, 24)
            )
        }
        
        var xSpacer: some View {
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                }
            }
        }
    }
}
