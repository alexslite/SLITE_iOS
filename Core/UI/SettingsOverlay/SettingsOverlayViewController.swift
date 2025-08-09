//
//  SettingsOverlayViewController.swift
//  Slite
//
//  Created by Paul Marc on 23.06.2022.
//

import UIKit
import SwiftUI

final class SettingsOverlayViewController: UIHostingController<Core.SettingsOverlay> {
    
    init() {
        super.init(rootView: Core.SettingsOverlay(title: Texts.SettingsOverlay.noBLTitle, onSettingsPressed: {
            guard let url = URL(string: "App-prefs:Bluetooth") else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            
            UIApplication.shared.open(url)
        }))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class UnauthorizedOverlayViewController: UIHostingController<Core.SettingsOverlay> {
    
    init() {
        super.init(rootView: Core.SettingsOverlay(title: Texts.SettingsOverlay.unauthorizedTitle, onSettingsPressed: {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            
            UIApplication.shared.open(url)
        }))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
