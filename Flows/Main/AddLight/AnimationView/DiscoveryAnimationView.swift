//
//  DiscoveryLottieAnimation.swift
//  Slite
//
//  Created by Paul Marc on 14.03.2022.
//

import Foundation
import SwiftUI
import Lottie

struct DiscoveryAnimationView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<DiscoveryAnimationView>) -> UIView {
        let view = UIView(frame: .zero)

        let animation = Animation.named("pulse-background")!
        let animationView = AnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.play(fromFrame: animation.startFrame + 20, toFrame: animation.endFrame - 18, loopMode: .loop, completion: nil)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                     animationView.widthAnchor.constraint(equalTo: view.widthAnchor)])
        
        
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<DiscoveryAnimationView>) {
    }
}
