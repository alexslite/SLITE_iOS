//
//  Font + Extensiob.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import SwiftUI

extension Font {
    
    struct Main {
        
        static func bold(size: CGFloat) -> Font {
//            return .custom("HelveticaNeue-Bold", size: size)
            return Font(UIFont.Main.bold(size: size) as CTFont)
        }
        
        static func regular(size: CGFloat) -> Font {
//            return .custom("HelveticaNeue-Regular", size: size)
            return Font(UIFont.Main.regular(size: size) as CTFont)
        }
        
        static func semibold(size: CGFloat) -> Font {
//            return .custom("HelveticaNeue-Semibold", size: size)
            return Font(UIFont.Main.semibold(size: size) as CTFont)
        }
        
        static func medium(size: CGFloat) -> Font {
//            return .custom("HelveticaNeue-Medium", size: size)
            return Font(UIFont.Main.medium(size: size) as CTFont)
        }
        
        static var h1: Font {
            return bold(size: 24)
        }
        
        static var h2: Font {
            return bold(size: 16)
        }
    }
    
    struct Secondary {
        
        static func bold(size: CGFloat) -> Font {
//            return .custom("SecondaryFontFamiliy-Bold", size: size)
            return Font(UIFont.Secondary.bold(size: size) as CTFont)
        }
        
        static func regular(size: CGFloat) -> Font {
//            return .custom("SecondaryFontFamiliy-Regular", size: size)
            return Font(UIFont.Secondary.regular(size: size) as CTFont)
        }

        static var h1: Font {
            return bold(size: 24)
        }
        
        static var h2: Font {
            return regular(size: 16)
        }
    }
}




