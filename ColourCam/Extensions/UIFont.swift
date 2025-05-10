//
//  UIFont.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 8/5/2025.
//

import Foundation
import UIKit

extension UIFont {
    static func bold(_ textStyle: UIFont.TextStyle) -> UIFont {
        .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    }
}
