//
//  OptionalUpdatePopUp.swift
//  Slite
//
//  Created by Paul Marc on 07.07.2022.
//

import Foundation
import SwiftUI

final class OptionalUpdateViewController: UIHostingController<OptionalUpdatePopUp> {

    init(onUpdate: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        super.init(rootView: OptionalUpdatePopUp(onUpdate: onUpdate, onDismiss: onDismiss))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.75)
    }
}

struct OptionalUpdatePopUp: View {
    
    var onUpdate: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            popUp
        }
    }
    
    var popUp: some View {
        VStack {
            Text(Texts.OptionalAppUpdate.title)
                .frame(alignment: .center)
                .foregroundColor(.white)
                .font(Font.Main.bold(size: 18))
                .padding(.all, 16)
            Text(Texts.OptionalAppUpdate.description)
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(Font.Main.regular(size: 15))
                .padding(.bottom, 24)
                .padding(.horizontal, 48)
            HStack {
                Button(action: {
                    onDismiss()
                }, label: {
                    ZStack {
                        Text(Texts.OptionalAppUpdate.later)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                    }
                })
                .frame(.init(.init(width: 120, height: 50)))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.sonicSilver, lineWidth: 1))
                .padding(.bottom, 24)
                .padding(.trailing, 12)
                
                Button(action: {
                    onUpdate()
                }, label: {
                    ZStack {
                        Text(Texts.OptionalAppUpdate.update)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                    }
                })
                .frame(.init(.init(width: 120, height: 50)))
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.tartRed))
                .padding(.bottom, 24)
                .padding(.leading, 12)
            }
        }
        .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondaryBackground).padding(.horizontal, 24))
    }
}
