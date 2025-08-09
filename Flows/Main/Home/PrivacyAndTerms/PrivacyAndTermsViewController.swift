//
//  PrivacyAndTermsViewController.swift
//  Slite
//
//  Created by Paul Marc on 05.07.2022.
//

import Foundation
import MessageUI
import Combine

extension PrivacyAndTerms {
    
    class ViewController: SheetPresentedViewController {
        
        let onTapEmail = PassthroughSubject<Void, Never>()
        let onTapFirmware = PassthroughSubject<Void, Never>()
        
        init() {
            let contentView = ContentView(onEmailTap: onTapEmail, onFirmwareAvailableTap: onTapFirmware)
                .edgesIgnoringSafeArea(.all)
                .eraseToAnyView()
            super.init(config: .init(), rootView: contentView)
            
            onTapEmail.sink { [weak self] in
                self?.openMail()
            }.store(in: &disposableBag)
        }

        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func openMail() {
            guard let url = URL(string: "mailto:hello@slite.co") else { return }
            UIApplication.shared.open(url)
        }
    }
}

extension PrivacyAndTerms.ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
