//
//  ActiveSessionCoordinator.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit

class MainCoordinator {
    
    weak var navigationController: UINavigationController?
    
    let noBluetoothViewController = SettingsOverlayViewController()
    let unauthorizedViewController = UnauthorizedOverlayViewController()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        BLEService.shared.bluetoothStateCallback = { [unowned self] state in
            switch state {
            case .poweredOff:
                showNoBluetoothOverlay()
                print("\nBLST: OFF")
            case .poweredOn:
                noBluetoothViewController.dismiss(animated: false)
                print("\nBLST: ON")
            case .resetting:
                return
            case .unauthorized:
                showUnauthorizedOverlay()
                print("\nBLST: unauthorized")
            case .unsupported:
                return
            case .unknown:
                return
            @unknown default:
                return
            }
        }
    }
    
    func start(animatedEntrance: Bool) {
        let viewController = Home.ViewController()
        self.navigationController?.setViewControllers([viewController], animated: animatedEntrance)
    }
    
    func showNoBluetoothOverlay() {
        noBluetoothViewController.modalPresentationStyle = .overFullScreen        
        self.navigationController?.dismissTopmost()
        
        self.navigationController?.present(noBluetoothViewController, animated: false)
    }
    
    func showUnauthorizedOverlay() {
        unauthorizedViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(unauthorizedViewController, animated: false)
    }
}

