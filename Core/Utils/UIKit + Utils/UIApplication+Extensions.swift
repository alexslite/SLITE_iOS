//
//  UIApplication+Extensions.swift
//  Slite
//
//  Created by Paul Marc on 11.03.2022.
//

import UIKit

extension UIApplication {
    static var current: AppDelegate { UIApplication.shared.delegate as! AppDelegate }
    
    static var topSafeAreaHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame.minY ?? 0
    }
    
    static var bottomSafeAreaHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    static func takeScreenshot() -> UIImage? {
        var screenshotImage: UIImage?
        guard let layer = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.layer else { return nil }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return screenshotImage
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    static var shouldShowWarning: Bool {
        UserDefaults.standard.string(forKey: Constants.kWarningKey) == nil
    }
    
    static func showWarningAlert(completion: @escaping () -> Void) {
        let vc = WarningOverlayViewController(onProceed: {
            UIApplication.shared.keyWindow?.rootViewController?.topmostViewController?.dismiss(animated: true, completion: {
                completion()
            })
            UserDefaults.standard.set(true, forKey: Constants.kWarningKey)
        })
        vc.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.topmostViewController?.present(vc, animated: false)
    }
}

