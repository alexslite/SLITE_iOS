//
//  LightView.swift
//  Slite
//
//  Created by Paul Marc on 15.03.2022.
//

import Foundation
import SwiftUI

struct LightView: View {
    
    var lightTitle: String
    var tapCallback: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: {
                tapCallback?()
            }, label: {
                Text(lightTitle)
                    .foregroundColor(.white)
                    .font(Font.Main.bold(size: 19))
                    .padding(.all, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Image("lightView_next")
                    .padding(.trailing, 28)
                    .width(8)
            })
        }
        .frame(maxWidth: .infinity)
        .background(.eerieBlack)
        .cornerRadius(5)
    }
}

struct LightView_Preview: PreviewProvider {
    static var previews: some View {
        LightView(lightTitle: "Light_1")
    }
}
