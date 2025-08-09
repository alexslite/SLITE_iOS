//
//  RenameScene.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import Foundation
import SwiftUI
import Combine
import SwiftUIX

struct RenameScene {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                Text(Texts.RenameScene.title)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                Core.LabeledInputContainer(label: Texts.Core.name, textField: textField) { textField in
                    if self.viewModel.textField == nil {
                        textField.becomeFirstResponder()
                        self.viewModel.textField = textField
                    }
                }
                .onTapGesture {
                    self.viewModel.textField?.becomeFirstResponder()
                }
                .padding(.bottom, 10)
                
                Text(Texts.EditName.sliteNameHint)
                    .font(Font.Main.regular(size: 15))
                    .foregroundColor(.sonicSilver)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Buttons.FilledRoundedButton(title: Texts.Core.done) {
                    viewModel.onFinishedInteraction.send(viewModel.sceneName)
                }
                .disabled(viewModel.sceneName.isEmpty)
                .opacity(viewModel.sceneName.isEmpty ? 0.5 : 1)
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
