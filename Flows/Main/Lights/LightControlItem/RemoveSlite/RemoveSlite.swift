//
//  RemoveSlite.swift
//  Slite
//
//  Created by Paul Marc on 01.04.2022.
//

import UIKit
import SwiftUI

struct RemoveSlite {
    struct ContentView: View {
        
        var light: LightData
        var isGroup: Bool
        var scenesName: [String]
        var confirmCallback: (() -> Void)?
        var dismissCallback: (() -> Void)?
        
        var body: some View {
            VStack {
                Text(isGroup ? Texts.RemoveGroup.title : Texts.RemoveLight.title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                Text(isGroup ? Texts.RemoveGroup.descriptionFor(groupName: light.name) : Texts.RemoveLight.descriptionFor(lightName: light.name))
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .multilineTextAlignment(.center)
                
                if !scenesName.isEmpty {
                    Text(Texts.RemoveLight.sceneRemoveTitle)
                        .font(.Main.regular(size: 15))
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    ForEach(scenesName, id: \.self) { name in
                        Text("• \(name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.Main.regular(size: 15))
                            .padding(.horizontal, 24)
                    }
                }
                
                Buttons.FilledRoundedButton(title: isGroup ? Texts.RemoveGroup.remove : Texts.RemoveLight.remove) {
                    confirmCallback?()
                }.padding(.bottom, 8)
                    .padding(.top, 12)
                Buttons.FilledRoundedButton(title: Texts.RemoveLight.cancel, fillColor: .black) {
                    dismissCallback?()
                }.padding(.bottom, 24)
            }.padding(.all, 16)
        }
    }
}
