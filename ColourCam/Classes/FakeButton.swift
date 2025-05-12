//
//  FakeButton.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 9/5/2025.
//

import Dispatch
import Foundation
import UIKit

class FakeButton : UIView {
    var handler: ((FakeButton) -> Void)? = nil
    
    var visualEffectView: UIVisualEffectView? = nil
    var label: UILabel? = nil
    var imageView: UIImageView? = nil
    
    init(_ image: UIImage? = nil, _ style: UIBlurEffect.Style = .systemMaterialLight, frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: UIBlurEffect(style: style))
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView = .init(image: image?
            .applyingSymbolConfiguration(.init(hierarchicalColor: .label))?
            .applyingSymbolConfiguration(.init(weight: .bold)))
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        visualEffectView.contentView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        imageView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    init(_ text: String, _ style: UIBlurEffect.Style = .systemMaterialLight, frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: UIBlurEffect(style: style))
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        label = .init()
        guard let label else { return }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bold(.body)
        label.text = text
        label.textAlignment = .center
        label.textColor = if style == .systemMaterialLight {
            .darkText
        } else {
            .label
        }
        visualEffectView.contentView.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let handler else { return }
        handler(self)
    }
    
    func set(_ text: String) {
        guard let label else { return }
        label.text = text
    }
    
    func set(_ image: UIImage? = nil) {
        guard let imageView else { return }
        imageView.image = image
    }
}
