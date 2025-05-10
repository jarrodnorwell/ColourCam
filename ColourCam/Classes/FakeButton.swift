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
    
    init(_ text: String, _ style: UIBlurEffect.Style = .systemMaterialLight, frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: UIBlurEffect(style: style))
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        label = .init()
        guard let label else { return }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        label.text = text
        label.textAlignment = .center
        label.textColor = if style == .systemMaterialLight {
            .darkText
        } else {
            .label
        }
        visualEffectView.contentView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor, constant: 12).isActive = true
        label.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor, constant: -12).isActive = true
        label.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -20).isActive = true
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
}
