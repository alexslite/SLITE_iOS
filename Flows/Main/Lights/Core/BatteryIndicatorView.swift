//
//  BatteryIndicatorView.swift
//  Slite
//
//  Created by Efraim Budusan on 02.02.2022.
//

import SwiftUI

struct BatteryIndicatorView: View {
    
    let level: Int
    var fullCount: Int = 4
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<fullCount) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < fullCount - 1 ? Color(hexadecimal6: 0x40EF65) : Color.clear)
                    .frame(width: 2, height: 6)
            }
        }
        .padding(.all, 2)
        .background {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.secondaryForegorund, lineWidth: 1)
        }
    }
}

