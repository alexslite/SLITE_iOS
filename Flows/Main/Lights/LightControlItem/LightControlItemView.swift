//
// LightControlItemView.swift
// Slite
//
// Created by Efraim Budusan on 07.02.2022.
//
//

import Foundation
import SwiftUI
import Combine
import SwiftUIX
import CoreMedia


struct LightControlItem {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        @Binding var isExpanded: Bool
        var backgroundColor: Color
        var titleColor: Color?
        
        @State var swipeState: SwipeState = .programatic(false)
        
        var isExpandable: Bool = true
        
        var onShowSettings: (() -> Void) = { }
        var onRename: (() -> Void) = { }
        var onRemove: (() -> Void) = { }
        var onTapDisconnectedLight: (() -> Void) = { }
        var onStateChanged: (() -> Void) = { }
        
        var light: LightData {
            return viewModel.base.data
        }
        var shouldExpand: Bool {
            isExpandable && light.state == .turnedOn
        }
        
        var body: some View {
            VStack(spacing: 0) {
                baseContent
                    .background(RoundedRectangle(cornerRadius: 5).fill(backgroundColor))
                    .addSwipe(state: $swipeState, maxDragDistance: isExpanded ? 0 : 148, onTap: {
                        
                    }, background: {
                        slideButtons
                    })
                if isExpanded && shouldExpand {
                    expandedContent
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                }
            }
            .background(RoundedRectangle(cornerRadius: 5)
                            .fill(shouldExpand ? Color.eerieBlack : Color.primaryBackground)
            )
        }
        
        var baseContent: some View {
            HStack(alignment: .top, spacing: 0) {
                colorView
                    .padding(EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24))
                centerContentView
                    .padding(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 8))
                expandIcon
//                    .padding(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
            }
        }
        
        var expandedContent: some View {
            VStack(spacing: 0) {
                if light.mode == .whiteWithTemperature {
                    brightnessSlider
                        .padding(.bottom, 16)
                    temperatureSlider
                        .padding(.bottom, 16)
                } else if light.mode == .color {
                    brightnessSlider
                        .padding(.bottom, 16)
                    hueSlider
                        .padding(.bottom, 16)
                }
                Color.primaryBackground
                    .frame(height: 2)
                settingsButton
            }
        }
        
        var settingsButton: some View {
            Button(action: {
                onShowSettings()
            }) {
                HStack {
                    Image("lights_adjustments")
                        .frame(width: 30, height: 48)
                    
                    Text("Settings")
                        .font(Font.Main.regular(size: 15))
                        .foregroundColor(.white)
                }
                .maxWidth(.infinity)
                .contentShape(Rectangle())
            }
        }
        
        var colorView: some View {
            light.state.powerImage
                .renderingMode(.template)
                .foregroundColor(light.state.powerImageForegroundColor)
                .frame(width: 40, height: 40)
                .background(Circle()
                    .fill(light.state.powerImageBackground(colorGradient: viewModel.base.powerButtonGradient)))
                .onTapGesture {
                    isExpanded = false
                    guard light.state != .disconnected else {
                        onTapDisconnectedLight()
                        return
                    }
                    viewModel.base.data.onOffToggle()
                    
                    onStateChanged()
                }
        }
        
        var centerContentView: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(light.name)
                    .foregroundColor(titleColor != nil ? titleColor : (shouldExpand ? .primaryForeground : .secondaryForegorund))
                    .font(Font.Main.bold(size: 19))
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading )
                statusView
            }
        }
        
        var statusView: some View {
            HStack(spacing: 8) {
                Text(viewModel.base.subtitle)
                    .font(Font.Main.regular(size: 13))
                    .foregroundColor(.secondaryForegorund)
                    .lineLimit(0)
            }
        }
        
        var expandIcon: some View {
            ZStack {
                Image(shouldExpand ? "chevron_dropdown" : "core_options")
                    .renderingMode(.template)
                    .foregroundColor(.secondaryForegorund)
                    .rotationEffect(Angle(degrees: isExpanded ? 180 : 0))
                    .animation(.easeInOut, value: isExpanded)
                    .frame(width: 61)
                    .frame(maxHeight: .infinity)
                RoundedRectangle(cornerRadius: 5)
//                    .fill(Color.white.opacity(0.1))
                    .frame(maxWidth: 61, maxHeight: 100)
                    .opacity(0.001)
                    .layoutPriority(-1)
                    .onTapGesture {
                        guard shouldExpand else {
//                            if light.state == .disconnected {
//                                onTapDisconnectedLight()
//                            }
                            swipeState = swipeState.toggle
                            return
                        }
                        withAnimation(.easeInOut) {
                            isExpanded = !isExpanded
                            swipeState = .programatic(false)
                        }
                    }
            }
        }
        
        var slideButtons: some View {
            HStack(spacing: 2) {
                Button(action: {
                    onRename()
                }) {
                    VStack {
                        Image("core_edit")
                        Text("Rename")
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 72)
                    .frame(maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.midnightGreen))
                }
                Button(action: {
                    onRemove()
                }) {
                    VStack {
                        Image("core_remove")
                        Text("Remove")
                            .font(.Main.regular(size: 13))
                            .foregroundColor(.white)
                    }
                    .frame(width: 72)
                    .frame(maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.tartRed))
                }
            }
            .padding(.leading, 2)
        }


    }

}

extension LightControlItem {
    
    class ViewModel: AnyObservableObject {
        
        var base: LightControlViewModel
        
        init(_ light: LightControlViewModel) {
            self.base = light
            super.init(base: light)
        }
    }
}

extension LightControlItem.ContentView {
    struct HueSlider: View {
        @Binding var progress: CGFloat
        @Binding var saturation: CGFloat
        let knobImage: Image
        
        var body: some View {
            THueSlider(progress: $progress, saturation: $saturation, knobImage: knobImage).frame(alignment: .center)
                .padding(.horizontal, 24)
        }
    }
}

extension LightControlItem.ContentView {
    
    struct TemperatureSlider: View {
        @Binding var progress: CGFloat
        let title: String
        let knobImage: Image
        var endColor: Color?
        
        var body: some View {
            HStack(spacing: 4) {
                Text(title)
                    .font(Font.Main.regular(size: 13))
                    .foregroundColor(.primaryForeground)
                    .frame(width: 45, alignment: .leading)
                SteppedSlider(progress: $progress, knobImage: knobImage, endColor: endColor, slidingValue: 8000, step: 100, onGestureEnded: {
                    #warning("Add tracking event")
                })
            }
            .padding(.horizontal, 24)
        }
    }
    
    struct Slider: View {
        
        @Binding var progress: CGFloat
        let title: String
        let knobImage: Image
        var endColor: Color?
        
        var body: some View {
            HStack(spacing: 4) {
                Text(title)
                    .font(Font.Main.regular(size: 13))
                    .foregroundColor(.primaryForeground)
                    .frame(width: 45, alignment: .leading)
                TSlider(progress: $progress, knobImage: knobImage, endColor: endColor, onGestureEnd: {
                    #warning("add track event")
                })
            }
            .padding(.horizontal, 24)
        }
    }
    
    var brightnessSlider: some View {
        Slider(progress: .init(get: {
            return light.brightnessPercentage
        }, set: { newValue in
//            viewModel.base.brightness.set(percentage: newValue)
            viewModel.base.setBrightnessFromUserAction(percentage: newValue)
        }), title: "\(light.brightnessLevel)%", knobImage: Image("lights_brightness"))
    }
    
    var temperatureSlider: some View {
        TemperatureSlider(progress: .init(get: {
            return light.temperaturePercentage
        }, set: { newValue in
//            viewModel.base.temperature.set(percentage: newValue)
            viewModel.base.setTemperatureFromUserAction(percentage: newValue)
        }), title: "\(light.temperatureLevel)K", knobImage: Image("lights_temperature"))
    }
    
    var saturationSlider: some View {
        Slider(progress: .init(get: {
            return light.saturationPercentage
        }, set: { newValue in
//            viewModel.base.saturation.set(percentage: newValue)
            viewModel.base.setSaturationFromUserAction(percentage: newValue)
        }), title: "\(Int(light.saturationLevel))%", knobImage: Image("light_saturation"), endColor: light.color)
    }
    
    var hueSlider: some View {
        HueSlider(progress: .init(get: {
            return light.huePercentage
        }, set: { newValue in
//            viewModel.base.hue.set(percentage: newValue)
            viewModel.base.setHueFromUserAction(percentage: newValue)
        }), saturation: .init(get: {
            return light.saturationPercentage
        }, set: { _ in
            
        }), knobImage: Image("light_saturation"))
    }
}


