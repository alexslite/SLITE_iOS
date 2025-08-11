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
        
        // Print current configuration for debugging
        Configuration.printCurrentConfiguration()
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Sentry with environment-based settings
        SentrySDK.start { options in
            options.dsn = Configuration.Analytics.sentryDSN
            options.debug = Configuration.Analytics.enableDebugMode
            
            // Modern iOS 17+ tracing configuration
            options.tracesSampleRate = Configuration.Analytics.tracesSampleRate
            options.enableTracing = true
            options.enableAutoSessionTracking = true
            
            // Add environment tag
            options.environment = Configuration.current.rawValue
        }
        
        // Configure Mixpanel with secure token handling
        Mixpanel.initialize(token: Configuration.Analytics.mixpanelToken, trackAutomaticEvents: false)
        Mixpanel.mainInstance().identify(distinctId: Mixpanel.mainInstance().distinctId)
        
        // Set up modern iOS 17+ app lifecycle
        if #available(iOS 17.0, *) {
            // Enable modern app lifecycle features
            application.isIdleTimerDisabled = false
            
            // Configure modern iOS features
            configureModerniOSFeatures()
        }
        
        return true
    }
    
    @available(iOS 17.0, *)
    private func configureModerniOSFeatures() {
        // Configure modern iOS 17+ features
        // This can include advanced Bluetooth features, enhanced security, etc.
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

