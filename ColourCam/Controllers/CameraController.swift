//
//  CameraController.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 7/5/2025.
//

@preconcurrency import AVFoundation
import Foundation
import TipKit
import UIKit

class CameraController : UIViewController {
    var session: AVCaptureSession = .init()
    var device: AVCaptureDevice? = .systemPreferredCamera
    var input: AVCaptureDeviceInput? = nil
    var output: AVCaptureVideoDataOutput? = nil
    
    var bufferQueue: DispatchQueue = .init(label: "com.antique.ColourCam.buffer")
    var sessionQueue: DispatchQueue = .init(label: "com.antique.ColourCam.session")
    var point: CGPoint? = nil
    
    var imageView: UIImageView? = nil
    var button: FakeButton? = nil
    var coloursCollectionView: ColoursCollectionView? = nil
    var colour: UIColor? = nil
    
    let longHoldTip: LongHoldTip = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let previewView: CameraPreviewView = .init()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        if let videoPreviewLayer = previewView.videoPreviewLayer {
            videoPreviewLayer.session = session
            videoPreviewLayer.videoGravity = .resizeAspectFill
        }
        
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageView = .init(image: .init(systemName: "dot.scope")?
            .applyingSymbolConfiguration(.init(hierarchicalColor: .white))?
            .applyingSymbolConfiguration(.init(scale: .large)))
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 8
        imageView.layer.shadowOpacity = 2 / 3
        previewView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: previewView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: previewView.centerYAnchor).isActive = true
        
        button = .init("Capture", UIBlurEffect.Style(rawValue: 1100) ?? .systemUltraThinMaterial, frame: .zero)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.handler = { [weak self] button in
            UIImpactFeedbackGenerator(view: button).impactOccurred()
            
            guard let self,
                  let coloursCollectionView = self.coloursCollectionView,
                  let colour = self.colour else { return }
            coloursCollectionView.add(colour)
            self.colour = nil
        }
        previewView.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.trailingAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        coloursCollectionView = .init()
        guard let coloursCollectionView else { return }
        coloursCollectionView.translatesAutoresizingMaskIntoConstraints = false
        coloursCollectionView.cameraController = self
        previewView.addSubview(coloursCollectionView)
        
        coloursCollectionView.leadingAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        coloursCollectionView.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        coloursCollectionView.trailingAnchor.constraint(equalTo: button.safeAreaLayoutGuide.leadingAnchor, constant: -12).isActive = true
        coloursCollectionView.heightAnchor.constraint(equalTo: button.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        guard let device else { return }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            do {
                try self.setupCaptureSessionInput(with: device)
            } catch {
                print(error.localizedDescription)
            }
            
            self.setupCaptureSessionOutput()
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            guard let videoPreviewLayer = previewView.videoPreviewLayer,
                  let connection = videoPreviewLayer.connection else { return }
            connection.videoRotationAngle = AVCaptureDevice.RotationCoordinator(device: device,
                                                                                previewLayer: videoPreviewLayer).videoRotationAngleForHorizonLevelCapture
        }
        
        Task { @MainActor in
            for await shouldDisplay in longHoldTip.shouldDisplayUpdates {
                if shouldDisplay {
                    let controller = TipUIPopoverViewController(longHoldTip, sourceItem: coloursCollectionView)
                    present(controller, animated: true)
                } else if presentedViewController is TipUIPopoverViewController {
                    dismiss(animated: true)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    private func setupCaptureSessionInput(with device: AVCaptureDevice) throws {
        input = try .init(device: device)
        guard let input, session.canAddInput(input) else { return }
        session.addInput(input)
    }
    
    private func setupCaptureSessionOutput() {
        output = .init()
        guard let output else { return }
        output.setSampleBufferDelegate(self, queue: self.bufferQueue)
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
    }
}

extension CameraController : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let colour = pixelBuffer.colour else { return }
        
        self.colour = colour
    }
}
