//
//  ErrorDisplay.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import UIKit
import SwiftMessages

class ErrorDisplay {
    static func checkAndShowError(_ error: Error?, fromViewController:UIViewController? = nil) {
        guard let error = error else { return }
        
        let nsError = error as NSError
        let ignoreError = ((nsError.domain == "NSURLErrorDomain" && nsError.code == -999)
            || (nsError.domain == "WebKitErrorDomain" && nsError.code == 102));
        
        if (ignoreError) {
            return;
        }
        
        if fromViewController?.isViewLoaded == true {
            let isNotVisible = fromViewController?.view.window == nil
            if isNotVisible {
                return
            }
        }
        
        if nsError.domain == "NSURLErrorDomain" && nsError.code == NSURLErrorNotConnectedToInternet {
            self.showNoNetworkErrorWithAction(fromViewController)
            return
        }
        
        showErrorWithTitle("Error", message: error.localizedDescription, fromViewController: fromViewController)
    }
    
    static func showSuccesWith(title:String, andMessage message:String, fromViewController:UIViewController) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureContent(title: title, body: message)
        view.button?.setTitle("Ok", for: .normal)
        view.buttonTapHandler = { (button: UIButton) -> Void in  SwiftMessages.hide() }
        view.backgroundView.backgroundColor = UIColor(0x79D760)
        SwiftMessages.show(view: view)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureContent(title: title, body: message)
        view.button?.removeFromSuperview()
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: .statusBar)
        
        SwiftMessages.show(config: config, view: view)
        //        SwiftMessages.show(view: view)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?, _ confirmationAction:@escaping ()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    static func showErrorWithTitle(_ title:String, message:String, fromViewController:UIViewController?, actionName: String, _ confirmationAction:@escaping ()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionName, style: .default, handler:{ _ in
            confirmationAction()
        }))
        
        let controller = fromViewController ?? UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    static func showNoNetworkErrorWithAction(_ fromViewController:UIViewController?) {
        let message = "Unable to connect to the internet. Please make sure you have an active internet connection."
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        
        let controller = fromViewController ?? UIApplication.shared.windows.first { $0.isKeyWindow }?.mostVisibleViewController()
        controller?.present(alertController, animated: true, completion: nil)
    }
}


extension UIViewController {
    func checkAndShowError(_ error : NSError?) {
        ErrorDisplay.checkAndShowError(error, fromViewController:self)
    }
    
    func checkAndShow(error : Error?) {
        ErrorDisplay.checkAndShowError(error as NSError? , fromViewController:self)
    }
}
