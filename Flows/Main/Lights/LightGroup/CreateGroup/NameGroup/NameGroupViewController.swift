//
//  NameGroupViewController.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import UIKit
import SwiftUI

extension NameGroup {

    class ViewController: SheetPresentedViewController {

        let viewModel: ViewModel

        init(viewModel: ViewModel, scenesName: [String]) {
            self.viewModel = viewModel
            let contentView = ContentView(scenesName: scenesName)
                .environmentObject(viewModel)
                .edgesIgnoringSafeArea(.all)
                .eraseToAnyView()
            super.init(config: .init(), rootView: contentView)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }

        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
}
