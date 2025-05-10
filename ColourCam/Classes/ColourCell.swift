//
//  ColourCell.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 9/5/2025.
//

import Foundation
import UIKit

class ColourCell : UICollectionViewCell {
    var label: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        label = .init()
        guard let label else { return }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bold(.body)
        label.textAlignment = .center
        addSubview(label)
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func set(_ colour: UIColor) {
        backgroundColor = colour
        
        guard let label else { return }
        label.text = colour.hex
        label.textColor = if colour.isLight {
            colour.darker
        } else {
            colour.lighter
        }
    }
}
