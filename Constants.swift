//
//  Constants.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit

struct Constants {
    #if PRODUCTION
    static let API_URL = "your api url"
    #elseif STAGING
    static let API_URL = "your api url"
    #elseif DEV
    static let API_URL = "https://tapptitude-nodejs.herokuapp.com/api/v1"
    #endif
    
    static var userAgent: String {
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let appName = "Slite"
        return "ios \(osVersion) \(appName)/\(appVersion)"
    }
    
    static var kWarningKey = "WARNING_WAS_SHOWN"
}



//MARK: - Notifications
extension Notifications {
    static let sessionClosed = Notification<Error?, String>() // payload, identity of payload
//    static let userDidCheckin = Notification<User, String>() // payload, identity of payload
//    static let userChangedTeam = Notification<Void, String>() // payload, identity of payload
}
