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
    
    var cameraController: CameraController? = nil
    
    init(_ collectionViewLayout: CollectionViewLayout, frame: CGRect = .zero) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: .private)
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        collectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout.colours)
        guard let collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        visualEffectView.contentView.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 6).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -6).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -6).isActive = true
        
        let cellRegistration: UICollectionView.CellRegistration<ColourCell, UIColor> = .init { $0.set($2) }
        
        dataSource = .init(collectionView: collectionView) { $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2) }
        
        let color1 = UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0) // soft red
        let color2 = UIColor(red: 0.95, green: 0.65, blue: 0.35, alpha: 1.0) // orange
        let color3 = UIColor(red: 0.95, green: 0.85, blue: 0.35, alpha: 1.0) // golden yellow
        let color4 = UIColor(red: 0.65, green: 0.95, blue: 0.35, alpha: 1.0) // lime green
        let color5 = UIColor(red: 0.35, green: 0.95, blue: 0.65, alpha: 1.0) // mint green
        let color6 = UIColor(red: 0.35, green: 0.95, blue: 0.95, alpha: 1.0) // cyan
        let color7 = UIColor(red: 0.35, green: 0.65, blue: 0.95, alpha: 1.0) // sky blue
        let color8 = UIColor(red: 0.65, green: 0.35, blue: 0.95, alpha: 1.0) // violet
        let color9 = UIColor(red: 0.95, green: 0.35, blue: 0.85, alpha: 1.0) // pink

        let gradientColors = [
            color1, color2, color3, color4, color5,
            color6, color7, color8, color9
        ]
        
        snapshot = .init()
        guard let dataSource, var snapshot else { return }
        snapshot.appendSections(["Colours"])
#if targetEnvironment(simulator)
        snapshot.appendItems(gradientColors, toSection: "Colours")
#endif
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
    
    func colours() -> [String]? {
        guard let dataSource else { return nil }
        let snapshot = dataSource.snapshot()
        return snapshot.itemIdentifiers.map { $0.hex }
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
