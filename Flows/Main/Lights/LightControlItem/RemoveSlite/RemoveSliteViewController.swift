//
//  RemoveSliteViewController.swift
//  Slite
//
//  Created by Paul Marc on 01.04.2022.
//

import Foundation

extension RemoveSlite {
    
    class ViewController: SheetPresentedViewController {
        init(light: LightData, isGroup: Bool, scenesName: [String], removeLightCallback: ((LightData) -> Void)?, cancelCallback: (()-> Void?)?) {
            let contentView = ContentView(light: light,
                                          isGroup: isGroup,
                                          scenesName: scenesName,
                                          confirmCallback: { removeLightCallback?(light)},
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
