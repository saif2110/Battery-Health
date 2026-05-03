//
//  DublicatesTableViewCell.swift
//  Cleaner
//
//  Created by Alexey on 19.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

protocol DublicatesTableViewCellDelegate {
    func deleteAssetes(toDelete: [PHAsset])
}

final class DublicatesTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var dubsCollectionView: UICollectionView!

    var indexPath: Int = 0 {
        didSet { groupLabel.text = "Group \(indexPath + 1)" }
    }
    var duplicates: [PHAsset]? { didSet { refreshGroupMetadata() } }
    var currentId = 0
    var previewAsset: PHAsset?
    var previewId = 0
    var delegate: DublicatesTableViewCellDelegate?
    var selectedImageIndex: Int = 0

    private let accent = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)

    // New programmatic UI elements
    private let groupLabel = UILabel()
    private let savingsPill = UIView()
    private let savingsLabel = UILabel()
    private let savingsIcon = UIImageView()
    private let hintLabel = UILabel()
    private let keepButton = UIButton(type: .custom)
    private let keeperBadge = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        dubsCollectionView.delegate = self
        dubsCollectionView.dataSource = self
        dubsCollectionView.allowsSelection = true
        dubsCollectionView.delaysContentTouches = false
        dubsCollectionView.canCancelContentTouches = true
        rebuildLayout()
    }

    // MARK: - Modern Layout

    private func rebuildLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Capture the storyboard collection view (it carries the prototype cell registration).
        let cv = dubsCollectionView!
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false

        // Wipe storyboard subviews so we can lay out from scratch.
        contentView.subviews.forEach { $0.removeFromSuperview() }

        // ── Card ──────────────────────────────────────────
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Top row: group label + savings pill ──────────
        groupLabel.font = .systemFont(ofSize: 17, weight: .bold)
        groupLabel.textColor = .label
        groupLabel.text = "Group 1"
        groupLabel.translatesAutoresizingMaskIntoConstraints = false

        savingsPill.backgroundColor = accent.withAlphaComponent(0.15)
        savingsPill.layer.cornerRadius = 12
        savingsPill.layer.cornerCurve = .continuous
        savingsPill.translatesAutoresizingMaskIntoConstraints = false

        let pillIconConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        savingsIcon.image = UIImage(systemName: "sparkles", withConfiguration: pillIconConfig)
        savingsIcon.tintColor = accent
        savingsIcon.contentMode = .scaleAspectFit
        savingsIcon.translatesAutoresizingMaskIntoConstraints = false

        savingsLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        savingsLabel.textColor = accent
        savingsLabel.text = "0 duplicates"
        savingsLabel.translatesAutoresizingMaskIntoConstraints = false

        savingsPill.addSubview(savingsIcon)
        savingsPill.addSubview(savingsLabel)

        NSLayoutConstraint.activate([
            savingsIcon.leadingAnchor.constraint(equalTo: savingsPill.leadingAnchor, constant: 10),
            savingsIcon.centerYAnchor.constraint(equalTo: savingsPill.centerYAnchor),
            savingsIcon.widthAnchor.constraint(equalToConstant: 12),
            savingsIcon.heightAnchor.constraint(equalToConstant: 12),

            savingsLabel.leadingAnchor.constraint(equalTo: savingsIcon.trailingAnchor, constant: 5),
            savingsLabel.centerYAnchor.constraint(equalTo: savingsPill.centerYAnchor),
            savingsLabel.trailingAnchor.constraint(equalTo: savingsPill.trailingAnchor, constant: -10),
            savingsLabel.topAnchor.constraint(equalTo: savingsPill.topAnchor, constant: 6),
            savingsLabel.bottomAnchor.constraint(equalTo: savingsPill.bottomAnchor, constant: -6),
        ])

        // ── Hero preview ────────────────────────────────
        let hero = UIImageView()
        hero.contentMode = .scaleAspectFill
        hero.clipsToBounds = true
        hero.layer.cornerRadius = 18
        hero.layer.cornerCurve = .continuous
        hero.backgroundColor = .tertiarySystemBackground
        hero.translatesAutoresizingMaskIntoConstraints = false
        previewImageView = hero

        // ── Keeper badge overlay on hero (bottom-left) ──
        keeperBadge.backgroundColor = accent
        keeperBadge.layer.cornerRadius = 16
        keeperBadge.layer.cornerCurve = .continuous
        keeperBadge.layer.shadowColor = UIColor.black.cgColor
        keeperBadge.layer.shadowOpacity = 0.20
        keeperBadge.layer.shadowOffset = CGSize(width: 0, height: 2)
        keeperBadge.layer.shadowRadius = 6
        keeperBadge.translatesAutoresizingMaskIntoConstraints = false

        let keeperIconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let keeperIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: keeperIconConfig))
        keeperIcon.tintColor = .white
        keeperIcon.contentMode = .scaleAspectFit
        keeperIcon.translatesAutoresizingMaskIntoConstraints = false

        let keeperLabel = UILabel()
        keeperLabel.text = "Keeper"
        keeperLabel.font = .systemFont(ofSize: 13, weight: .bold)
        keeperLabel.textColor = .white
        keeperLabel.translatesAutoresizingMaskIntoConstraints = false

        keeperBadge.addSubview(keeperIcon)
        keeperBadge.addSubview(keeperLabel)

        NSLayoutConstraint.activate([
            keeperIcon.leadingAnchor.constraint(equalTo: keeperBadge.leadingAnchor, constant: 10),
            keeperIcon.centerYAnchor.constraint(equalTo: keeperBadge.centerYAnchor),
            keeperIcon.widthAnchor.constraint(equalToConstant: 14),
            keeperIcon.heightAnchor.constraint(equalToConstant: 14),

            keeperLabel.leadingAnchor.constraint(equalTo: keeperIcon.trailingAnchor, constant: 5),
            keeperLabel.trailingAnchor.constraint(equalTo: keeperBadge.trailingAnchor, constant: -10),
            keeperLabel.centerYAnchor.constraint(equalTo: keeperBadge.centerYAnchor),
            keeperLabel.topAnchor.constraint(equalTo: keeperBadge.topAnchor, constant: 6),
            keeperLabel.bottomAnchor.constraint(equalTo: keeperBadge.bottomAnchor, constant: -6),
        ])

        // ── Hint label ─────────────────────────────────
        hintLabel.text = "Tap any thumbnail to choose the keeper"
        hintLabel.font = .systemFont(ofSize: 12, weight: .medium)
        hintLabel.textColor = .secondaryLabel
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── CTA button ─────────────────────────────────
        keepButton.setTitle("Keep & Delete Others", for: .normal)
        keepButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        keepButton.setTitleColor(.white, for: .normal)
        keepButton.backgroundColor = accent
        keepButton.layer.cornerRadius = 14
        keepButton.layer.cornerCurve = .continuous
        keepButton.translatesAutoresizingMaskIntoConstraints = false
        keepButton.addTarget(self, action: #selector(saveThisAction), for: .touchUpInside)

        let trashConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        keepButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: trashConfig), for: .normal)
        keepButton.tintColor = .white
        keepButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        keepButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)

        // ── Add subviews ───────────────────────────────
        [groupLabel, savingsPill, hero, keeperBadge, hintLabel, cv, keepButton].forEach { card.addSubview($0) }

        // ── Constraints ────────────────────────────────
        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            // Header row
            groupLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            groupLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),

            savingsPill.centerYAnchor.constraint(equalTo: groupLabel.centerYAnchor),
            savingsPill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),

            // Hero
            hero.topAnchor.constraint(equalTo: groupLabel.bottomAnchor, constant: 12),
            hero.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            hero.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            hero.heightAnchor.constraint(equalTo: hero.widthAnchor, multiplier: 0.62),

            // Keeper badge
            keeperBadge.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 12),
            keeperBadge.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -12),

            // Hint
            hintLabel.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 14),
            hintLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            hintLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            // Duplicate strip
            cv.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 10),
            cv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            cv.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            cv.heightAnchor.constraint(equalToConstant: 96),

            // CTA
            keepButton.topAnchor.constraint(equalTo: cv.bottomAnchor, constant: 14),
            keepButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            keepButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            keepButton.heightAnchor.constraint(equalToConstant: 50),
            keepButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
    }

    private func refreshGroupMetadata() {
        let count = max(0, (duplicates?.count ?? 0) - 1)
        savingsLabel.text = count == 1 ? "1 duplicate" : "\(count) duplicates"
        let title = count == 1 ? "Keep & Delete 1 Other" : "Keep & Delete \(count) Others"
        keepButton.setTitle(title, for: .normal)
    }

    // MARK: - Actions

    @IBAction func saveThisAction() {
        if let duplicates = self.duplicates {
            var toDelete: [PHAsset] = []
            for i in duplicates where i != previewAsset {
                toDelete.append(i)
            }
            if toDelete.count == duplicates.count {
                toDelete.remove(at: 0)
            }
            self.delegate?.deleteAssetes(toDelete: toDelete)
        }
    }

    // MARK: - Reload / Reuse

    func reload(duplicates: [PHAsset]) {
        if duplicates == self.duplicates { return }
        self.duplicates = duplicates
        selectedImageIndex = 0
        previewAsset = nil
        dubsCollectionView.reloadData()
        setPreview()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func willRemoveSubview(_ subview: UIView) {
        ImageManager.cancelImageRequest(id: currentId)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.previewAsset = nil
    }

    func setPreview() {
        previewAsset = previewAsset ?? duplicates?.first
        guard let asset = previewAsset else {
            previewImageView.image = nil
            return
        }
        currentId = ImageManager.takeImageFromAsset(asset: asset, completion: { photo, id in
            DispatchQueue.main.async {
                if self.currentId == id {
                    self.previewImageView.image = photo
                    self.layoutIfNeeded()
                }
            }
        })
    }

    // MARK: - Collection (duplicate thumbnails)

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return duplicates?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DublicateCollectionViewCell
        ImageManager.cancelImageRequest(id: cell.currentId)
        let asset = duplicates![indexPath.item]
        cell.photoAsset = asset
        let isKeeper = asset.localIdentifier == previewAsset?.localIdentifier
        cell.configureKeeperState(isKeeper)
        cell.reload()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dup = duplicates, indexPath.item >= 0, indexPath.item < dup.count else { return }
        let asset = dup[indexPath.item]
        selectedImageIndex = indexPath.item

        for visible in collectionView.visibleCells {
            guard let c = visible as? DublicateCollectionViewCell, let a = c.photoAsset else { continue }
            let isKeeper = a.localIdentifier == asset.localIdentifier
            c.configureKeeperState(isKeeper)
        }

        if let tapped = collectionView.cellForItem(at: indexPath) as? DublicateCollectionViewCell {
            UIView.animate(withDuration: 0.05, animations: {
                tapped.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            }) { _ in
                UIView.animate(withDuration: 0.18) {
                    tapped.transform = .identity
                }
            }
        }

        let sameAsPreview = asset.localIdentifier == previewAsset?.localIdentifier
        if !sameAsPreview {
            previewAsset = asset
            setPreview()
        }
        collectionView.reloadData()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
