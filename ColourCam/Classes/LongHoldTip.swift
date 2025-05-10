//
//  LongHoldTip.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 10/5/2025.
//

import TipKit

struct LongHoldTip : Tip {
    var image: Image? { .init(systemName: "hand.tap") }
    var message: Text? { .init("Long press a colour to see it in fullscreen, copy its hex or rgba value and delete it") }
    var title: Text { .init("Hidden Feature") }
}
