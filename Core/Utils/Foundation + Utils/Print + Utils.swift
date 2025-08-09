//
//  Print + Utils.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == endIdx ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        
    #endif
}
