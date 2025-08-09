//
//  ListHeaderView.swift
//  Slite
//
//  Created by Efraim Budusan on 02.02.2022.
//

import SwiftUI

struct ListHeaderView: View {
    
    let title: String
    let isExpanded: Bool
    let action: () -> Void
     
    var body: some View {
//        Button(action: action) {
//
//        }
//        .buttonStyle(PlainButtonStyle())
//        .disabled(true)
        HStack {
//                Image("chevron_dropdown")
//                    .renderingMode(.template)
//                    .foregroundColor(.secondaryForegorund)
//                    .rotationEffect(Angle(degrees: isExpanded ? 0 : -90))
//                    .animation(.easeInOut, value: isExpanded)
            Text(title)
                .font(.Main.regular(size: 15))
                .foregroundColor(Color.secondaryForegorund)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 24)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .background(Color.primaryBackground)
    }
}
