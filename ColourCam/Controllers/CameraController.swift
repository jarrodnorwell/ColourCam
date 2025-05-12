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
    var optionsButton: FakeButton? = nil, captureButton: FakeButton? = nil
    var coloursCollectionView: ColoursCollectionView? = nil
    var colour: UIColor? = nil
    
    let ellipsisTip: EllipsisTip = .init()
    
    let collectionViewLayout: CollectionViewLayout = .init()
    
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
        
        optionsButton = .init(.init(systemName: "ellipsis"), .private, frame: .zero)
        guard let optionsButton else { return }
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        let interaction: UIContextMenuInteraction = .init(delegate: self)
        optionsButton.addInteraction(interaction)
        previewView.addSubview(optionsButton)
        
        optionsButton.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        optionsButton.leadingAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        captureButton = .init(.init(systemName: "circle"), .private, frame: .zero)
        guard let captureButton else { return }
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.handler = { [weak self] button in
            guard let self,
                  let coloursCollectionView = self.coloursCollectionView,
                  let colour = self.colour else { return }
            
            let colours = coloursCollectionView.colours() ?? []
            
            if colours.count == 5 {
                UINotificationFeedbackGenerator(view: optionsButton).notificationOccurred(.success)
                if let imageView = optionsButton.imageView, let image: UIImage = .init(systemName: "swatchpalette")?
                    .applyingSymbolConfiguration(.init(hierarchicalColor: .label))?
                    .applyingSymbolConfiguration(.init(weight: .bold)) {
                    imageView.setSymbolImage(image, contentTransition: .replace) { context in
                        guard let sender = context.sender as? UIImageView, let image: UIImage = .init(systemName: "ellipsis")?
                            .applyingSymbolConfiguration(.init(hierarchicalColor: .label))?
                            .applyingSymbolConfiguration(.init(weight: .bold)) else { return }
                        sender.setSymbolImage(image, contentTransition: .replace)
                    }
                }
            }
            
            if colours.count == 8 {
                let checkered: String = if #available(iOS 18, *) {
                    "circle.bottomrighthalf.pattern.checkered"
                } else {
                    "circle.bottomrighthalf.checkered"
                }
                
                UINotificationFeedbackGenerator(view: optionsButton).notificationOccurred(.success)
                if let imageView = optionsButton.imageView, let image: UIImage = .init(systemName: checkered)?
                    .applyingSymbolConfiguration(.init(hierarchicalColor: .label))?
                    .applyingSymbolConfiguration(.init(weight: .bold)) {
                    imageView.setSymbolImage(image, contentTransition: .replace) { context in
                        guard let sender = context.sender as? UIImageView, let image: UIImage = .init(systemName: "ellipsis")?
                            .applyingSymbolConfiguration(.init(hierarchicalColor: .label))?
                            .applyingSymbolConfiguration(.init(weight: .bold)) else { return }
                        sender.setSymbolImage(image, contentTransition: .replace)
                    }
                }
            }
            
            if ![5, 8].contains(colours.count) {
                UIImpactFeedbackGenerator(view: button).impactOccurred()
            }
            coloursCollectionView.add(colour)
            self.colour = nil
        }
        previewView.addSubview(captureButton)
        
        captureButton.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        captureButton.trailingAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        coloursCollectionView = .init(collectionViewLayout)
        guard let coloursCollectionView else { return }
        coloursCollectionView.translatesAutoresizingMaskIntoConstraints = false
        coloursCollectionView.cameraController = self
        previewView.addSubview(coloursCollectionView)
        
        coloursCollectionView.leadingAnchor.constraint(equalTo: optionsButton.safeAreaLayoutGuide.trailingAnchor, constant: 12).isActive = true
        coloursCollectionView.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        coloursCollectionView.trailingAnchor.constraint(equalTo: captureButton.safeAreaLayoutGuide.leadingAnchor, constant: -12).isActive = true
        coloursCollectionView.heightAnchor.constraint(equalTo: captureButton.safeAreaLayoutGuide.heightAnchor).isActive = true
        
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
            for await shouldDisplay in ellipsisTip.shouldDisplayUpdates {
                if shouldDisplay {
                    let controller = TipUIPopoverViewController(ellipsisTip, sourceItem: optionsButton)
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

extension CameraController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let palettes = UserDefaults.standard.array(forKey: "palettes") as? [[String]]
        
        let browsePalettesAction: UIAction = .init(title: "Browse Palettes",
                                                   subtitle: "Under Construction",
                                                   image: .init(systemName: "swatchpalette"),
                                                   attributes: .disabled,
                                                   handler: { _ in })
        
        guard let coloursCollectionView, let colours = coloursCollectionView.colours(), colours.count >= 6 else {
            var children: [UIAction] = []
            if let _ = palettes {
                children.append(browsePalettesAction)
            }
            
            return .init(actionProvider: { elements in
                .init(children: children)
            })
        }
        
        var children: [UIAction] = [
            .init(title: "Save Palette",
                  image: .init(systemName: "swatchpalette"),
                  handler: { _ in
                      if var palettes {
                          palettes.append(colours)
                          UserDefaults.standard.set(palettes, forKey: "palettes")
                      } else {
                          UserDefaults.standard.set([colours], forKey: "palettes")
                      }
                  })
        ]
        
        if let _ = palettes {
            children.prepend(browsePalettesAction)
        }
        
        let checkered: String = if #available(iOS 18, *) {
            "circle.bottomrighthalf.pattern.checkered"
        } else {
            "circle.bottomrighthalf.checkered"
        }
        
        var gradientChildren: [UIAction] = []
        if colours.count == 9 {
            gradientChildren.append(.init(title: "Create Gradient", image: .init(systemName: checkered), handler: { [weak self] _ in
                guard let self else { return }
                
                let coloursController: ColourController = .init(colours)
                coloursController.modalPresentationStyle = .fullScreen
                self.present(coloursController, animated: true)
            }))
        }
        
        return .init(actionProvider: { elements in
            .init(children: [
                UIMenu(options: .displayInline, children: gradientChildren),
                UIMenu(options: .displayInline, children: children)
            ])
        })
    }
}
