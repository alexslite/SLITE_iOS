//
//  UIFont + Utils.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation
import UIKit

// extension for disabling font scalling
public extension UITraitCollection {
    static let defaultContentSizeTraitCollection = UITraitCollection(preferredContentSizeCategory: .medium)
}

extension UIFont {
    
    private static func findFont(named: String, withSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        guard let font = UIFont(name: named, size: size) else {
            assert(false, "Font file not found. Make sure the names match and the font files are added to the destination target.")
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        return font
    }
    
    struct Main {

        static func bold(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "HelveticaNeue-Bold", withSize: size, weight: .bold), compatibleWith: .defaultContentSizeTraitCollection)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "HelveticaNeue", withSize: size, weight: .regular), compatibleWith: .defaultContentSizeTraitCollection)
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "HelveticaNeue-Semibold", withSize: size, weight: .semibold), compatibleWith: .defaultContentSizeTraitCollection)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "HelveticaNeue-Medium", withSize: size, weight: .medium), compatibleWith: .defaultContentSizeTraitCollection)
        }
        
        static var h1: UIFont {
            return bold(size: 24)
        }
        
        static var h2: UIFont {
            return bold(size: 16)
        }
    }
    
    struct Secondary {
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "SecondaryFontFamiliy-Bold", withSize: size, weight: .bold), compatibleWith: .defaultContentSizeTraitCollection)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.findFont(named: "SecondaryFontFamiliy-Regular", withSize: size, weight: .regular), compatibleWith: .defaultContentSizeTraitCollection)
        }

        static var h1: UIFont {
            return bold(size: 24)
        }
        
        static var h2: UIFont {
            return regular(size: 16)
        }
    }
}
