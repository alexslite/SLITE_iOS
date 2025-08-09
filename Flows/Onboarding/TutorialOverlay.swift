//
//  TutorialOverlay.swift
//  Slite
//
//  Created by Paul Marc on 11.03.2022.
//

import Foundation
import SwiftUI
import SwiftUIX

struct TutorialOverlay: View {
    
    var backgroundImage: UIImage?
    var buttonTapCallback: (() -> Void)?
    
    private let buttonWidthHeight: CGFloat = 68
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let backgroundImage = backgroundImage?.cgImage {
                Image(cgImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 4)
            }
            
            Color(UIColor.black.withAlphaComponent(0.7))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack(alignment: .center) {
                Circle()
                    .strokeBorder(Color.red,lineWidth: 12)
                    .frame(width: buttonWidthHeight, height: buttonWidthHeight)
                Image("navigation_plus")
                    .renderingMode(.template)
                    .foregroundColor(.primaryForeground)
                    .frame(width: buttonWidthHeight, height: buttonWidthHeight)
                    .onTapGesture {
                        buttonTapCallback?()
                    }
            }
            .padding(.top, UIApplication.topSafeAreaHeight)
            .padding(.trailing, 40)
            
            HStack {
                Text(Texts.Onboarding.addLightTutorialTitle)
                    .font(Font.Main.bold(size: 19))
                Image("arrow")
                    .padding(.trailing, 5)
            }.padding(.top, UIApplication.topSafeAreaHeight + buttonWidthHeight)
                .padding(.trailing, buttonWidthHeight)
        }
    }
}
