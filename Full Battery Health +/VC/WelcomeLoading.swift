//
//  WelcomeLoading.swift
//  Full Battery Health
//
//  Created by Saif on 06/05/26.
//

import UIKit

class WelcomeLoading: UIViewController {

    private let themeGreen = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 1.0)
    private let titleGreen = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1.0)

    private struct Phase {
        let title: String
        let subtitle: String
    }

    private let phases: [Phase] = [
        Phase(title: "Analyzing Battery Health", subtitle: "Checking charging cycles and capacity"),
        Phase(title: "Optimizing Cleanup", subtitle: "Scanning storage for junk and duplicates"),
        Phase(title: "Setting Up Smart Alerts", subtitle: "Configuring charge level notifications"),
        Phase(title: "Finalizing Your Profile", subtitle: "Almost there — preparing recommendations")
    ]

    private let ringSize: CGFloat = 220
    private let ringLineWidth: CGFloat = 10

    private let ringHost = UIView()
    private let percentLabel = UILabel()
    private let completeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dotsStack = UIStackView()

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private let duration: CFTimeInterval = 6.0
    private var didComplete = false
    private var currentPhaseIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildUI()
        buildRings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
    }

    private func buildUI() {
        let ringContainer = UIView()
        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ringContainer)

        ringHost.translatesAutoresizingMaskIntoConstraints = false
        ringHost.backgroundColor = .clear
        ringContainer.addSubview(ringHost)

        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.text = "0%"
        percentLabel.font = .systemFont(ofSize: 56, weight: .light)
        percentLabel.textColor = .white
        percentLabel.textAlignment = .center
        ringContainer.addSubview(percentLabel)

        completeLabel.translatesAutoresizingMaskIntoConstraints = false
        completeLabel.text = "Complete"
        completeLabel.font = .systemFont(ofSize: 16, weight: .regular)
        completeLabel.textColor = titleGreen
        completeLabel.textAlignment = .center
        ringContainer.addSubview(completeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = phases[0].title
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = phases[0].subtitle
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)

        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        dotsStack.axis = .horizontal
        dotsStack.spacing = 8
        dotsStack.alignment = .center
        for _ in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
            dot.layer.cornerRadius = 5
            dot.backgroundColor = themeGreen.withAlphaComponent(0.3)
            dotsStack.addArrangedSubview(dot)
        }
        view.addSubview(dotsStack)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            ringContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ringContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            ringContainer.widthAnchor.constraint(equalToConstant: ringSize),
            ringContainer.heightAnchor.constraint(equalToConstant: ringSize),

            ringHost.topAnchor.constraint(equalTo: ringContainer.topAnchor),
            ringHost.leadingAnchor.constraint(equalTo: ringContainer.leadingAnchor),
            ringHost.trailingAnchor.constraint(equalTo: ringContainer.trailingAnchor),
            ringHost.bottomAnchor.constraint(equalTo: ringContainer.bottomAnchor),

            percentLabel.centerXAnchor.constraint(equalTo: ringContainer.centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: ringContainer.centerYAnchor, constant: -10),

            completeLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 2),
            completeLabel.centerXAnchor.constraint(equalTo: ringContainer.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: ringContainer.bottomAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),

            dotsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func buildRings() {
        let radius = (ringSize - ringLineWidth) / 2
        let center = CGPoint(x: ringSize / 2, y: ringSize / 2)
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true).cgPath

        trackLayer.path = path
        trackLayer.frame = CGRect(x: 0, y: 0, width: ringSize, height: ringSize)
        trackLayer.strokeColor = UIColor(white: 0.18, alpha: 1.0).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = ringLineWidth
        trackLayer.lineCap = .round
        ringHost.layer.addSublayer(trackLayer)

        progressLayer.path = path
        progressLayer.frame = CGRect(x: 0, y: 0, width: ringSize, height: ringSize)
        progressLayer.strokeColor = themeGreen.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = ringLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        ringHost.layer.addSublayer(progressLayer)
    }

    private func startProgress() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = CGFloat(min(max(elapsed / duration, 0), 1))

        let percent = Int(progress * 100)
        if percentLabel.text != "\(percent)%" {
            percentLabel.text = "\(percent)%"
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = progress
        CATransaction.commit()

        let phaseIndex = min(Int(progress * CGFloat(phases.count)), phases.count - 1)
        if phaseIndex != currentPhaseIndex {
            currentPhaseIndex = phaseIndex
            crossfade(label: titleLabel, to: phases[phaseIndex].title)
            crossfade(label: subtitleLabel, to: phases[phaseIndex].subtitle)
        }

        let activeDot = min(Int(progress * 3), 2)
        for (i, v) in dotsStack.arrangedSubviews.enumerated() {
            let target: UIColor = (i == activeDot) ? themeGreen : themeGreen.withAlphaComponent(0.3)
            if v.backgroundColor != target { v.backgroundColor = target }
        }

        if progress >= 1.0 && !didComplete {
            didComplete = true
            displayLink?.invalidate()
            displayLink = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.goToIAP()
            }
        }
    }

    private func crossfade(label: UILabel, to text: String) {
        UIView.transition(with: label, duration: 0.35, options: [.transitionCrossDissolve], animations: {
            label.text = text
        })
    }

    private func goToIAP() {
        let vc = Apps15init.shared.makeIAPVC()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
