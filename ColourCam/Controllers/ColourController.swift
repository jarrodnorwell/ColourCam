//
//  ColourController.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 10/5/2025.
//

import Foundation
import UIKit

class ColourController : UIViewController {
    var button: FakeButton? = nil
    
    var colour: UIColor
    init(_ colour: UIColor) {
        self.colour = colour
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colour
        
        button = .init("Dismiss", UIBlurEffect.Style(rawValue: 1100) ?? .systemUltraThinMaterial, frame: .zero)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.handler = { [weak self] button in
            UIImpactFeedbackGenerator(view: button).impactOccurred()
            
            guard let self else { return }
            self.dismiss(animated: true)
        }
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
}
