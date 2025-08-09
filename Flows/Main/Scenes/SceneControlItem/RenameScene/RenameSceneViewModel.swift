//
//  RenameSceneViewModel.swift
//  Slite
//
//  Created by Paul Marc on 04.05.2022.
//

import Foundation
import Combine
import UIKit

extension RenameScene {
    
    class ViewModel: ObservableObject {
        
        @Published var sceneName: String {
            didSet {
                if sceneName.count > 15 {
                    sceneName = String(sceneName.dropLast())
                }
                if let first = sceneName.first, first.isWhitespace { sceneName = String(sceneName.dropFirst()) }
            }
        }
        
        let onFinishedInteraction = PassthroughSubject<String, Never>()
        
        var textField: UITextField?
        
        init(sceneName: String) {
            self.sceneName = sceneName
        }
    }
}
