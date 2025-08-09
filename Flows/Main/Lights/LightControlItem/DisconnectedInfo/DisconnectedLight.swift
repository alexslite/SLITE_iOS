//
//  DisconnectedPopUp.swift
//  Slite
//
//  Created by Paul Marc on 05.04.2022.
//

import UIKit
import SwiftUI

struct DisconnectedLight {
    
    struct ContentView: View {
        
        var reconnectCallback: (() -> Void)
        
        var body: some View {
            Text(Texts.Disconnected.title)
                .font(.Main.bold(size: 19))
                .foregroundColor(.primaryForeground)
                .padding(.all, 16)
                .frame(alignment: .center)
            Text(Texts.Disconnected.bullets)
                .font(.Main.regular(size: 15))
                .foregroundColor(.primaryForeground)
                .padding([.horizontal], 24)
                .padding(.bottom, 40)
                .multilineTextAlignment(.leading)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Buttons.FilledRoundedButton(title: "Reconnect") {
                reconnectCallback()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
    }
}
