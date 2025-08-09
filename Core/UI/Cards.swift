//
//  Cards.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit
import SwiftUIX


public struct VibrantBlurBackgroundView: UIViewRepresentable {

    public init() {
        
    }

    public func makeUIView(context: Context) -> UIView {
        
        let view = UIView()
        let blurView = UIVisualEffectView(effect: blur)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurView)
        view.addSubview(vibrancyView)
        
        vibrancyView.backgroundColor = UIColor.primaryBackground.withAlphaComponent(0.5)
        
        blurView.constrainAllMargins(with: view)
        vibrancyView.constrainAllMargins(with: view)
        
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {

    }
    
    var blur: UIBlurEffect {
        if UIWindow.appKeyWindow?.traitCollection.userInterfaceStyle == .light {
            return UIBlurEffect(style: .light)
        } else {
            return UIBlurEffect(style: .dark)
        }
    }
    
    var vibrancy: UIVisualEffect {
        return UIVibrancyEffect(blurEffect: blur, style: .fill)
    }
}
