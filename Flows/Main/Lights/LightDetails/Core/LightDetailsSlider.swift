//
//  LightDetailsSlider.swift
//  Slite
//
//  Created by Efraim Budusan on 11.02.2022.
//

import Foundation
import SwiftUIX
import SwiftUI

extension LightDetails {
    
    struct SliderView<Content: View>: View {
        
        var icon: Image
        var title: String
        var subtitle: Text
        @ViewBuilder var buttons: () -> Content
        var sliderProgress: Binding<CGFloat>
        var onGestureEnd: () -> Void
        var endColor: Color? = nil
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    icon
                        .frame(width: 40, alignment: .topLeading)
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.Main.bold(size: 19))
                            .foregroundColor(.primaryForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        subtitle
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.secondaryForegorund)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.bottom, 6)
            .animation(nil)
            TSlider(progress: sliderProgress, knobImage: Image(""), endColor: endColor, knobHeight: 32, onGestureEnd: onGestureEnd)
                .padding(.bottom, 16)
            buttons()
        }
    }
    
    struct TemperatureSliderView<Content: View>: View {
        
        var icon: Image
        var title: String
        var subtitle: Text
        @ViewBuilder var buttons: () -> Content
        var sliderProgress: Binding<CGFloat>
        var endColor: Color? = nil
        var onGestureEnded: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    icon
                        .frame(width: 40, alignment: .topLeading)
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.Main.bold(size: 19))
                            .foregroundColor(.primaryForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        subtitle
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.secondaryForegorund)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.bottom, 6)
            .animation(nil)
            SteppedSlider(progress: sliderProgress, knobImage: Image(""), endColor: endColor, slidingValue: 8000, step: 100, knobHeight: 32, onGestureEnded: {
                onGestureEnded()
            })
                .padding(.bottom, 16)
            buttons()
        }
    }
}


