//
//  RemoveSceneViewController.swift
//  Slite
//
//  Created by Paul Marc on 05.05.2022.
//

import Foundation

extension RemoveScene {
    
    class ViewController: SheetPresentedViewController {
        init(scene: Scene, removeSceneCallback: ((Scene) -> Void)?, cancelCallback: (()-> Void?)?) {
            let contentView = ContentView(scene: scene,
                                          confirmCallback: { removeSceneCallback?(scene)},
                                          dismissCallback: { cancelCallback?() })
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
