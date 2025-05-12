//
//  Array.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 12/5/2025.
//

import Foundation

extension Array {
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}
