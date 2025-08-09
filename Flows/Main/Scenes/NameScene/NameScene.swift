//
//  NameScene.swift
//  Slite
//
//  Created by Paul Marc on 02.05.2022.
//

import UIKit
import SwiftUI
import SwiftUIX

struct NameScene {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                Text(Texts.SaveScene.title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                Text(Texts.SaveScene.description)
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                Core.LabeledInputContainer(label: Texts.SaveScene.sceneName, textField: textField) { textField in
                    if self.viewModel.textField == nil {
                        textField.becomeFirstResponder()
                        self.viewModel.textField = textField
                    }
                }
                .onTapGesture {
                    self.viewModel.textField?.becomeFirstResponder()
                }
                .padding(.bottom, 10)
                
                Buttons.FilledRoundedButton(title: Texts.Core.done) {
                    viewModel.onFinishedInteraction.send(viewModel.sceneName)
                }
                .disabled(!viewModel.saveButtonEnabled)
                .opacity(!viewModel.saveButtonEnabled ? 0.5 : 1)
            }
            .padding(.all, 16)
        }
         
        var textField: CocoaTextField<Text> {
            return CocoaTextField<Text>.init("", text: $viewModel.sceneName, onCommit: {
                guard !viewModel.sceneName.isEmpty else { return }
                viewModel.onFinishedInteraction.send(viewModel.sceneName)
            })
            .returnKeyType(.done)
            .placeholder(Texts.Core.name)
        }
    }
}
