//
// EditHexValueViewController.swift
// Slite
//
// Created by Efraim Budusan on 28.01.2022.
//
//

import Foundation
import UIKit
import SwiftUI

extension EditHexValue {

    class ViewController: SheetPresentedViewController {

        let viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            let contentView = ContentView()
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

