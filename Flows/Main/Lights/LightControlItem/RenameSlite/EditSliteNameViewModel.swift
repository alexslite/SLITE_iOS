//
//  EditLightNameViewModel.swift
//  Slite
//
//  Created by Paul Marc on 16.03.2022.
//

import Foundation
import Combine
import UIKit

extension EditSliteName {
    
    class ViewModel: ObservableObject {
        
        var title: String {
            isGroup ? Texts.EditName.editGroupNameTitle : Texts.EditName.editSliteNameTitle
        }
        var placeholder: String {
            isGroup ? Texts.EditName.editGroupNamePlaceholder : Texts.EditName.editSliteNamePlaceholder
        }
        
        @Published var sliteName: String {
            didSet {
                if sliteName.count > 15 {
                    sliteName = String(sliteName.dropLast())
                }
                if let first = sliteName.first, first.isWhitespace { sliteName = String(sliteName.dropFirst()) }
            }
        }
        var isGroup: Bool
        
        let onFinishedInteraction = PassthroughSubject<String, Never>()
        
        var textField: UITextField?
        
        init(sliteName: String, isGroup: Bool) {
            self.sliteName = sliteName
            self.isGroup = isGroup
        }
    }
}
