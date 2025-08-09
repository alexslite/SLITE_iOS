//
//  Session.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit


enum Session {
    @UserDefault(key: "accessToken", defaultValue: nil)
    static var accessToken: String?
    
    @UserDefault(key: "currentUserID", defaultValue: nil)
    static var currentUserID: String?
    
    @Keychain(key: "password")
    static var password: String?
    
    static var isValid: Bool {
        return accessToken?.isEmpty == false
    }
    
    static func shouldRestoreUserSession () -> Bool {
        let user = JSONCache.currentUser.loadFromFile()
        let isComplete = user?.firstName?.isEmpty == false && user?.lastName?.isEmpty == false
        return !isComplete
    }
    
    
    static func saveSession(accessToken: String, userId: String) {
        self.accessToken = accessToken
        self.currentUserID = userId
    }
    
    static func close(error: Error? = nil) {
        guard isValid else {
            return
        }        
//        Facebook.logout()
        self.removeUserIDAndAccessToken()
        Notifications.sessionClosed.post(error)
    }
    
    static func removeUserIDAndAccessToken() {
        Session.currentUserID = nil
        Session.accessToken = nil
        UserDefaults.standard.synchronize()
    }
}
