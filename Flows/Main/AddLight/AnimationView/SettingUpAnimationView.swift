//
//  SettingUpAnimationView.swift
//  Slite
//
//  Created by Paul Marc on 17.03.2022.
//

import Foundation
import SwiftUI
import Lottie

struct SettingUpAnimationView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<SettingUpAnimationView>) -> UIView {
        let view = UIView(frame: .zero)

        let animation = Animation.named("setting_up_spinner")!
        let animationView = AnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                     animationView.widthAnchor.constraint(equalTo: view.widthAnchor)])
        
        
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<SettingUpAnimationView>) {
    }
}
