//
// EditHexValueViewModel.swift
// Slite
//
// Created by Efraim Budusan on 28.01.2022.
//
//

import Foundation
import Combine
import UIKit

extension EditHexValue {
    
    class ViewModel: ObservableObject {
        
        @Published var hexValue: String {
            didSet {
                isValid = hexValue.isValidWith(regex: Texts.EditHex.regex)
            }
        }
        @Published var isValid = true
        
        let onFinishedInteraction = PassthroughSubject<String, Never>()
        
        var textField: UITextField? 
        
        init(hexValue: String) {
            self.hexValue = hexValue
        }
        
    }
}
