//
//  Facebook.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
//import FacebookLogin
//import FacebookCore
//
//class Facebook {
//    static let manager: LoginManager = LoginManager()
//
//    static func isOpen() -> Bool {
//        guard let current = AccessToken.current else { return false }
//        return !current.tokenString.isEmpty && current.expirationDate.timeIntervalSinceNow > 0.0
//
//
//    static func accessToken() -> String? {
//        return AccessToken.current?.tokenString
//    }
//
//    static func expirationDate() -> Date? {
//        return AccessToken.current?.expirationDate
//    }
//
//    static func loginFromViewController(_ fromController: UIViewController?, callback:@escaping (_ userCanceled : Bool, _ error : Error?) -> Void) {
//        manager.logIn(permissions: ["email","public_profile"], from: fromController) { (result, error) -> Void in
//            let didCancel = result?.isCancelled ?? false
//            callback( didCancel == true, error)
//        }
//    }
//
//    static func getUserInfo( _ callback: @escaping ( _ email:String?, _ first_name:String?, _ last_name: String?, _ photoUrl:String?, _ error: Error?) -> () ){
//        let request: GraphRequest = GraphRequest(graphPath: "/me", parameters: ["fields": "email,first_name,last_name,picture"], httpMethod: .get)
//        request.start { (connection, result, error) in
//            if let dict = result as? NSDictionary {
//                let email = dict.value(forKey: "email") as! String
//                let first_name = dict.value(forKey: "first_name") as? String
//                let last_name = dict.value(forKey: "last_name") as? String
//                let picture = dict.value(forKeyPath: "picture.data.url") as? String
//                callback(email, first_name, last_name, picture, nil)
//            } else {
//                callback(nil, nil, nil, nil, error)
//            }
//        }
//    }
//
//    static func logout() {
//        manager.logOut()
//    }
//
//    static func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }
//
//    static func application(_ app: UIApplication, openURL url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: [])
//    }
//
//    static func application(_ application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]!) -> Bool {
//        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions as? [UIApplication.LaunchOptionsKey : Any])
//    }
//}
