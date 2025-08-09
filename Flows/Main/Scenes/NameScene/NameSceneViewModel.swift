//
//  NameSceneViewModel.swift
//  Slite
//
//  Created by Paul Marc on 02.05.2022.
//

import UIKit
import Combine

extension NameScene {
    
    class ViewModel: ObservableObject {
        
        @Published var sceneName: String = "" {
            didSet {
                if sceneName.count > 15 {
                    sceneName = String(sceneName.dropLast())
                }
                if let first = sceneName.first, first.isWhitespace { sceneName = String(sceneName.dropFirst()) }
            }
        }
        var saveButtonEnabled: Bool {
            sceneName.trimmingCharacters(in: .whitespaces).count > 1
        }
        
        let onFinishedInteraction = PassthroughSubject<String, Never>()
        var textField: UITextField?
    }
}
