//
//  ColourController.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 10/5/2025.
//

import Foundation
import SwiftUI
import UIKit

class ColourController : UIViewController {
    var button: FakeButton? = nil
    var meshGradientView: UIHostingController<MeshGradientView>? = nil
    
    var colour: UIColor? = nil
    var colours: [String]? = nil
    init(_ colour: UIColor? = nil) {
        self.colour = colour
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ colours: [String]? = nil) {
        self.colours = colours
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if let colour {
            view.backgroundColor = colour
        } else if let colours {
            meshGradientView = .init(rootView: MeshGradientView(colours))
            guard let meshGradientView else { return }
            meshGradientView.view.translatesAutoresizingMaskIntoConstraints = false
            addChild(meshGradientView)
            view.addSubview(meshGradientView.view)
            meshGradientView.didMove(toParent: self)
            
            meshGradientView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            meshGradientView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            meshGradientView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            meshGradientView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        button = .init("Dismiss", .private, frame: .zero)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.handler = { [weak self] button in
            UIImpactFeedbackGenerator(view: button).impactOccurred()
            
            guard let self else { return }
            self.dismiss(animated: true)
        }
        (meshGradientView?.view ?? view).addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: (meshGradientView?.view ?? view).safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.centerXAnchor.constraint(equalTo: (meshGradientView?.view ?? view).safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    override var prefersStatusBarHidden: Bool { true }
}
