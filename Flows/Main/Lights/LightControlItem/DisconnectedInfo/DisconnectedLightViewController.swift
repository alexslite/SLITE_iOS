//
//  DisconnectedLightViewController.swift
//  Slite
//
//  Created by Paul Marc on 05.04.2022.
//

import Foundation

extension DisconnectedLight {
    
    class ViewController: SheetPresentedViewController {
        init(reconnectCallback: @escaping () -> Void) {
            let contentView = ContentView(reconnectCallback: reconnectCallback)
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
