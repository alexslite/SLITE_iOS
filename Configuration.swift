//
//  Configuration.swift
//  Slite
//
//  Created by AI Assistant on 2024.
//

import Foundation

/// Configuration manager for environment-specific settings
struct Configuration {
    
    // MARK: - Environment
    
    enum Environment: String, CaseIterable {
        case development = "development"
        case staging = "staging"
        case production = "production"
        
        var displayName: String {
            switch self {
            case .development: return "Development"
            case .staging: return "Staging"
            case .production: return "Production"
            }
        }
    }
    
    // MARK: - Current Environment
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        // In production, this should be determined by your build configuration
        return .production
        #endif
    }
    
    // MARK: - API Configuration
    
    struct API {
        static var baseURL: String {
            switch Configuration.current {
            case .development:
                return "https://dev-api.slite.co"
            case .staging:
                return "https://staging-api.slite.co"
            case .production:
                return "https://api.slite.co"
            }
        }
        
        static var timeout: TimeInterval {
            switch Configuration.current {
            case .development:
                return 30.0
            case .staging:
                return 20.0
            case .production:
                return 15.0
            }
        }
    }
    
    // MARK: - Analytics Configuration
    
    struct Analytics {
        static var sentryDSN: String {
            switch Configuration.current {
            case .development:
                return "https://08c85a019d0a4e3fb7fb8115c535d951@o1297260.ingest.sentry.io/6525588"
            case .staging:
                return "https://08c85a019d0a4e3fb7fb8115c535d951@o1297260.ingest.sentry.io/6525588"
            case .production:
                return "https://08c85a019d0a4e3fb7fb8115c535d951@o1297260.ingest.sentry.io/6525588"
            }
        }
        
        static var mixpanelToken: String {
            switch Configuration.current {
            case .development:
                return "a4e9e25417a643291c512cd775e446cd"
            case .staging:
                return "a4e9e25417a643291c512cd775e446cd"
            case .production:
                return "a4e9e25417a643291c512cd775e446cd"
            }
        }
        
        static var enableDebugMode: Bool {
            switch Configuration.current {
            case .development:
                return true
            case .staging:
                return false
            case .production:
                return false
            }
        }
        
        static var tracesSampleRate: Double {
            switch Configuration.current {
            case .development:
                return 1.0
            case .staging:
                return 0.5
            case .production:
                return 0.1
            }
        }
    }
    
    // MARK: - Bluetooth Configuration
    
    struct Bluetooth {
        static var scanTimeout: TimeInterval = 5.0
        static var connectionTimeout: TimeInterval = 15.0
        static var maxReconnectionAttempts: Int = 3
        static var restoreIdentifier: String = "SliteBluetoothRestoreKey"
        
        static var scanOptions: [String: Any] {
            var options: [String: Any] = [:]
            
            if #available(iOS 17.0, *) {
                options[CBCentralManagerScanOptionAllowDuplicatesKey] = false
            }
            
            return options
        }
        
        static var connectionOptions: [String: Any] {
            var options: [String: Any] = [:]
            
            if #available(iOS 17.0, *) {
                options[CBConnectPeripheralOptionNotifyOnConnectionKey] = true
                options[CBConnectPeripheralOptionNotifyOnDisconnectionKey] = true
                options[CBConnectPeripheralOptionNotifyOnNotificationKey] = true
            }
            
            return options
        }
    }
    
    // MARK: - UI Configuration
    
    struct UI {
        static var animationDuration: TimeInterval = 0.3
        static var hapticFeedbackEnabled: Bool = true
        static var darkModeEnabled: Bool = true
        static var autoLockTimeout: TimeInterval = 300.0 // 5 minutes
    }
    
    // MARK: - Feature Flags
    
    struct Features {
        static var firmwareUpdatesEnabled: Bool = true
        static var cloudSyncEnabled: Bool = true
        static var advancedColorPicker: Bool = true
        static var voiceControl: Bool = false // Future feature
        static var locationBasedLighting: Bool = false // Future feature
    }
    
    // MARK: - Security
    
    struct Security {
        static var certificatePinningEnabled: Bool = true
        static var biometricAuthenticationEnabled: Bool = true
        static var encryptionLevel: EncryptionLevel = .aes256
        
        enum EncryptionLevel: String, CaseIterable {
            case aes128 = "AES-128"
            case aes256 = "AES-256"
            
            var keySize: Int {
                switch self {
                case .aes128: return 128
                case .aes256: return 256
                }
            }
        }
    }
    
    // MARK: - Debug Information
    
    static var debugInfo: [String: Any] {
        return [
            "Environment": current.rawValue,
            "iOS Version": UIDevice.current.systemVersion,
            "Device Model": UIDevice.current.model,
            "App Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "Build Number": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            "Configuration": [
                "API Base URL": API.baseURL,
                "Bluetooth Scan Timeout": Bluetooth.scanTimeout,
                "UI Animation Duration": UI.animationDuration,
                "Security Encryption": Security.encryptionLevel.rawValue
            ]
        ]
    }
}

// MARK: - Extensions

extension Configuration {
    /// Print current configuration for debugging
    static func printCurrentConfiguration() {
        print("=== Slite Configuration ===")
        print("Environment: \(current.displayName)")
        print("API Base URL: \(API.baseURL)")
        print("Analytics Debug Mode: \(Analytics.enableDebugMode)")
        print("Bluetooth Scan Timeout: \(Bluetooth.scanTimeout)s")
        print("UI Animation Duration: \(UI.animationDuration)s")
        print("Security Encryption: \(Security.encryptionLevel.rawValue)")
        print("========================")
    }
}