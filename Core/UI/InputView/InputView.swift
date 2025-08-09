//
//  InputView.swift
//  Slite
//
//  Created by Efraim Budusan on 28.01.2022.
//

import Foundation
import Introspect
import SwiftUIX

extension Core {

    struct LabeledInputContainer: View {
        
        let label: String
        let textField: CocoaTextField<Text>
        var prefix: String?
        var borderColor: Color = .sonicSilver
        
        var introspect: ((UITextField) -> ())?
        
        var body: some View {
            VStack(spacing: 6) {
                Text(label)
                    .font(.Main.regular(size: 11))
                    .foregroundColor(Color.sonicSilver)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 4) {
                    if let prefix = prefix {
                        Text(prefix)
                            .font(.Main.regular(size: 15))
                            .foregroundColor(Color.primaryForeground)
                    }
                    textField
                        .placeholderTextColor(Color.sonicSilver)
                        .font(.Main.regular(size: 15))
                        .foregroundColor(Color.primaryForeground)
                        .cursorTintColor(Color.tartRed)
                        .frame(height: 16)
                    .introspectTextField { textField in
                        introspect?(textField)
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 8))
            .background(RoundedRectangle(cornerRadius: 3).stroke(borderColor, lineWidth: 1))
        }
    }
}
