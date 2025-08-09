//
//  VersionCheck.swift
//  Slite
//
//  Created by Paul Marc on 06.07.2022.
//

import Foundation
import UIKit
import Firebase

let kOptionalAlertConditionKey: String = "OPTIONAL_ALERT_KEY"
let kCurrentVersionRemoteConfigKey: String = "iosCurrentVersion"

typealias VersionComponents = (major: Int, minor: Int, patch: Int)

final class VersionCheck {
    
    static let shared = VersionCheck()
    private var alertIsShown = false
    private init() {}
    
    private lazy var optionalAlertViewController: UIViewController = {
        return OptionalUpdateViewController { [weak self] in
            self?.openAppStore()
        } onDismiss: {
            self.optionalAlertViewController.dismiss(animated: false)
        }
    }()
    
    private var shouldShowMinorDifferenceAlert: Bool {
        UserDefaults.standard.string(forKey: kOptionalAlertConditionKey) == nil ||
        UserDefaults.standard.string(forKey: kOptionalAlertConditionKey) != Texts.ApplicationVersion.versionNumber
    }
    
    func checkNewStoreVersion() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetchAndActivate { [weak self] status, _ in
            if status == .successFetchedFromRemote {
                let version = remoteConfig.configValue(forKey: kCurrentVersionRemoteConfigKey).stringValue
                self?.showAlertIfNeccessaryForVersion(version)
            }
        }
    }
        
    private func showAlertIfNeccessaryForVersion(_ string: String) {
        guard let cachedVersionComponents = Texts.ApplicationVersion.versionNumber.versionComponents,
              let apiVersionComponents = string.versionComponents else { return }
        
        if shouldShowAlertFor(apiVersion: apiVersionComponents.major, cachedVersion: cachedVersionComponents.major) {
            show(UpdateViewController(onUpdate: { [weak self] in
                self?.openAppStore()
            }))
        } else if shouldShowAlertFor(apiVersion: apiVersionComponents.minor, cachedVersion: cachedVersionComponents.minor) {
            if shouldShowMinorDifferenceAlert {
                show(optionalAlertViewController)
                UserDefaults.standard.set(Texts.ApplicationVersion.versionNumber, forKey: kOptionalAlertConditionKey)
            }
        }
    }
    
    private func shouldShowAlertFor(apiVersion: Int, cachedVersion: Int) -> Bool {
        let zeroDiff = String(apiVersion).count - String(cachedVersion).count
        
        if zeroDiff == 0 {
            return apiVersion > cachedVersion
        } else {
            var zeros = ""
            for _ in 1...abs(zeroDiff) {
                zeros.append(contentsOf: "0")
            }
            
            if zeroDiff < 0 {
                var fullVersion = String(apiVersion)
                fullVersion.append(contentsOf: zeros)
                guard let newApiVersion = Int(fullVersion) else { return false }
                        
                return newApiVersion > cachedVersion
            } else {
                var fullVersion = String(cachedVersion)
                fullVersion.append(contentsOf: zeros)
                guard let newCachedVersion = Int(fullVersion) else { return false }
                
                return apiVersion > newCachedVersion
            }
        }
    }
    
    private func show(_ alertController: UIViewController) {
        guard !alertIsShown else { return }
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            alertController.modalPresentationStyle = .overFullScreen
            
            topController.present(alertController, animated: false)
            alertIsShown = true
        }
    }
    
    private func openAppStore() {
        #warning("Add real app id")
        if let url = URL(string: "itms-apps://itunes.apple.com/app/1633396732"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
}

extension String {
    var versionComponents: VersionComponents? {
        let components = self.components(separatedBy: ".")
        guard components.count >= 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2])
        else {
            return nil
        }
        
        return (major, minor, patch)
    }
}
