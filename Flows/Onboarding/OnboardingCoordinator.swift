//
//  OnboardingCoordinator.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022..
//

import Foundation
import UIKit
import Combine

class OnboardingCoordinator: NSObject{
    
    weak var navigationController: UINavigationController?
    
    let onFinishedInteraction = PassthroughSubject<Void, Never>()
    
    init(navigationController:UINavigationController) {
        self.navigationController = navigationController
    }
    
    var disposeBag = [AnyCancellable]()
    
    func start(animatedEntrance:Bool) {
        let viewController = OnboardingViewController()
        viewController.slides.last?.viewModel.onCTA.sink { [weak self] in
            self?.onFinishedInteraction.send()
        }.store(in: &disposeBag)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(viewController, animated: animatedEntrance)
    }
    
    func saveSession(token: String) {
        Session.accessToken = token
    }

    
}

