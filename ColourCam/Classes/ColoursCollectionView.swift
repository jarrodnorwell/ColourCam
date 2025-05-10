//
//  ColoursCollectionView.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 8/5/2025.
//

import Foundation
import UIKit

class ColoursCollectionView : UIView {
    var visualEffectView: UIVisualEffectView? = nil
    var collectionView: UICollectionView? = nil
    
    var dataSource: UICollectionViewDiffableDataSource<String, UIColor>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, UIColor>? = nil
    
    var collectionViewLayout: CollectionViewLayout = .init()
    var cameraController: CameraController? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: .private)
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        collectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout.layout)
        guard let collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        visualEffectView.contentView.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor, constant: 6).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: 6).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor, constant: -6).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -6).isActive = true
        
        let cellRegistration: UICollectionView.CellRegistration<ColourCell, UIColor> = .init { $0.set($2) }
        
        dataSource = .init(collectionView: collectionView) { $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2) }
        
        snapshot = .init()
        guard let dataSource, var snapshot else { return }
        snapshot.appendSections(["Colours"])
        Task { await dataSource.apply(snapshot) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        if let collectionView {
            collectionView.layer.cornerRadius = layer.cornerRadius - 6
        }
        layoutIfNeeded()
    }
    
    func add(_ colour: UIColor) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([colour], toSection: "Colours")
        Task {
            await dataSource.apply(snapshot)
            
            guard let collectionView,
                  let indexPath = dataSource.indexPath(for: colour) else { return }
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
}

extension ColoursCollectionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource,
              let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath) as? ColourCell,
              let colour = cell.backgroundColor else { return nil }
        
        return .init(actionProvider: { elements in
            .init(children: [
                UIMenu(options: .displayInline, children: [
                    UIAction(title: "Open in Fullscreen", image: .init(systemName: "rectangle.expand.vertical"), handler: { [weak self] _ in
                        guard let self, let cameraController = self.cameraController else { return }
                        
                        let colourController: ColourController = .init(colour)
                        colourController.modalPresentationStyle = .fullScreen
                        cameraController.present(colourController, animated: true)
                    })
                ]),
                UIAction(title: "Copy HEX", image: .init(systemName: "pencil.and.list.clipboard"), handler: { [weak self] _ in
                    UIPasteboard.general.string = colour.hex
                    guard let self, let cameraController = self.cameraController else { return }
                    
                    let alertController: UIAlertController = .init(title: "Copied to Pasteboard",
                                                                   message: "\(colour.hex) copied to the pasteboard",
                                                                   preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    cameraController.present(alertController, animated: true)
                }),
                UIAction(title: "Copy RGBA", image: .init(systemName: "pencil.and.list.clipboard"), handler: { [weak self] _ in
                    UIPasteboard.general.string = colour.rgba
                    guard let self, let cameraController = self.cameraController else { return }
                    
                    let alertController: UIAlertController = .init(title: "Copied to Pasteboard",
                                                                   message: "\(colour.rgba) copied to the pasteboard",
                                                                   preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    cameraController.present(alertController, animated: true)
                }),
                UIMenu(options: .displayInline, children: [
                    UIAction(title: "Delete Colour", image: .init(systemName: "trash"), attributes: .destructive, handler: { _ in
                        var snapshot = dataSource.snapshot()
                        snapshot.deleteItems([colour])
                        Task { await dataSource.apply(snapshot) }
                    })
                ])
            ])
        })
    }
}
