//
//  CameraAccess.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 6/5/2025.
//

import AVFoundation

actor CameraAccess {
    var authorised: Bool = false
    var status: AVAuthorizationStatus = .notDetermined
    
    func checkAuthorisationStatus() {
        status = AVCaptureDevice.authorizationStatus(for: .video)
        authorised = status == .authorized
    }
    
    func authorise() async -> Bool {
        authorised = await AVCaptureDevice.requestAccess(for: .video)
        return authorised
    }
}
