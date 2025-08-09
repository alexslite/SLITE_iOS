//
//  Texts.swift
//  Slite
//
//  Created by Paul Marc on 11.03.2022.
//

import Foundation

struct Texts {
    struct Core {
        static let done = "Done!"
        static let name = "Name"
        static let next = "Next"
    }
    
    struct Toast {
        static let sceneCreated = "Your scene was successfully created"
        static func connectionFailedMessage(deviceName: String) -> String {
            "Failed to setup device \(deviceName)"
        }
    }
    
    
    struct Onboarding {
        static let addLightTutorialTitle = "Tap here to connect\nyour first Slite"
        
        static let firstTitle = "Welcome to Slite"
        static let secondTitle = "Bring your Slite to life"
        static let thirdTitle = "Scenes, Groups & Effects"
        
        static let firstDescription = "Let’s take your creativity to the next level!"
        static let secondDescription = "Control your Slite’s color, brightness, saturation and plenty more."
        static let thirdDescription = "Create your own ‘Scene’ or ‘Group’ with multiple lights, or pump up the fun with playful effects!"
    }
    
    struct Discovery {
        static let discoveryScreenTitle = "Add Light"
        static let discoverySearchingText = "Searching for your Slite"
        static let discoveryFailedText = "We couldn’t find any Slite"
        static let tryAgainButtonTitle = "Try again"
        static let settingUpSliteTitle = "Setting up your Slite"
    }
    
    struct EditName {
        static let editSliteNameTitle = "Name your Slite"
        static let editSliteNamePlaceholder = "Enter Slite name"
        
        static let editGroupNameTitle = "Name your group"
        static let editGroupNamePlaceholder = "Enter group name"
        
        static let sliteNameHint = "Name can be 15 characters max."
    }
    
    struct RemoveLight {
        static let title = "Remove Light?"
        static func descriptionFor(lightName: String) -> String {
            "Are you sure you want to remove “\(lightName)” from your list and groups?"
        }
        static let sceneRemoveTitle = "\nDoing this will delete the following scenes:"
        
        static let remove = "Remove"
        static let cancel = "Cancel"
    }
    
    struct RemoveGroup {
        static let title = "Ungroup Lights?"
        static func descriptionFor(groupName: String) -> String {
            "Are you sure you want to ungroup lights from \(groupName)?"
        }
        static let remove = "Ungroup"
        static let cancel = "Cancel"
    }
    
    struct Disconnected {
        static let title = "Connection issue"
        static let bullets = "• Check power source\n• Check Bluetooth connection\n• Check for physical damage"
    }
    
    struct PrivacyAndTerms {
        static let title = "Support"
        static let privacyTitle = "Privacy Policy"
        static let termsTitle = "Terms of Use"
        static let getInTouch = "Get in Touch"
        
        static var appVersion: String {
            "App Version \(ApplicationVersion.versionNumber)"
        }
    }
    
    struct FirmwareUpdate {
        static let updatesAvailable = "Firmware Updates Available"
        static let navigationTitle = "Firmware Updates"
    }
    
    struct ApplicationVersion {
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        static let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    struct CameraView {
        static let pickButtonTitle = "Pick Color"
        static let useColorButonTitle = "Use Color"
        static let settingsButtonTitle = "Go to Settings"
        static let cameraNotAvailable = "Slite unfortunately does not have access to the camera. Access can be changed in Settings"
        static let galleryNotAvailable = "Slite unfortunately does not have access to the gallery. Access can be changed in Settings"
    }
    
    struct EditHex {
        static let regex = "[A-Fa-f0-9]{6}"
        static let invalidHint = "Please enter a valid Hex Color Code"
    }
    
    struct CreateGroup {
        static let title = "Select Lights"
        static let popUpTitle = "Group Name"
        static let textFieldTitle = "Name"
        static let buttonTitle = "Create Group"
        static let groupNameHint = "Name can be 15 characters max."
        
        static let popUpTitleWarning = "Are you sure you want to create this group?"
        static let descriptionWarning = "Grouping the selected lights will lead to deleting the following scenes that they are a part of:"
        static let buttonTitleWarning = "Delete scenes and proceed"
    }
    
    struct SaveScene {
        static let title = "Save Scene"
        static let sceneName = "Scene name"
        static let description = "You are about to create a scene which uses the settings of your active lights. This is a setting you can use later on via the Scenes section"
        static let save = "Save"
    }
    
    struct RenameScene {
        static let title = "Rename scene"
    }
    
    struct RemoveScene {
        static let title = "Remove scene?"
        static func descriptionFor(_ sceneName: String) -> String {
            "Are you sure you want to remove \(sceneName) from your list of scenes?"
        }
        static let remove = "Remove"
        static let cancel = "Cancel"
    }
    
    struct SettingsOverlay {
        static let noBLTitle = "The app requires Bluetooth to be turned on in order to communicate with the Slites"
        static let unauthorizedTitle = "The app needs Bluetooth permissions to communicate with the Slites"
        
        static let buttonTitle = "Go to settings"
    }
    
    struct Warning {
        static let title = "Some effects contain bright, flashing lights and/or patterns that may cause discomfort and/or seizures for those with photosensitive conditions.\nUser discretion is advised."
        static let buttonTitle = "I understand and would like to proceed"
    }
    
    struct MandatoryAppUpdate {
        static let title = "\"Slite\" needs to be updated"
        static let description = "You need the latest version of Slite to keep using it on your device."
        static let update = "Update now"
    }

    struct OptionalAppUpdate {
        static let title = "New update available"
        static let description = "An improved version of Slite is now available in the AppStore"
        static let later = "Later"
        static let update = "Update now"
    }
    
    struct SaveScenePopUp {
        static let title = "Unable to Save Scene"
        static let description = "To create a scene you need to have at least one\nlight or group turned ON"
        static let ok = "OK"
    }
    
    struct LightControlItem {
        static func groupDescription(turnedOn: Int, connected: Int, disconnected: Int) -> String {
            var firstString: String = ""
            var secondString: String = ""
            
            if connected > 0 {
                if turnedOn == connected {
                    firstString = "\(turnedOn) Turned On"
                } else {
                    if turnedOn == 0 {
                        firstString = "\(connected) Turned Off"
                    } else {
                        let turnedPrefix = disconnected == 0 ? "Turned" : ""
                        firstString = "\(turnedOn) of \(connected) \(turnedPrefix) On"
                    }
                }
                
                firstString += disconnected > 0 ? " • " : ""
            }
            
            if disconnected > 0 {
                secondString = "\(disconnected) Disconnected"
            } else {
                secondString = ""
            }
            
            return "\(firstString)\(secondString)"
        }
    }
}
