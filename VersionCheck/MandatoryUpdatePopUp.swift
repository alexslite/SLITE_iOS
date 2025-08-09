//
//  MandatoryUpdatePopUp.swift
//  Slite
//
//  Created by Paul Marc on 07.07.2022.
//

import Foundation
import SwiftUI

final class UpdateViewController: UIHostingController<MandatoryUpdatePopUp> {

    init(onUpdate: @escaping () -> Void) {
        super.init(rootView: MandatoryUpdatePopUp(onUpdate: onUpdate))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.75)
    }
}

struct MandatoryUpdatePopUp: View {
    
    var onUpdate: () -> Void
    
    var body: some View {
        ZStack {
            popUp
        }
    }
    
    var popUp: some View {
        VStack {
            Text(Texts.MandatoryAppUpdate.title)
                .frame(alignment: .center)
                .foregroundColor(.white)
                .font(Font.Main.bold(size: 18))
                .padding(.all, 16)
            Text(Texts.MandatoryAppUpdate.description)
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(Font.Main.regular(size: 15))
                .padding(.bottom, 24)
                .padding(.horizontal, 48)
                            
                Button(action: {
                    onUpdate()
                }, label: {
                    ZStack {
                        Text(Texts.MandatoryAppUpdate.update)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                    }
                })
                .frame(.init(.init(width: 150, height: 50)))
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.tartRed))
                .padding(.bottom, 24)
        }
        .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondaryBackground).padding(.horizontal, 24))
    }
}
