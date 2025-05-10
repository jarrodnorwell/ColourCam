//
//  CGFloat.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 7/5/2025.
//

import Foundation
import UIKit

extension CGFloat {
    static var smallCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
    
    static var mediumCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
    
    static var largeCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
}
