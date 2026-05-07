//
//  WelcomeReview.swift
//  Full Battery Health
//
//  Created by Saif on 06/05/26.
//

import UIKit
import StoreKit

class WelcomeReview: UIViewController {

    private let themeGreen = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 1.0)
    private let titleGreen = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1.0)
    private let starGold = UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0)
    private let cardBG = UIColor(white: 0.12, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.requestStoreReview()
        }
    }

    private func requestStoreReview() {
        if #available(iOS 14.0, *) {
            if let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
                return
            }
        }
        SKStoreReviewController.requestReview()
    }

    private func buildUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let continueBtn = UIButton(type: .system)
        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.setTitle("Continue", for: .normal)
        continueBtn.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.backgroundColor = themeGreen
        continueBtn.layer.cornerRadius = 27.5
        continueBtn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueBtn)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: safe.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: continueBtn.topAnchor, constant: -10),

            continueBtn.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            continueBtn.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),
            continueBtn.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -20),
            continueBtn.heightAnchor.constraint(equalToConstant: 55),

            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Help us to improve!"
        title.font = .boldSystemFont(ofSize: 30)
        title.textColor = .white
        title.textAlignment = .center
        content.addSubview(title)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Your feedback helps us"
        subtitle.font = .systemFont(ofSize: 16)
        subtitle.textColor = UIColor(white: 0.7, alpha: 1.0)
        subtitle.textAlignment = .center
        content.addSubview(subtitle)

        let starsRow = makeStarsRow(count: 5, color: themeGreen, size: 32)
        starsRow.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(starsRow)

        let madeFor = UILabel()
        madeFor.translatesAutoresizingMaskIntoConstraints = false
        madeFor.text = "This app was designed for users like you."
        madeFor.font = .systemFont(ofSize: 16)
        madeFor.textColor = UIColor(white: 0.7, alpha: 1.0)
        madeFor.textAlignment = .center
        content.addSubview(madeFor)

        let usersCount = UILabel()
        usersCount.translatesAutoresizingMaskIntoConstraints = false
        usersCount.text = "+ 50,000 users"
        usersCount.font = .boldSystemFont(ofSize: 17)
        usersCount.textColor = titleGreen
        usersCount.textAlignment = .center
        content.addSubview(usersCount)

        let avatarsStack = UIStackView()
        avatarsStack.translatesAutoresizingMaskIntoConstraints = false
        avatarsStack.axis = .horizontal
        avatarsStack.spacing = 10
        avatarsStack.alignment = .center
        avatarsStack.distribution = .equalSpacing
        for i in 1...5 {
            avatarsStack.addArrangedSubview(makeAvatar(name: "p\(i)", size: 50))
        }
        content.addSubview(avatarsStack)

        let card1 = makeReviewCard(
            avatarName: "p1",
            name: "Mike Jobs",
            handle: "@mikejobs",
            stars: 5,
            text: "\"My battery used to die before lunch. After using this app's smart charging alerts and cleanup, my phone easily lasts a full day now!\""
        )
        let card2 = makeReviewCard(
            avatarName: "p2",
            name: "Lisa Wen",
            handle: "@lisawen",
            stars: 4,
            text: "\"Cleaning out duplicate photos and screenshots freed up 8GB on my phone. Everything feels faster — totally worth it.\""
        )
        let card3 = makeReviewCard(
            avatarName: "p3",
            name: "Daniel Park",
            handle: "@danielp",
            stars: 5,
            text: "\"The battery health stats and overcharge alerts are spot on. My phone's battery is finally lasting like new again.\""
        )
        card1.translatesAutoresizingMaskIntoConstraints = false
        card2.translatesAutoresizingMaskIntoConstraints = false
        card3.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(card1)
        content.addSubview(card2)
        content.addSubview(card3)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            subtitle.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            starsRow.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 14),
            starsRow.centerXAnchor.constraint(equalTo: content.centerXAnchor),

            madeFor.topAnchor.constraint(equalTo: starsRow.bottomAnchor, constant: 14),
            madeFor.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            madeFor.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            usersCount.topAnchor.constraint(equalTo: madeFor.bottomAnchor, constant: 4),
            usersCount.centerXAnchor.constraint(equalTo: content.centerXAnchor),

            avatarsStack.topAnchor.constraint(equalTo: usersCount.bottomAnchor, constant: 14),
            avatarsStack.centerXAnchor.constraint(equalTo: content.centerXAnchor),

            card1.topAnchor.constraint(equalTo: avatarsStack.bottomAnchor, constant: 22),
            card1.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            card1.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            card2.topAnchor.constraint(equalTo: card1.bottomAnchor, constant: 14),
            card2.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            card2.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            card3.topAnchor.constraint(equalTo: card2.bottomAnchor, constant: 14),
            card3.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            card3.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            card3.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16)
        ])
    }

    private func makeStarsRow(count: Int, color: UIColor, size: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        for _ in 0..<count {
            let iv = UIImageView(image: UIImage(systemName: "star.fill"))
            iv.tintColor = color
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: size).isActive = true
            iv.heightAnchor.constraint(equalToConstant: size).isActive = true
            stack.addArrangedSubview(iv)
        }
        return stack
    }

    private func makeAvatar(name: String, size: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: size).isActive = true
        container.heightAnchor.constraint(equalToConstant: size).isActive = true

        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = size / 2
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        iv.layer.borderWidth = 2
        iv.layer.borderColor = themeGreen.withAlphaComponent(0.4).cgColor
        if let img = UIImage(named: name) {
            iv.image = img
        } else {
            iv.image = UIImage(systemName: "person.fill")
            iv.tintColor = .gray
        }
        container.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeReviewCard(avatarName: String, name: String, handle: String, stars: Int, text: String) -> UIView {
        let card = UIView()
        card.backgroundColor = cardBG
        card.layer.cornerRadius = 14

        let avatar = makeAvatar(name: avatarName, size: 44)

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = .white

        let badge = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.tintColor = themeGreen
        badge.contentMode = .scaleAspectFit
        badge.widthAnchor.constraint(equalToConstant: 16).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let handleLabel = UILabel()
        handleLabel.translatesAutoresizingMaskIntoConstraints = false
        handleLabel.text = handle
        handleLabel.font = .systemFont(ofSize: 13)
        handleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)

        let starsView = makeStarsRow(count: stars, color: starGold, size: 14)
        starsView.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.translatesAutoresizingMaskIntoConstraints = false
        body.text = text
        body.font = .systemFont(ofSize: 14)
        body.textColor = UIColor(white: 0.85, alpha: 1.0)
        body.numberOfLines = 0

        let nameRow = UIStackView(arrangedSubviews: [nameLabel, badge])
        nameRow.translatesAutoresizingMaskIntoConstraints = false
        nameRow.axis = .horizontal
        nameRow.spacing = 4
        nameRow.alignment = .center

        card.addSubview(avatar)
        card.addSubview(nameRow)
        card.addSubview(handleLabel)
        card.addSubview(starsView)
        card.addSubview(body)

        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            nameRow.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            nameRow.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),

            handleLabel.topAnchor.constraint(equalTo: nameRow.bottomAnchor, constant: 2),
            handleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),

            starsView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            starsView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            starsView.leadingAnchor.constraint(greaterThanOrEqualTo: nameRow.trailingAnchor, constant: 8),

            body.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 12),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    @objc private func continueTapped() {
        let vc = WelcomeLoading()
        navigationController?.pushViewController(vc, animated: true)
    }
}
