//
//  Tips.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 11/5/2025.
//

import Foundation
import TipKit

struct EllipsisTip : Tip {
    var image: Image? { .init(systemName: "sparkles") }
    var message: Text? { .init("Create gradients, persist colour palettes between launches and more") }
    var title: Text { .init("New Features") }
}

struct TooManyColoursTip : Tip {
    var image: Image? { .init(systemName: "exclamationmark.triangle") }
    var message: Text? { .init("Gradients use 9 colours, use \"Save Palette\" to save and reset the palette") }
    var title: Text { .init("Limit Reached") }
}
