//
//  NameGroupViewModel.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import Combine
import UIKit

extension NameGroup {
    
    class ViewModel: ObservableObject {
        
        @Published var groupName: String = "" {
            didSet {
                if groupName.count > 15 {
                    groupName = String(groupName.dropLast())
                }
                if let first = groupName.first, first.isWhitespace { groupName = String(groupName.dropFirst()) }
            }
        }
        
        let onFinishedInteraction = PassthroughSubject<String, Never>()
        var textField: UITextField?
    }
}
