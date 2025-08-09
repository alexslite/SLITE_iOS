//
//  SectionControlView.swift
//  Slite
//
//  Created by Paul Marc on 05.04.2022.
//

import UIKit
import SwiftUI

struct SectionControlView: View {
    
    var turnOffAction: (() -> Void)?
    var turnOnAction: (() -> Void)?
    
    var body: some View {
        baseContent
            .cornerRadius(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.bottom, .horizontal], 24)
        
    }
    
    var turnOn: some View {
        HStack(alignment: .center) {
            Button(action: {
                turnOnAction?()
            }, label: {
                Image("lights_power")
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.tartRed))
                    .padding(.trailing, 24)
            })
            
            Text("Turn\nOn All")
                .font(.Main.medium(size: 15))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var turnOff: some View {
        HStack(alignment: .center) {
            Button(action: {
                turnOffAction?()
            }) {
                Image("lights_power")
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.sonicSilver))
                    .padding(.trailing, 24)
            }
            
            Text("Turn\nOff All")
                .font(.Main.medium(size: 15))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    
    var baseContent: some View {
        HStack(alignment: .center, spacing: 0) {
            turnOn
                .padding(.all, 24)
            turnOff
                .padding(.all, 24)
        }
        .background(RoundedRectangle(cornerRadius: 5)
                        .fill(Color.eerieBlack)
        )
    }
}
