//
//  UIColor.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 8/5/2025.
//

import Foundation
import UIKit

extension UIColor {
    var darker: UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        return .init(red: max(r - 0.3, 0.0), green: max(g - 0.3, 0.0), blue: max(b - 0.3, 0.0), alpha: a)
    }
    
    var hex: String {
        let components = cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        return .init(format: "#%02lX%02lX%02lX",
                     lroundf(Float(r * 255)),
                     lroundf(Float(g * 255)),
                     lroundf(Float(b * 255)))
    }
    
    var isLight: Bool {
        guard let components = cgColor.components, components.count > 2 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return (brightness > 0.5)
    }
    
    var lighter: UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        return .init(red: min(r + 0.3, 1.0), green: min(g + 0.3, 1.0), blue: min(b + 0.3, 1.0), alpha: a)
    }
    
    var rgba: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        r *= 255
        g *= 255
        b *= 255
        a *= 255
        return "\(Int(r)) \(Int(g)) \(Int(b)) \(Int(a))"
    }
    
    static var skyBlue: UIColor {
        .init(red: 0.6, green: 0.8, blue: 1, alpha: 1)
    }
}
