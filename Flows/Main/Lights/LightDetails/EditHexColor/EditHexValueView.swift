//
// EditHexValueView.swift
// Slite
//
// Created by Efraim Budusan on 28.01.2022.
//
//

import Foundation
import SwiftUIX
import SwiftUI


struct EditHexValue {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                Text("Type Hex Color Code")
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                Core.LabeledInputContainer(label: "Color Code",
                                           textField: textField,
                                           prefix: "#",
                                           borderColor: viewModel.isValid ? .sonicSilver : .tartRed) { textField in
                    if self.viewModel.textField == nil {
                        textField.becomeFirstResponder()
                        self.viewModel.textField = textField
                    }
                }
                .onTapGesture {
                    self.viewModel.textField?.becomeFirstResponder()
                }
                .padding(.bottom, 20)
                
                if !viewModel.isValid {
                    Text(Texts.EditHex.invalidHint)
                        .font(Font.Main.regular(size: 15))
                        .foregroundColor(.tartRed)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Buttons.FilledRoundedButton(title: "Use") {
                    viewModel.onFinishedInteraction.send(viewModel.hexValue)
                }
                .disabled(!viewModel.isValid)
                .opacity(viewModel.isValid ? 1 : 0.5)
            }
            .padding(.all, 16)
        }
         
        var textField: CocoaTextField<Text> {
            return CocoaTextField<Text>.init("", text: $viewModel.hexValue, onCommit: {
                viewModel.onFinishedInteraction.send(viewModel.hexValue)
            })
            .returnKeyType(.done)
            .autocapitalization(.allCharacters)
            .placeholder("Enter Custom HEX Code")
            
        }
    }
}


extension EditHexValue {
    

    
}
