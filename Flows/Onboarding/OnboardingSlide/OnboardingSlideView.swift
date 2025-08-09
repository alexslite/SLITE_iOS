//
// OnboardingSlideView.swift
// Slite
//
// Created by Efraim Budusan on 25.01.2022.
//
//

import Foundation
import SwiftUIX
import SwiftUI

struct OnboardingSlide {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var nextButtonCallback: () -> Void
        
        var body: some View {
            ZStack(alignment: .trailing) {
                content
                Rectangle()
                    .fill(viewModel.item.nextButtonColor)
                    .frame(width: 8, height: UIScreen.main.bounds.height, alignment: .trailing)
            }
        }
        
        var content: some View {
            VStack(spacing: 0) {
                Text(viewModel.item.title)
                    .multilineTextAlignment(.leading)
                    .font(.Main.bold(size: 28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                Text(viewModel.item.description)
                    .multilineTextAlignment(.leading)
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, viewModel.item == OnboardingSlide.allSlides.first ? 50 : 34)
                Buttons.FilledRoundedButton(title: "Let there be light!") {
                    viewModel.onCTA.send()
                }
                .opacity(viewModel.item == OnboardingSlide.allSlides.last ? 1.0 : 0.0)
                .overlay({
                    if viewModel.index < viewModel.pageCount - 1 {
                        HStack {
                            PageControlView(count: viewModel.pageCount, selectedIndex: viewModel.index)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Rectangle()
                                .fill(viewModel.item.nextButtonColor)
                                .frame(width: 48, height: 48, alignment: .trailing)
                                .onTapGesture {
                                    nextButtonCallback()
                                }
                                .overlay(Image("forward"))
                        }
                    }
                })
                .padding(.bottom, 50 + UIWindow.safeAreaPadding(from: .bottom))
            }
            .padding(.leading, 24)
            .padding(.trailing, 8)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background {
                viewModel.item.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    struct PageControlView: View {
        
        let count: Int
        let selectedIndex: Int
        
        var body: some View {
            HStack(spacing: 6) {
                ForEach(0..<count) { index in
                    if index == selectedIndex {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    } else {
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        
        
    }
}
