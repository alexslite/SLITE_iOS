//
//  OnboardingViewController.swift
//  Slite
//
//  Created by Efraim Budusan on 25.01.2022.
//

import UIKit
import SwiftUIX

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.setupFirstScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    lazy var slides: [OnboardingSlide.ViewController] = {
        OnboardingSlide.allSlides.enumerated().map { (index, item) in
            return OnboardingSlide.ViewController.init(viewModel: .init(item: item, index: index, pageCount: OnboardingSlide.allSlides.count), nextButtonCallback: {
                self.onNext(index: index + 1)
            })
        }
    }()
    
    func onNext(index: Int) {
        self.slides[index].view.alpha = 0
        self.addChild(controller: self.slides[index], to: self.view)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn) {
            self.slides[index].view.alpha = 1
        } completion: { _ in
            
        }
    }
    
    func setupFirstScreen() {
        self.addChild(controller: slides[0], to: self.view)
    }
}
