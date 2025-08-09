//
//  LightDetailsColorTabView.swift
//  Slite
//
//  Created by Efraim Budusan on 21.02.2022.
//

import Foundation
import SwiftUIX
import SwiftUI

extension LightDetails {
    
    struct ColorTabView: View {
        
        @EnvironmentObject var viewModel: LightDetails.LightDetailsViewModel
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    brightnessSlider
                        .padding(.bottom, 8)
                    saturationSlider
                        .padding(.bottom, 8)
                    ColourWheel(radius: 247, rgbColour: .init(get: {
                        viewModel.hsv.rgb
                    }, set: { newValue in
                        viewModel.setRGB(newValue: newValue)
                    }), brightness: viewModel.displayColorBrightness)
                    .frame(width: 247, height: 247)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        HStack {
                            cameraButton
                            Spacer()
                            hexButton
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    .padding(.bottom, 32)
                }
                .padding(EdgeInsets(top: 3, leading: 24, bottom: 0, trailing: 24))
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.58)
            
        }
        
        var brightnessSlider: some View {
            SliderView(icon: Image("lights_brightness"),
                       title: "\(viewModel.colorBrightnessLevel)%",
                       subtitle: Text("Brightness"),
                       buttons: { EmptyView() },
                       sliderProgress: viewModel.colorBrightness,
                       onGestureEnd: {
                Analytics.shared.trackEvent(.advancedModeColor, properties: [
                    "Brightness value set": "\(viewModel.colorBrightnessLevel)",
                    "Saturation value set": "\(viewModel.saturationLevel)",
                    "Hue value set": "\(viewModel.light.data.hue)"
                ])
            })
        }
        
        
        var saturationSlider: some View {
            SliderView(icon: Image("light_saturation"), title: "\(viewModel.saturationLevel)%", subtitle: Text("Saturation"), buttons: {
                EmptyView()
            }, sliderProgress: .init(get: {
                viewModel.hsv.s
            }, set: { newValue in
                viewModel.setSaturation(newValue: newValue)
            }),
                       onGestureEnd: {
                Analytics.shared.trackEvent(.advancedModeColor, properties: [
                    "Brightness value set": "\(viewModel.colorBrightnessLevel)",
                    "Saturation value set": "\(viewModel.saturationLevel)",
                    "Hue value set": "\(viewModel.light.data.hue)"
                ])
            },
                       endColor: viewModel.hsv.rgb.color)
        }
        
        var cameraButton: some View {
            Button {
                viewModel.cameraInput.send()
                Analytics.shared.trackEvent(.cameraColorPicker)
            } label: {
                Image("lights_camera")
                    .renderingMode(.template)
                    .foregroundColor(.primaryForeground)
                    .frame(width: 32, height: 32)
                    .background(Circle().stroke(Color.primaryForeground, lineWidth: 1))
                    .background(Circle().fill(Color.secondaryBackground))
            }
            .buttonStyle(PlainButtonStyle())
            
            
        }
        
        var hexButton: some View {
            Button {
                viewModel.hexAction()
            } label: {
                Image("lights_hex")
                    .renderingMode(.template)
                    .foregroundColor(.primaryForeground)
                    .frame(width: 32, height: 32)
                    .background(Circle().stroke(Color.primaryForeground, lineWidth: 1))
                    .background(Circle().fill(Color.secondaryBackground))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
