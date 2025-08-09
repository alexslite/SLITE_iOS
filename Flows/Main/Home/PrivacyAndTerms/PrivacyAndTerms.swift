//
//  PrivacyAndTerms.swift
//  Slite
//
//  Created by Paul Marc on 05.07.2022.
//

import UIKit
import SwiftUI
import Combine

struct PrivacyAndTerms {
    
    struct ContentView: View {
        
        var onEmailTap: PassthroughSubject<Void, Never>
        var onFirmwareAvailableTap: PassthroughSubject<Void, Never>
        
        var body: some View {
            Text(Texts.PrivacyAndTerms.title)
                .font(.Main.bold(size: 19))
                .foregroundColor(.primaryForeground)
                .padding(.all, 16)
                .frame(alignment: .center)
            HStack {
                Text("•")
                    .padding(.leading, 24)
                    .padding(.bottom, 24)
                    .font(.Main.regular(size: 15))
                Text(Texts.PrivacyAndTerms.privacyTitle)
                    .underline()
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        if let url = URL(string: "https://www.slite.co/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            
            HStack {
                Text("•")
                    .padding(.leading, 24)
                    .padding(.bottom, 24)
                    .font(.Main.regular(size: 15))
                Text(Texts.PrivacyAndTerms.termsTitle)
                    .underline()
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        if let url = URL(string: "https://www.slite.co/terms-of-use") {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            HStack {
                Text("•")
                    .padding(.leading, 24)
                    .padding(.bottom, 24)
                    .font(.Main.regular(size: 15))
                Text(Texts.PrivacyAndTerms.getInTouch)
                    .underline()
                    .font(.Main.regular(size: 15))
                    .foregroundColor(.primaryForeground)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        onEmailTap.send()
                    }
            }
            
            if BLEService.shared.isFirmwareUpdateAvailable {
                HStack {
                    Text("•")
                        .padding(.leading, 24)
                        .font(.Main.regular(size: 15))
                        .foregroundColor(.tartRed)
                    Text(Texts.FirmwareUpdate.updatesAvailable)
                        .underline()
                        .font(.Main.regular(size: 15))
                        .foregroundColor(.tartRed)
                        .padding(.trailing, 24)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            onFirmwareAvailableTap.send()
                        }
                }
            }
            
            Text(Texts.PrivacyAndTerms.appVersion)
                .font(.Main.regular(size: 13))
                .foregroundColor(.sonicSilver)
                .frame(alignment: .center)
                .padding(.vertical, 24)
            
            Image("logo")
                .frame(alignment: .center)
                .padding(.bottom, 30)
        }
    }
}
