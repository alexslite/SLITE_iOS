//
//  SaveScenePopUp.swift
//  Slite
//
//  Created by Paul Marc on 23.05.2022.
//

import Foundation
import SwiftUI

struct SaveScenePopUp: View {
    var body: some View {
        VStack {
            Text(Texts.SaveScenePopUp.title)
                .frame(alignment: .center)
                .foregroundColor(.white)
                .font(Font.Main.bold(size: 18))
                .padding(.all, 16)
            Text(Texts.SaveScenePopUp.description)
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(Font.Main.regular(size: 15))
                .padding([.horizontal, .bottom], 24)
            
            Button(action: {
                
            }, label: {
                ZStack {
                    Text(Texts.SaveScenePopUp.ok)
                        .foregroundColor(.white)
                        .font(.Main.regular(size: 15))
                }
            })
            .frame(.init(.init(width: 100, height: 50)))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.sonicSilver, lineWidth: 1))
            .padding(.bottom, 24)
        }
        .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondaryBackground))
    }
}
