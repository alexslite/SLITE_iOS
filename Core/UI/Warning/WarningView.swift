//
//  WarningView.swift
//  Slite
//
//  Created by Paul Marc on 23.06.2022.
//

import Foundation
import SwiftUI

struct WarningView: View {
    
    var onProceed: () -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image("warning")
                    .renderingMode(.template)
                    .foregroundColor(.tertiaryForegorund)
                    .padding(.bottom, 24)
                Text(Texts.Warning.title)
                    .multilineTextAlignment(.center)
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.secondaryForegorund)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        Buttons.FilledRoundedButton(title: Texts.Warning.buttonTitle) {
            onProceed()
        }
        .padding([.horizontal, .bottom], 24)
        .frame(alignment: .bottom)
    }
}

final class WarningOverlayViewController: UIHostingController<WarningView> {
    
    init(onProceed: @escaping () -> Void) {
        super.init(rootView: WarningView(onProceed: onProceed))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
