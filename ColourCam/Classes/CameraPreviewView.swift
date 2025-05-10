//
//  CameraPreviewView.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 7/5/2025.
//

import AVFoundation
import Foundation
import UIKit

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? { layer as? AVCaptureVideoPreviewLayer }
}
