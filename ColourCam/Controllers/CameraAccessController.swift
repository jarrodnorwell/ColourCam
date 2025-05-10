//
//  CameraAccessController.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 6/5/2025.
//

import AVFoundation
import Foundation
import SwiftUI
import UIKit

class CameraAccessController: UIViewController {
    var imageView: UIImageView? = nil
    var label: UILabel? = nil, secondaryLabel: UILabel? = nil,
        tertiaryLabel: UILabel? = nil
    var button: FakeButton? = nil
    
    private var cameraAccess: CameraAccess
    init(_ cameraAccess: CameraAccess) {
        self.cameraAccess = cameraAccess
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = nil
        
        var title: String = "Allow Access"
        Task {
            title = switch await cameraAccess.status {
            case .authorized: "Authorised"
            case .denied, .restricted: "Open Settings"
            default: title
            }
            
            guard let button else { return }
            button.set(title)
        }
        
        let meshGradientView: UIHostingController = .init(rootView: MeshGradientView())
        addChild(meshGradientView)
        meshGradientView.view.frame = view.frame
        view.addSubview(meshGradientView.view)
        meshGradientView.didMove(toParent: self)
        
        let visualEffectView: UIVisualEffectView = .init(effect: UIVibrancyEffect(blurEffect: .init(style: .systemMaterialDark)))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: meshGradientView.view.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: meshGradientView.view.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: meshGradientView.view.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: meshGradientView.view.trailingAnchor).isActive = true
        
        let hierarchicalColor: UIColor = if traitCollection.userInterfaceStyle == .dark {
            .white
        } else {
            .black
        }
        
        imageView = .init(image: .init(systemName: "camera.fill")?
            .applyingSymbolConfiguration(.init(hierarchicalColor: hierarchicalColor)))
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        visualEffectView.contentView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 3).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        label = .init(frame: .zero)
        guard let label else { return }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bold(.extraLargeTitle)
        label.text = "ColourCam"
        label.textAlignment = .center
        label.textColor = .label
        visualEffectView.contentView.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        label.centerYAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.safeAreaLayoutGuide.topAnchor, constant: -20).isActive = true
        
        secondaryLabel = .init(frame: .zero)
        guard let secondaryLabel else { return }
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = .preferredFont(forTextStyle: .body)
        secondaryLabel.numberOfLines = 3
        secondaryLabel.text = "Capture colour information from the world around you in real-time"
        secondaryLabel.textAlignment = .center
        secondaryLabel.textColor = .secondaryLabel
        visualEffectView.contentView.addSubview(secondaryLabel)
        
        secondaryLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        secondaryLabel.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        secondaryLabel.topAnchor.constraint(equalTo: label.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
        
        tertiaryLabel = .init(frame: .zero)
        guard let tertiaryLabel else { return }
        tertiaryLabel.translatesAutoresizingMaskIntoConstraints = false
        tertiaryLabel.font = .preferredFont(forTextStyle: .footnote)
        tertiaryLabel.numberOfLines = 3
        tertiaryLabel.text = "Colour values will not always be accurate, please take these values as rough approximations"
        tertiaryLabel.textAlignment = .center
        tertiaryLabel.textColor = .tertiaryLabel
        visualEffectView.contentView.addSubview(tertiaryLabel)
        
        tertiaryLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        tertiaryLabel.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        tertiaryLabel.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        let centeringView: UIView = .init(frame: .zero)
        centeringView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centeringView)
        
        centeringView.topAnchor.constraint(equalTo: secondaryLabel.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        centeringView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        centeringView.bottomAnchor.constraint(equalTo: tertiaryLabel.safeAreaLayoutGuide.topAnchor, constant: -20).isActive = true
        centeringView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        button = .init(title, frame: .zero)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.handler = { [weak self] button in
            UIImpactFeedbackGenerator(view: button).impactOccurred()
            
            Task {
                guard let self else { return }
                if await self.cameraAccess.authorised {
                    let cameraController: CameraController = .init()
                    cameraController.modalPresentationStyle = .fullScreen
                    self.present(cameraController, animated: true)
                } else {
                    if await self.cameraAccess.authorise() {
                        let cameraController: CameraController = .init()
                        cameraController.modalPresentationStyle = .fullScreen
                        self.present(cameraController, animated: true)
                    } else {
                        if let url: URL = .init(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        view.addSubview(button)
        
        button.centerYAnchor.constraint(equalTo: centeringView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    var animationHasPlayed: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !animationHasPlayed {
            guard let imageView else { return }
            imageView.addSymbolEffect(.bounce)
            
            animationHasPlayed.toggle()
        }
    }
    
    override var prefersStatusBarHidden: Bool { true }
}
