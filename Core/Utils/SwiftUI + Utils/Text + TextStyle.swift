//
//  Text + TextStyle.swift
//  Slite
//
//  Created by Efraim Budusan on 19.05.2021.
//

import Foundation
import SwiftUI

extension Text {

    func textStyle<S>(_ style: S) -> some View where S : TextStyle {
        return style.makeBody(text: self)
    }
}

protocol TextStyle {
    
    associatedtype Body : View
    func makeBody(text: Text) -> Self.Body
} 

