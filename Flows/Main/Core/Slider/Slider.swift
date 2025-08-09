//
//  Slider.swift
//  Slite
//
//  Created by Efraim Budusan on 03.02.2022.
//

import SwiftUIX
import SwiftUI

struct THueSlider: View {
    @Binding var progress: CGFloat
    @Binding var saturation: CGFloat
    let knobImage: Image
    
    var knobHeight: CGFloat = 32
    
    var colors: [Color] {
        let hueValues = Array(1...360)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 360.0 ,
                          saturation: saturation,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            knob
                .gesture(dragGesture(sliderWidth: proxy.size.width))
                .offset(x: knobPosition(sliderWidth: proxy.size.width), y: 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(rail(sliderWidth: proxy.size.width))
        }
        .frame(height: knobHeight)
    }
    
    var knob: some View {
        knobImage
            .renderingMode(.template)
            .foregroundColor(.primaryForeground)
            .frame(width: knobHeight, height: knobHeight)
            .background(Circle().stroke(Color.primaryForeground, lineWidth: 1))
            .background(Circle().fill(Color.secondaryBackground))
        
    }
    
    func rail(sliderWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .modify(transform: { view in
                    view.fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                })
                .frame(maxWidth: sliderWidth)
                .frame(height: 2)
        }
    }

    func dragGesture(sliderWidth: CGFloat) -> some Gesture {
         DragGesture()
            .onChanged({ value in
                progress = max(min(progress + (value.translation.width / sliderWidth), 1.0), 0.0)
            })
     }
    
    func knobPosition(sliderWidth: CGFloat) -> CGFloat {
        return  progress * (sliderWidth - knobHeight)
    }
    
}

struct TSlider: View {
    
    @Binding var progress: CGFloat
    let knobImage: Image
    var endColor: Color? = nil
    var knobHeight: CGFloat = 32
    var onGestureEnd: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            knob
                .gesture(dragGesture(sliderWidth: proxy.size.width))
                .offset(x: knobPosition(sliderWidth: proxy.size.width), y: 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(rail(sliderWidth: proxy.size.width))
        }
        .frame(height: knobHeight)
    }
    
    var knob: some View {
        knobImage
            .renderingMode(.template)
            .foregroundColor(.primaryForeground)
            .frame(width: knobHeight, height: knobHeight)
            .background(Circle().stroke(Color.primaryForeground, lineWidth: 1))
            .background(Circle().fill(Color.secondaryBackground))
        
    }
    
    func rail(sliderWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.primaryBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
            RoundedRectangle(cornerRadius: 1)
                .modify(transform: { view in
                    if let endColor = endColor {
                        view.fill(LinearGradient(colors: [.primaryForeground, endColor], startPoint: .leading, endPoint: .trailing))
                    } else {
                        view.fill(Color.primaryForeground)
                    }
                })
                .frame(maxWidth: sliderWidth * progress)
                .frame(height: 2)
        }
    }

    func dragGesture(sliderWidth: CGFloat) -> some Gesture {
         DragGesture()
            .onChanged({ value in
                progress = max(min(progress + (value.translation.width / sliderWidth), 1.0), 0.0)
            })
            .onEnded { value in
                progress = max(min(progress + (value.translation.width / sliderWidth), 1.0), 0.0)
                onGestureEnd()
            }
     }
    
    func knobPosition(sliderWidth: CGFloat) -> CGFloat {
        return  progress * (sliderWidth - knobHeight)
    }
    
}

struct SteppedSlider: View {
    
    @Binding var progress: CGFloat
    let knobImage: Image
    var endColor: Color? = nil
    let slidingValue: CGFloat
    let step: CGFloat
    var knobHeight: CGFloat = 32
    var onGestureEnded: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            knob
                .gesture(dragGesture(sliderWidth: proxy.size.width))
                .offset(x: knobPosition(sliderWidth: proxy.size.width), y: 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(rail(sliderWidth: proxy.size.width))
        }
        .frame(height: knobHeight)
    }
    
    var knob: some View {
        knobImage
            .renderingMode(.template)
            .foregroundColor(.primaryForeground)
            .frame(width: knobHeight, height: knobHeight)
            .background(Circle().stroke(Color.primaryForeground, lineWidth: 1))
            .background(Circle().fill(Color.secondaryBackground))
        
    }
    
    func rail(sliderWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.primaryBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
            RoundedRectangle(cornerRadius: 1)
                .modify(transform: { view in
                    if let endColor = endColor {
                        view.fill(LinearGradient(colors: [.primaryForeground, endColor], startPoint: .leading, endPoint: .trailing))
                    } else {
                        view.fill(Color.primaryForeground)
                    }
                })
                .frame(maxWidth: sliderWidth * progress)
                .frame(height: 2)
        }
    }

    func dragGesture(sliderWidth: CGFloat) -> some Gesture {
         DragGesture()
            .onChanged({ value in
                let newProgress = max(min(progress + (value.translation.width / sliderWidth), 1.0), 0.0)
                let newValue = CGFloat(slidingValue) * newProgress
                let stepedValue = round(newValue / step) * step
                
                let steppedProgress = stepedValue / slidingValue
                
                progress = max(min(steppedProgress, 1.0), 0.0)
            })
            .onEnded { _ in
                onGestureEnded()
            }
     }
    
    func knobPosition(sliderWidth: CGFloat) -> CGFloat {
        return  progress * (sliderWidth - knobHeight)
    }
    
}
