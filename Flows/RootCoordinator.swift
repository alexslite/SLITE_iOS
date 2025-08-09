//
//  RootCoordinator.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit
import Combine

class RootCoordinator {
    
    var activeSessionCoordinator: MainCoordinator?
    var onboardingCoordinator: OnboardingCoordinator?
    
    weak var window: UIWindow?
    weak var navigationController: UINavigationController?
    
    var disposeBag = [AnyCancellable]()
    
    func start(in window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController()
        self.navigationController = navigationController
        self.window?.rootViewController = navigationController
        if UserDefaults.applicationWasLaunched {
            handleActiveSession(animatedEntrance: false)
        } else {
            handleOnboarding(animatedEntrance: false)
        }
        self.registerSessionClosedNotification()
    }
    
    func handleOnboarding(animatedEntrance: Bool) {
        guard let navigationController = self.navigationController else {
            return
        }
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.onFinishedInteraction.sink { [weak self] in
            self?.handleActiveSession(animatedEntrance: true)
        }.store(in: &disposeBag)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.start(animatedEntrance: animatedEntrance)
    }
    
    func handleActiveSession(animatedEntrance: Bool) {
        guard let navigationController = self.navigationController else {
            return
        }
        let activeSessionCoordinator = MainCoordinator(navigationController: navigationController)
        activeSessionCoordinator.start(animatedEntrance: animatedEntrance)
        self.activeSessionCoordinator = activeSessionCoordinator
        onboardingCoordinator = nil
    }
    
    func handleLogout() {
        guard let navigationController = self.navigationController else {
            return
        }
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.start(animatedEntrance: true)
        activeSessionCoordinator = nil
    }
    
    func registerSessionClosedNotification () {
        Notifications.sessionClosed.addObserver(self) { (self, error) in
            ErrorDisplay.checkAndShowError(error)
            self.handleLogout()
        }
    }
}
