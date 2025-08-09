//
//  HomeNavigationBar.swift
//  Slite
//
//  Created by Efraim Budusan on 24.01.2022.
//

import Foundation
import SwiftUIX
import Introspect

final class ButtonStateHelper: ObservableObject {
    @Published var isSpinning: Bool = false {
        didSet {
            if isSpinning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [unowned self] in
                    withAnimation {
                        self.isSpinning = false
                    }
                }
            }
        }
    }
}

struct Core {
    
    struct LargeTitleNavigationBar: View {
        
        @EnvironmentObject var helper: ButtonStateHelper
        
        let title: String
        let showReconnect: Bool
        let showOptions: Bool
        let onAdd: () -> Void
        let onRefresh: () -> Void
        let onOptions: () -> Void
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.Main.bold(size: 28))
                    .foregroundColor(.primaryForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 0))
                
                if showReconnect {
                    refreshButton
                }
                
                Button(action: onAdd) {
                    Image("navigation_plus")
                        .renderingMode(.template)
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 45)
                
                if showOptions {
                Button(action: onOptions) {
                    Image("core_options")
                        .renderingMode(.template)
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 45)
                }
            }
            .frame(height: 68)
            // Not same as design - keeping it for now
            .background {
                VibrantBlurBackgroundView()
                    .edgesIgnoringSafeArea(.all)
            }
        }
        
        var refreshButton: some View {
            Button(action: {
                onRefresh()
                helper.isSpinning = true
            }, label: {
                if helper.isSpinning {
                    ActivityIndicator()
                } else {
                    Image("refresh")
                        .renderingMode(.template)
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fill)
                }
            })
            .frame(width: 45)
            .disabled(helper.isSpinning)
        }
        
        var blur: UIBlurEffect {
            return .init(style: .dark)
        }
        
        var effect: UIVisualEffect {
            return UIVibrancyEffect(blurEffect: blur, style: .fill)
        }
    }
    

}
