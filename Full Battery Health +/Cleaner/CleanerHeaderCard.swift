//
//  CleanerHeaderCard.swift
//  Full Battery Health
//
//  Modern header card used across the cleaner detail screens
//  (Duplicate Photos, Screenshots, Large Videos).
//

import UIKit

final class CleanerHeaderCard: UIView {

    let countLabel = UILabel()
    let sizeLabel = UILabel()
    let countCaptionLabel = UILabel()
    let sizeCaptionLabel = UILabel()
    let primaryButton = UIButton(type: .custom)

    private let card = UIView()
    private var primaryAction: (() -> Void)?

    init(icon: String,
         accent: UIColor,
         title: String,
         countCaption: String,
         sizeCaption: String,
         buttonTitle: String,
         helpText: String,
         onPrimary: @escaping () -> Void) {
        super.init(frame: .zero)
        primaryAction = onPrimary
        translatesAutoresizingMaskIntoConstraints = false
        build(icon: icon, accent: accent, title: title,
              countCaption: countCaption, sizeCaption: sizeCaption,
              buttonTitle: buttonTitle, helpText: helpText)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func build(icon: String, accent: UIColor, title: String,
                       countCaption: String, sizeCaption: String,
                       buttonTitle: String, helpText: String) {

        backgroundColor = .clear

        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        // Icon badge
        let iconBg = UIView()
        iconBg.backgroundColor = accent.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 12
        iconBg.layer.cornerCurve = .continuous
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)))
        iconView.tintColor = accent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stats row: count | size
        let countCell = makeStat(value: countLabel, caption: countCaptionLabel,
                                 captionText: countCaption, accent: accent)
        let sizeCell = makeStat(value: sizeLabel, caption: sizeCaptionLabel,
                                captionText: sizeCaption, accent: accent)

        countLabel.text = "0"
        sizeLabel.text = "0 MB"

        let statsStack = UIStackView(arrangedSubviews: [countCell, sizeCell])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        // Primary button
        primaryButton.setTitle(buttonTitle, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = accent
        primaryButton.layer.cornerRadius = 14
        primaryButton.layer.cornerCurve = .continuous
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        // Help text
        let helpLabel = UILabel()
        helpLabel.text = helpText
        helpLabel.font = .systemFont(ofSize: 12)
        helpLabel.textColor = .secondaryLabel
        helpLabel.numberOfLines = 0
        helpLabel.textAlignment = .center
        helpLabel.translatesAutoresizingMaskIntoConstraints = false

        [iconBg, titleLabel, statsStack, primaryButton, helpLabel].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.widthAnchor.constraint(equalToConstant: 48),
            iconBg.heightAnchor.constraint(equalToConstant: 48),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            statsStack.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            statsStack.heightAnchor.constraint(equalToConstant: 64),

            primaryButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 14),
            primaryButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: 50),

            helpLabel.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 10),
            helpLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            helpLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            helpLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
    }

    private func makeStat(value: UILabel, caption: UILabel,
                          captionText: String, accent: UIColor) -> UIView {
        let cell = UIView()
        cell.backgroundColor = UIColor.tertiarySystemBackground
        cell.layer.cornerRadius = 14
        cell.layer.cornerCurve = .continuous
        cell.translatesAutoresizingMaskIntoConstraints = false

        caption.text = captionText
        caption.font = .systemFont(ofSize: 11, weight: .medium)
        caption.textColor = .secondaryLabel
        caption.translatesAutoresizingMaskIntoConstraints = false

        value.font = .systemFont(ofSize: 18, weight: .bold)
        value.textColor = .label
        value.adjustsFontSizeToFitWidth = true
        value.minimumScaleFactor = 0.6
        value.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(caption)
        cell.addSubview(value)

        NSLayoutConstraint.activate([
            caption.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
            caption.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 12),
            caption.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -12),

            value.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 4),
            value.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 12),
            value.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -12),
            value.bottomAnchor.constraint(lessThanOrEqualTo: cell.bottomAnchor, constant: -10),
        ])
        return cell
    }

    @objc private func primaryTapped() { primaryAction?() }
}

// MARK: - Selection bar (Screenshots & Videos bottom action bar)

final class CleanerSelectionBar: UIView {

    let countLabel = UILabel()
    let primaryButton = UIButton(type: .custom)

    private var primaryAction: (() -> Void)?

    init(buttonTitle: String, accent: UIColor, onPrimary: @escaping () -> Void) {
        super.init(frame: .zero)
        primaryAction = onPrimary
        translatesAutoresizingMaskIntoConstraints = false
        build(buttonTitle: buttonTitle, accent: accent)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func build(buttonTitle: String, accent: UIColor) {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowOffset = CGSize(width: 0, height: -2)
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        // Selection badge
        let badge = UIView()
        badge.backgroundColor = accent.withAlphaComponent(0.15)
        badge.layer.cornerRadius = 14
        badge.layer.cornerCurve = .continuous
        badge.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = .systemFont(ofSize: 18, weight: .bold)
        countLabel.textColor = accent
        countLabel.text = "0"
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(countLabel)

        let badgeCaption = UILabel()
        badgeCaption.text = "selected"
        badgeCaption.font = .systemFont(ofSize: 13, weight: .medium)
        badgeCaption.textColor = .secondaryLabel
        badgeCaption.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.setTitle(buttonTitle, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = .systemRed
        primaryButton.layer.cornerRadius = 14
        primaryButton.layer.cornerCurve = .continuous
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        let trashConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        primaryButton.setImage(UIImage(systemName: "trash", withConfiguration: trashConfig), for: .normal)
        primaryButton.tintColor = .white
        primaryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        primaryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)

        [badge, badgeCaption, primaryButton].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            badge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 50),
            badge.heightAnchor.constraint(equalToConstant: 50),

            countLabel.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            badgeCaption.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 10),
            badgeCaption.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            primaryButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            primaryButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 46),
            primaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 130),

            card.heightAnchor.constraint(equalToConstant: 78),
        ])
    }

    @objc private func primaryTapped() { primaryAction?() }
}
