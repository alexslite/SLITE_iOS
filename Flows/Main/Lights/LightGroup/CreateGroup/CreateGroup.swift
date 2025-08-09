//
//  ContentView.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import SwiftUI

extension CreateGroup {
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                ForEach(viewModel.lightsViewModel.lights.map { $0.data }) { light in
                    LightSelectingView(lightTitle: light.name, isSelected: viewModel.selectionStateFor(light)) { state in
                        viewModel.update(state, for: light)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.all, 24)
            .listStyle(.automatic)
            if viewModel.shouldShowNextButton {
                Buttons.FilledRoundedButton(title: Texts.Core.next) {
                    viewModel.onNext.send()
                }
                .padding(.all, 24)
            }
        }
    }
    
    struct LightSelectingView: View {
        
        var lightTitle: String
        var isSelected: Bool
        var selectionCallback: (Bool) -> Void
        
        var body: some View {
            content
        }
        
        var content: some View {
            HStack {
                Button(action: {
                    selectionCallback(!isSelected)
                }, label: {
                    HStack {
                        Image(isSelected ? "selected" : "unselected")
                            .padding([.vertical, .leading], 24)
                        Text(lightTitle)
                            .foregroundColor(.white)
                            .font(Font.Main.bold(size: 19))
                            .padding(.all, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                })
            }
            .frame(maxWidth: .infinity)
            .background(.eerieBlack)
            .cornerRadius(5)
        }
    }
}
