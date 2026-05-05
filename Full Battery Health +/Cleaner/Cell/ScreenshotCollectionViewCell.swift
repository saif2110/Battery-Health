//
//  ScreenshotCollectionViewCell.swift
//  Cleaner
//
//  Created by Alexey on 20.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

final class ScreenshotCollectionViewCell: UICollectionViewCell {

    var currentId = 0
    var showedId = ""

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!

    var photoAsset: ImageObject?

    // New programmatic UI
    private let card = UIView()
    private let thumb = UIImageView()
    private let dateLabel = UILabel()
    private let sizeLabel = UILabel()
    private let selectCircle = UIView()
    private let selectMark = UILabel()

    private let accent = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)
    private var isMarked = false

    override func awakeFromNib() {
        super.awakeFromNib()
        rebuildAsListRow()
    }

    private func rebuildAsListRow() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.masksToBounds = false

        // Hide every storyboard subview — we lay out from scratch.
        imageView?.isHidden = true
        labelView?.isHidden = true
        contentView.subviews.forEach { $0.isHidden = true }

        let thumbSide: CGFloat = 96
        let selectSide: CGFloat = 26

        // ── Card ──────────────────────────────────────────
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = kChromeCornerRadius
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Thumbnail ────────────────────────────────────
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = kChromeCornerRadius
        thumb.layer.cornerCurve = .continuous
        thumb.backgroundColor = .tertiarySystemBackground
        thumb.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(thumb)
        // Re-point legacy IBOutlet so any external code that touches it still works.
        imageView = thumb

        // ── Text labels (no title row; date + size only) ─
        dateLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 2
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        sizeLabel.font = .systemFont(ofSize: 17, weight: .bold)
        sizeLabel.textColor = accent
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        labelView = sizeLabel

        [dateLabel, sizeLabel].forEach { card.addSubview($0) }

        // ── Selection circle ─────────────────────────────
        selectCircle.translatesAutoresizingMaskIntoConstraints = false
        selectCircle.layer.cornerRadius = selectSide / 2
        selectCircle.layer.borderWidth = 2
        selectCircle.layer.borderColor = UIColor.tertiaryLabel.cgColor
        selectCircle.backgroundColor = .clear
        card.addSubview(selectCircle)

        selectMark.translatesAutoresizingMaskIntoConstraints = false
        selectMark.font = .systemFont(ofSize: 14, weight: .bold)
        selectMark.textAlignment = .center
        selectMark.text = ""
        selectMark.textColor = .white
        selectCircle.addSubview(selectMark)

        // ── Constraints ──────────────────────────────────
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            thumb.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            thumb.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumb.widthAnchor.constraint(equalToConstant: thumbSide),
            thumb.heightAnchor.constraint(equalToConstant: thumbSide),

            dateLabel.topAnchor.constraint(equalTo: thumb.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: selectCircle.leadingAnchor, constant: -16),

            sizeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 14),
            sizeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),

            selectCircle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            selectCircle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            selectCircle.widthAnchor.constraint(equalToConstant: selectSide),
            selectCircle.heightAnchor.constraint(equalToConstant: selectSide),

            selectMark.centerXAnchor.constraint(equalTo: selectCircle.centerXAnchor),
            selectMark.centerYAnchor.constraint(equalTo: selectCircle.centerYAnchor),
        ])
    }

    func configureSelectionState(_ isSelected: Bool) {
        isMarked = isSelected
        if isSelected {
            selectCircle.backgroundColor = accent
            selectCircle.layer.borderColor = accent.cgColor
            selectMark.text = "✓"
            card.layer.borderColor = accent.cgColor
            card.layer.borderWidth = 1.5
        } else {
            selectCircle.backgroundColor = .clear
            selectCircle.layer.borderColor = UIColor.tertiaryLabel.cgColor
            selectMark.text = ""
            card.layer.borderColor = UIColor.clear.cgColor
            card.layer.borderWidth = 0
        }
    }

    func reload() {
        guard let item = photoAsset, let asset = item.asset else { return }

        dateLabel.text = Self.formattedDate(item.date)
        sizeLabel.text = Formatter.humanReadableByteCount(bytes: item.size)

        if showedId != asset.localIdentifier {
            currentId = ImageManager.takeImageFromAsset(asset: asset, completion: { [weak self] photo, id in
                DispatchQueue.main.async {
                    guard let self = self, id == self.currentId else { return }
                    self.thumb.image = photo
                    self.showedId = asset.localIdentifier
                }
            })
        }
    }

    private static func formattedDate(_ date: Date) -> String {
        let cal = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        if cal.isDateInToday(date) {
            return "Today · \(timeFormatter.string(from: date))"
        }
        if cal.isDateInYesterday(date) {
            return "Yesterday · \(timeFormatter.string(from: date))"
        }
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ImageManager.cancelImageRequest(id: currentId)
        configureSelectionState(false)
        thumb.image = nil
        showedId = ""
    }
}
