//
//  CollectionViewLayout.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 9/5/2025.
//

import Foundation
import UIKit

struct CollectionViewLayout {
    var colours: UICollectionViewCompositionalLayout {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.interSectionSpacing = 6
        
        return .init(sectionProvider: { sectionIndex, layoutEnvironment in
            let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .estimated(100),
                                                                       heightDimension: .fractionalHeight(1)))
            
            let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .estimated(100),
                                                                               heightDimension: .fractionalHeight(1)),
                                                             subitems: [item])
            group.interItemSpacing = .fixed(6)
            
            let section: NSCollectionLayoutSection = .init(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 6
            return section
        }, configuration: configuration)
    }
}
