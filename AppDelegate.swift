//
//  AppDelegate.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import UIKit
import Firebase
import Sentry
import Mixpanel

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        SentrySDK.start { options in
            options.dsn = "https://08c85a019d0a4e3fb7fb8115c535d951@o1297260.ingest.sentry.io/6525588"
            options.debug = true
            
            options.tracesSampleRate = 1.0
        }
        
        Mixpanel.initialize(token: "a4e9e25417a643291c512cd775e446cd", trackAutomaticEvents: false)
        Mixpanel.mainInstance().identify(distinctId: Mixpanel.mainInstance().distinctId)
        
//        UpdateAgent.loadFile()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

