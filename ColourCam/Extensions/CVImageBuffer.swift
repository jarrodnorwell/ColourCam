//
//  CVImageBuffer.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 7/5/2025.
//

import AVFoundation
import Foundation
import UIKit

extension CVImageBuffer {
    var colour: UIColor? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
        
        guard CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_32BGRA,
              let baseAddress = CVPixelBufferGetBaseAddress(self) else { return nil }
        
        let x = CVPixelBufferGetWidth(self) / 2
        let y = CVPixelBufferGetHeight(self) / 2
        let offset = y * CVPixelBufferGetBytesPerRow(self) + x * 4
        
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        let blue = CGFloat(buffer[offset]) / 255
        let green = CGFloat(buffer[offset + 1]) / 255
        let red = CGFloat(buffer[offset + 2]) / 255
        let alpha = CGFloat(buffer[offset + 3]) / 255
        
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
