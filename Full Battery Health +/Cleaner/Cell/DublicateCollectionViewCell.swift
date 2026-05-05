//
//  DublicateCollectionViewCell.swift
//  Cleaner
//
//  Created by Alexey on 19.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

final class DublicateCollectionViewCell: UICollectionViewCell {

    var currentId = 0
    var showedId = ""
    var parentCell: DublicatesTableViewCell?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedImageview: UIImageView!

    var photoAsset: PHAsset?

    private let stateBadge = UIView()
    private let stateLabel = UILabel()
    private let keeperRing = CAShapeLayer()

    private let accent = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupOverlay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        keeperRing.frame = contentView.bounds
        keeperRing.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 1.5, dy: 1.5),
                                       cornerRadius: kChromeCornerRadius).cgPath
    }

    private func setupOverlay() {
        // Hide the legacy storyboard tick image — we render our own modern badge.
        selectedImageview?.isHidden = true

        // Green keeper ring (drawn around the whole cell when this is the keeper).
        keeperRing.fillColor = UIColor.clear.cgColor
        keeperRing.strokeColor = accent.cgColor
        keeperRing.lineWidth = 3
        keeperRing.isHidden = true
        contentView.layer.addSublayer(keeperRing)

        // Floating state badge in the top-right corner — transparent (no background circle).
        stateBadge.translatesAutoresizingMaskIntoConstraints = false
        stateBadge.backgroundColor = .clear
        contentView.addSubview(stateBadge)

        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.font = .systemFont(ofSize: 18)
        stateLabel.textAlignment = .center
        // Soft shadow on the emoji itself so it stays legible over bright photos.
        stateLabel.layer.shadowColor = UIColor.black.cgColor
        stateLabel.layer.shadowOpacity = 0.45
        stateLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        stateLabel.layer.shadowRadius = 2
        stateBadge.addSubview(stateLabel)

        NSLayoutConstraint.activate([
            stateBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stateBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            stateBadge.widthAnchor.constraint(equalToConstant: 26),
            stateBadge.heightAnchor.constraint(equalToConstant: 26),

            stateLabel.centerXAnchor.constraint(equalTo: stateBadge.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: stateBadge.centerYAnchor),
        ])
    }

    func configureKeeperState(_ isKeeper: Bool) {
        if isKeeper {
            keeperRing.isHidden = false
            stateLabel.text = "✅"
            stateLabel.font = .systemFont(ofSize: 18)
            contentView.alpha = 1.0
        } else {
            keeperRing.isHidden = true
            stateLabel.text = "🗑"
            stateLabel.font = .systemFont(ofSize: 16)
            contentView.alpha = 0.85
        }
        contentView.bringSubviewToFront(stateBadge)
    }

    func reload() {
        if let asset = photoAsset {
            if showedId != asset.localIdentifier {
                currentId = ImageManager.takeImageFromAsset(asset: asset, completion: { photo, id in
                    DispatchQueue.main.async {
                        if id == self.currentId {
                            self.imageView.image = photo
                            self.showedId = asset.localIdentifier
                        }
                    }
                })
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ImageManager.cancelImageRequest(id: currentId)
        contentView.alpha = 1.0
        keeperRing.isHidden = true
    }
}
