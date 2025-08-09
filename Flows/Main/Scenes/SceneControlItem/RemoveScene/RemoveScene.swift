//
//  RemoveScene.swift
//  Slite
//
//  Created by Paul Marc on 05.05.2022.
//

import UIKit
import SwiftUI

struct RemoveScene {
    struct ContentView: View {
        
        var scene: Scene
        var confirmCallback: (() -> Void)?
        var dismissCallback: (() -> Void)?
        
        var body: some View {
            VStack {
                Text(Texts.RemoveScene.title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                Text(Texts.RemoveScene.descriptionFor(scene.name))
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                Buttons.FilledRoundedButton(title: Texts.RemoveScene.remove) {
                    confirmCallback?()
                }.padding(.bottom, 8)
                Buttons.FilledRoundedButton(title: Texts.RemoveScene.cancel, fillColor: .black) {
                    dismissCallback?()
                }.padding(.bottom, 24)
            }.padding(.all, 16)
        }
    }
}
