//
//  CleanerScanLoadingView.swift
//  Full Battery Health
//

import UIKit

/// Full-screen overlay with blur, spinner, determinate progress, and helper text for Cleaner scans.
final class CleanerScanLoadingView: UIView {
    private let blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.secondarySystemGroupedBackground
        v.layer.cornerRadius = kChromeCornerRadius
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 24
        return v
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.hidesWhenStopped = false
        return s
    }()

    private let progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .bar)
        p.translatesAutoresizingMaskIntoConstraints = false
        p.progressTintColor = UIColor.systemGreen
        p.trackTintColor = UIColor.tertiarySystemFill
        p.progress = 0
        p.layer.cornerRadius = 4
        p.clipsToBounds = true
        return p
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .headline)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.textColor = .label
        return l
    }()

    private let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.textColor = .secondaryLabel
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isUserInteractionEnabled = true

        addSubview(blurView)
        addSubview(card)
        card.addSubview(spinner)
        card.addSubview(titleLabel)
        card.addSubview(detailLabel)
        card.addSubview(progressView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 340),

            spinner.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            spinner.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            progressView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            progressView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 6),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    func configure(title: String, detail: String = "Large libraries take longer. You can leave this screen open.") {
        titleLabel.text = title
        detailLabel.text = detail
    }

    func setProgress(_ value: Float, animated: Bool = true) {
        let clamped = max(0, min(1, value))
        progressView.setProgress(clamped, animated: animated)
    }

    func attach(to host: UIView) {
        host.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: host.topAnchor),
            leadingAnchor.constraint(equalTo: host.leadingAnchor),
            trailingAnchor.constraint(equalTo: host.trailingAnchor),
            bottomAnchor.constraint(equalTo: host.bottomAnchor),
        ])
        alpha = 0
        spinner.startAnimating()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        spinner.stopAnimating()
        let remove = {
            self.removeFromSuperview()
            completion?()
        }
        guard animated else {
            remove()
            return
        }
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
        } completion: { _ in
            remove()
        }
    }
}
