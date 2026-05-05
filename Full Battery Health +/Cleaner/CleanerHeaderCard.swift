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
         compactMetrics: Bool = false,
         onPrimary: @escaping () -> Void) {
        super.init(frame: .zero)
        primaryAction = onPrimary
        translatesAutoresizingMaskIntoConstraints = false
        build(icon: icon, accent: accent, title: title,
              countCaption: countCaption, sizeCaption: sizeCaption,
              buttonTitle: buttonTitle, helpText: helpText,
              compactMetrics: compactMetrics)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func build(icon: String, accent: UIColor, title: String,
                       countCaption: String, sizeCaption: String,
                       buttonTitle: String, helpText: String,
                       compactMetrics: Bool) {

        backgroundColor = .clear

        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = kChromeCornerRadius
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
        iconBg.layer.cornerRadius = kChromeCornerRadius
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
        primaryButton.layer.cornerRadius = kChromeCornerRadius
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

        let iconTop: CGFloat = compactMetrics ? 14 : 18
        let iconToStats: CGFloat = compactMetrics ? 12 : 16
        let statsHeight: CGFloat = compactMetrics ? 58 : 64
        let statsToButton: CGFloat = compactMetrics ? 10 : 14
        let buttonHeight: CGFloat = compactMetrics ? 46 : 50
        let buttonToHelp: CGFloat = compactMetrics ? 6 : 10
        let helpBottom: CGFloat = compactMetrics ? 10 : 16

        [iconBg, titleLabel, statsStack, primaryButton, helpLabel].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: iconTop),
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

            statsStack.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: iconToStats),
            statsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            statsStack.heightAnchor.constraint(equalToConstant: statsHeight),

            primaryButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: statsToButton),
            primaryButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight),

            helpLabel.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: buttonToHelp),
            helpLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            helpLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            helpLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -helpBottom),
        ])
    }

    private func makeStat(value: UILabel, caption: UILabel,
                          captionText: String, accent: UIColor) -> UIView {
        let cell = UIView()
        cell.backgroundColor = UIColor.tertiarySystemBackground
        cell.layer.cornerRadius = kChromeCornerRadius
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
        card.layer.cornerRadius = kChromeCornerRadius
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
        badge.layer.cornerRadius = kChromeCornerRadius
        badge.layer.cornerCurve = .continuous
        badge.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = .systemFont(ofSize: 22, weight: .bold)
        countLabel.textColor = accent
        countLabel.text = "0"
        countLabel.textAlignment = .center
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.65
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(countLabel)

        let badgeCaption = UILabel()
        badgeCaption.text = "selected"
        badgeCaption.font = .systemFont(ofSize: 17, weight: .semibold)
        badgeCaption.textColor = .secondaryLabel
        badgeCaption.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        badgeCaption.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.setContentHuggingPriority(.required, for: .horizontal)
        primaryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        var deleteConfig = UIButton.Configuration.filled()
        deleteConfig.baseBackgroundColor = .systemRed
        deleteConfig.baseForegroundColor = .white
        deleteConfig.cornerStyle = .fixed
        deleteConfig.background.cornerRadius = kChromeCornerRadius
        let trashImage = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        deleteConfig.image = trashImage
        deleteConfig.title = buttonTitle
        deleteConfig.imagePlacement = .leading
        deleteConfig.imagePadding = 4
        deleteConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        deleteConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        primaryButton.configuration = deleteConfig

        [badge, badgeCaption, primaryButton].forEach { card.addSubview($0) }

        let barHeight: CGFloat = 56
        let badgeSize: CGFloat = 40
        let primaryH: CGFloat = 36

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 6),
            badge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 38),
            badge.heightAnchor.constraint(equalToConstant: badgeSize),

            countLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 3),
            countLabel.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -3),
            countLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            badgeCaption.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 5),
            badgeCaption.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            primaryButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -6),
            primaryButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: primaryH),
            primaryButton.leadingAnchor.constraint(greaterThanOrEqualTo: badgeCaption.trailingAnchor, constant: 6),

            card.heightAnchor.constraint(equalToConstant: barHeight),
        ])
    }

    @objc private func primaryTapped() { primaryAction?() }
}

// MARK: - List section header (Screenshots & Large Videos)

final class CleanerListSectionHeader: UICollectionReusableView {

    static let reuseId = "CleanerListSectionHeader"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16.5, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(label)
        let g = layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, accent: UIColor) {
        label.text = title
        label.textColor = accent
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    }
}
