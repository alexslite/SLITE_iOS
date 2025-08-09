//
//  NameGroup.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import SwiftUI
import Combine
import SwiftUIX

struct NameGroup {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        let scenesName: [String]
        
        var body: some View {
            VStack(spacing: 0) {
                Text(scenesName.isEmpty ? Texts.CreateGroup.popUpTitle : Texts.CreateGroup.popUpTitleWarning)
                    .font(.Main.bold(size: 19))
                    .foregroundColor(Color.primaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                    .multilineTextAlignment(.center)
                
                if !scenesName.isEmpty {
                    Text(Texts.CreateGroup.descriptionWarning)
                        .font(.Main.regular(size: 15))
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    ForEach(scenesName, id: \.self) { name in
                        Text("• \(name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.Main.regular(size: 15))
                            .padding(.horizontal, 24)
                    }
                }
                
                Core.LabeledInputContainer(label: Texts.Core.name, textField: textField) { textField in
                    if self.viewModel.textField == nil {
                        textField.becomeFirstResponder()
                        self.viewModel.textField = textField
                    }
                }
                .onTapGesture {
                    self.viewModel.textField?.becomeFirstResponder()
                }
                .padding(.vertical, 10)
                
                Text(Texts.CreateGroup.groupNameHint)
                    .font(Font.Main.regular(size: 15))
                    .foregroundColor(.sonicSilver)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Buttons.FilledRoundedButton(title: scenesName.isEmpty ? Texts.Core.done : Texts.CreateGroup.buttonTitleWarning) {
                    viewModel.onFinishedInteraction.send(viewModel.groupName)
                }
                .padding(.top, 12)
                .disabled(viewModel.groupName.isEmpty)
                .opacity(viewModel.groupName.isEmpty ? 0.5 : 1)
            }
            .padding(.all, 16)
        }
         
        var textField: CocoaTextField<Text> {
            return CocoaTextField<Text>.init("", text: $viewModel.groupName, onCommit: {
                guard !viewModel.groupName.isEmpty else { return }
                viewModel.onFinishedInteraction.send(viewModel.groupName)
            })
            .returnKeyType(.done)
            .placeholder(Texts.Core.name)
        }
    }
}
