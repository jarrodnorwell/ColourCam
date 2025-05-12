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
        
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func set(_ string: String) {
        guard let hex = UInt32(string.replacingOccurrences(of: "#", with: ""), radix: 16) else { return }
        let colour: UIColor = .fromHex(hex)
        
        backgroundColor = colour
        
        guard let label else { return }
        label.text = colour.hex
        label.textColor = if colour.isLight {
            colour.darker
        } else {
            colour.lighter
        }
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
