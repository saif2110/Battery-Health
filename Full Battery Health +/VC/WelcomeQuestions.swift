//
//  WelcomeQuestions.swift
//  Full Battery Health
//
//  Created by Saif on 06/05/26.
//

import UIKit

class WelcomeQuestions: UIViewController {

    private struct Question {
        let title: String
        let options: [String]
    }

    private let questions: [Question] = [
        Question(title: "How often does your battery drain quickly?",
                 options: ["Very often", "Often", "Sometimes", "Rarely", "Never"]),
        Question(title: "How long do you typically use your phone daily?",
                 options: ["Less than 2 hours", "2 – 4 hours", "4 – 6 hours", "6 – 8 hours", "More than 8 hours"]),
        Question(title: "What drains your battery the most?",
                 options: ["Apps & games", "Streaming videos", "Social media", "Calls & messages", "Mixed use"]),
        Question(title: "Is your phone storage almost full?",
                 options: ["Yes, completely full", "Mostly full", "About half full", "Mostly free", "Plenty of space"]),
        Question(title: "What concerns you most about your phone?",
                 options: ["Battery health", "Storage space", "Performance", "Security", "All of the above"])
    ]

    private let themeGreen = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 1.0)
    private let titleGreen = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1.0)

    private var currentIndex = 0
    private var selectedIndex: Int? = nil

    private let counterLabel = UILabel()
    private let questionLabel = UILabel()
    private let optionsStack = UIStackView()
    private let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        render()
    }

    private func setupUI() {
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
        counterLabel.font = .systemFont(ofSize: 16, weight: .regular)
        view.addSubview(counterLabel)

        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.textColor = titleGreen
        questionLabel.font = .boldSystemFont(ofSize: 28)
        questionLabel.numberOfLines = 0
        view.addSubview(questionLabel)

        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        optionsStack.axis = .vertical
        optionsStack.spacing = 12
        optionsStack.alignment = .fill
        optionsStack.distribution = .fill
        view.addSubview(optionsStack)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 27.5
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            counterLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

            questionLabel.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

            optionsStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 28),
            optionsStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            optionsStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),

            nextButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            nextButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    private func render() {
        let q = questions[currentIndex]
        counterLabel.text = "Question \(currentIndex + 1)/\(questions.count)"
        questionLabel.text = q.title

        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx, option) in q.options.enumerated() {
            let btn = makeOptionButton(title: option, tag: idx)
            optionsStack.addArrangedSubview(btn)
        }
        selectedIndex = nil
        updateNextButton()
    }

    private func makeOptionButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        btn.layer.cornerRadius = 27
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func optionTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        for case let b as UIButton in optionsStack.arrangedSubviews {
            if b.tag == sender.tag {
                b.layer.borderColor = themeGreen.cgColor
                b.backgroundColor = themeGreen.withAlphaComponent(0.25)
            } else {
                b.layer.borderColor = UIColor.clear.cgColor
                b.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            }
        }
        updateNextButton()
    }

    private func updateNextButton() {
        let enabled = selectedIndex != nil
        nextButton.isEnabled = enabled
        nextButton.backgroundColor = enabled ? themeGreen : UIColor(white: 0.3, alpha: 1.0)
        let isLast = currentIndex == questions.count - 1
        nextButton.setTitle(isLast ? "Finish" : "Next", for: .normal)
    }

    @objc private func nextTapped() {
        guard selectedIndex != nil else { return }
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            render()
        } else {
            let vc = WelcomeReview()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
