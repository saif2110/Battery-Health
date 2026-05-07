//
//  InAppVC2.swift
//  Full Battery Health
//
//  Created by Saif on 06/05/26.
//

import UIKit
import Purchases
import SafariServices
import InAppPurchase
import StoreKit

class InAppVC2: UIViewController {

    private let themeGreen = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 1.0)
    private let titleGreen = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1.0)
    private let cardBG = UIColor(white: 0.10, alpha: 1.0)
    private let cardSelectedBG = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 0.18)

    private var yearlyPackage: Purchases.Package?
    private var weeklyPackage: Purchases.Package?

    /// 0 = Yearly card (BatteryHealthProYear), 1 = 3-day trial / weekly card (BatteryHealthProWeek).
    private var selectedIndex = 1

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let dismissButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let yearlyCard = UIView()
    private let trialCard = UIView()
    private let yearlyRadio = UIImageView()
    private let trialRadio = UIImageView()
    private let yearlyPriceLabel = UILabel()
    private let trialPriceLabel = UILabel()
    private let ctaButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildUI()
        loadProducts()
        updateSelection(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Apps15init.shared.HSB {
            dismissButton.fadeIn()
        }
    }

    // MARK: - UI

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle("Start Trial", for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = themeGreen
        ctaButton.layer.cornerRadius = 27.5
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        view.addSubview(ctaButton)

        let footerStack = makeFooterRow()
        view.addSubview(footerStack)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -10),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            ctaButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            ctaButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            ctaButton.bottomAnchor.constraint(equalTo: footerStack.topAnchor, constant: -10),
            ctaButton.heightAnchor.constraint(equalToConstant: 55),

            footerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerStack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8)
        ])

        // Close (X) — initially hidden, fades in via Apps15init.HSB flag.
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor(white: 0.7, alpha: 1.0)
        dismissButton.alpha = 0
        dismissButton.isHidden = true
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            dismissButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 32),
            dismissButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Hero PRO image.
        let heroImage = UIImageView()
        heroImage.translatesAutoresizingMaskIntoConstraints = false
        heroImage.image = UIImage(named: "pro") ?? UIImage(named: "pro_banner")
        heroImage.contentMode = .scaleAspectFit
        contentView.addSubview(heroImage)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Unlock All Access"
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        // Feature rows.
        let features: [(String, String)] = [
            ("battery.100", "Smart battery alerts"),
            ("trash.circle.fill", "Junk file & cache cleanup"),
            ("photo.on.rectangle.angled", "Duplicate photo cleaner"),
            ("waveform.path.ecg.rectangle", "Battery health analytics"),
            //("nosign", "No ads, all features unlocked")
        ]
        let featuresStack = UIStackView()
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        featuresStack.spacing = 14
        featuresStack.alignment = .fill
        for (icon, text) in features {
            featuresStack.addArrangedSubview(makeFeatureRow(icon: icon, text: text))
        }
        contentView.addSubview(featuresStack)

        // Plan cards.
        configureYearlyCard()
        configureTrialCard()
        contentView.addSubview(yearlyCard)
        contentView.addSubview(trialCard)

        NSLayoutConstraint.activate([
            heroImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            heroImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            heroImage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
            heroImage.heightAnchor.constraint(equalToConstant: 240),

            titleLabel.topAnchor.constraint(equalTo: heroImage.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            featuresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            featuresStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            featuresStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            yearlyCard.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 24),
            yearlyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            yearlyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            yearlyCard.heightAnchor.constraint(equalToConstant: 62),

            trialCard.topAnchor.constraint(equalTo: yearlyCard.bottomAnchor, constant: 10),
            trialCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trialCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trialCard.heightAnchor.constraint(equalToConstant: 62),
            trialCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func makeFeatureRow(icon: String, text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false

        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = themeGreen
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0

        row.addArrangedSubview(iv)
        row.addArrangedSubview(label)
        return row
    }

    private func configureYearlyCard() {
        yearlyCard.translatesAutoresizingMaskIntoConstraints = false
        yearlyCard.layer.cornerRadius = 14
        yearlyCard.layer.borderWidth = 1.5
        yearlyCard.backgroundColor = cardBG

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Yearly Plan"
        title.font = .boldSystemFont(ofSize: 17)
        title.textColor = .white

        yearlyPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        yearlyPriceLabel.text = "Loading…"
        yearlyPriceLabel.font = .systemFont(ofSize: 14)
        yearlyPriceLabel.textColor = UIColor(white: 0.7, alpha: 1.0)

        let saveBadge = UILabel()
        saveBadge.translatesAutoresizingMaskIntoConstraints = false
        saveBadge.text = "  SAVE 90%  "
        saveBadge.font = .boldSystemFont(ofSize: 12)
        saveBadge.textColor = .white
        saveBadge.backgroundColor = themeGreen
        saveBadge.layer.cornerRadius = 8
        saveBadge.layer.masksToBounds = true
        saveBadge.textAlignment = .center

        yearlyRadio.translatesAutoresizingMaskIntoConstraints = false
        yearlyRadio.contentMode = .scaleAspectFit
        yearlyRadio.tintColor = themeGreen

        yearlyCard.addSubview(title)
        yearlyCard.addSubview(yearlyPriceLabel)
        yearlyCard.addSubview(saveBadge)
        yearlyCard.addSubview(yearlyRadio)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: yearlyCard.topAnchor, constant: 9),
            title.leadingAnchor.constraint(equalTo: yearlyCard.leadingAnchor, constant: 16),

            yearlyPriceLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            yearlyPriceLabel.leadingAnchor.constraint(equalTo: yearlyCard.leadingAnchor, constant: 16),
            yearlyPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: saveBadge.leadingAnchor, constant: -8),

            saveBadge.centerYAnchor.constraint(equalTo: yearlyCard.centerYAnchor),
            saveBadge.trailingAnchor.constraint(equalTo: yearlyRadio.leadingAnchor, constant: -10),
            saveBadge.heightAnchor.constraint(equalToConstant: 24),

            yearlyRadio.centerYAnchor.constraint(equalTo: yearlyCard.centerYAnchor),
            yearlyRadio.trailingAnchor.constraint(equalTo: yearlyCard.trailingAnchor, constant: -16),
            yearlyRadio.widthAnchor.constraint(equalToConstant: 24),
            yearlyRadio.heightAnchor.constraint(equalToConstant: 24)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(yearlyCardTapped))
        yearlyCard.addGestureRecognizer(tap)
        yearlyCard.isUserInteractionEnabled = true
    }

    private func configureTrialCard() {
        trialCard.translatesAutoresizingMaskIntoConstraints = false
        trialCard.layer.cornerRadius = 14
        trialCard.layer.borderWidth = 1.5
        trialCard.backgroundColor = cardBG

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "3-Days Trial"
        title.font = .boldSystemFont(ofSize: 17)
        title.textColor = .white

        trialPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        trialPriceLabel.text = "Then locked premium access"
        trialPriceLabel.font = .systemFont(ofSize: 14)
        trialPriceLabel.textColor = UIColor(white: 0.7, alpha: 1.0)

        trialRadio.translatesAutoresizingMaskIntoConstraints = false
        trialRadio.contentMode = .scaleAspectFit
        trialRadio.tintColor = themeGreen

        trialCard.addSubview(title)
        trialCard.addSubview(trialPriceLabel)
        trialCard.addSubview(trialRadio)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: trialCard.topAnchor, constant: 9),
            title.leadingAnchor.constraint(equalTo: trialCard.leadingAnchor, constant: 16),

            trialPriceLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            trialPriceLabel.leadingAnchor.constraint(equalTo: trialCard.leadingAnchor, constant: 16),
            trialPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: trialRadio.leadingAnchor, constant: -8),

            trialRadio.centerYAnchor.constraint(equalTo: trialCard.centerYAnchor),
            trialRadio.trailingAnchor.constraint(equalTo: trialCard.trailingAnchor, constant: -16),
            trialRadio.widthAnchor.constraint(equalToConstant: 24),
            trialRadio.heightAnchor.constraint(equalToConstant: 24)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(trialCardTapped))
        trialCard.addGestureRecognizer(tap)
        trialCard.isUserInteractionEnabled = true
    }

    private func makeFooterRow() -> UIStackView {
        let restore = UIButton(type: .system)
        restore.setTitle("Restore", for: .normal)
        restore.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        restore.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
        restore.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)

        let terms = UIButton(type: .system)
        terms.setTitle("Terms of Use & Privacy Policy", for: .normal)
        terms.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        terms.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
        terms.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [restore, terms])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 18
        stack.alignment = .center
        return stack
    }

    // MARK: - Selection state

    private func updateSelection(animated: Bool) {
        let yearlySelected = selectedIndex == 0
        let trialSelected = selectedIndex == 1

        let apply = {
            self.yearlyCard.backgroundColor = yearlySelected ? self.cardSelectedBG : self.cardBG
            self.yearlyCard.layer.borderColor = (yearlySelected ? self.themeGreen : UIColor.clear).cgColor
            self.trialCard.backgroundColor = trialSelected ? self.cardSelectedBG : self.cardBG
            self.trialCard.layer.borderColor = (trialSelected ? self.themeGreen : UIColor.clear).cgColor
            self.yearlyRadio.image = UIImage(systemName: yearlySelected ? "checkmark.circle.fill" : "circle")
            self.trialRadio.image = UIImage(systemName: trialSelected ? "checkmark.circle.fill" : "circle")
            self.ctaButton.setTitle(trialSelected ? "Start Trial" : "Continue", for: .normal)
        }
        if animated {
            UIView.animate(withDuration: 0.18, animations: apply)
        } else {
            apply()
        }
    }

    // MARK: - Actions

    @objc private func yearlyCardTapped() {
        selectedIndex = 0
        updateSelection(animated: true)
    }

    @objc private func trialCardTapped() {
        selectedIndex = 1
        updateSelection(animated: true)
    }

    @objc private func dismissTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func ctaTapped() {
        let pkg = (selectedIndex == 0) ? yearlyPackage : weeklyPackage
        guard let package = pkg else { return }
        startIndicator(selfo: self)
        Purchases.shared.purchasePackage(package) { [weak self] (_, purchaserInfo, _, _) in
            guard let self = self else { return }
            let ents = purchaserInfo?.entitlements.all
            let isPro = ents?[IPA.OneYearPro.rawValue]?.isActive == true
                || ents?[IPA.Year.rawValue]?.isActive == true
                || ents?[IPA.Week.rawValue]?.isActive == true
            if isPro {
                self.purchaseComplete()
            } else {
                stopIndicator()
            }
        }
    }

    @objc private func restoreTapped() {
        let iap = InAppPurchase.default
        iap.restore { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                if !products.isEmpty {
                    self.purchaseComplete()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc private func termsTapped() {
        let url = URL(string: "https://apps15.com/termsofuse.html")!
        present(SFSafariViewController(url: url), animated: true)
    }

    // MARK: - Products

    private func loadProducts() {
        Purchases.shared.offerings { [weak self] offerings, _ in
            guard let self = self, let offerings = offerings else { return }

            // Resolve packages by offering ID first, falling back to scanning the
            // current/all offerings for the matching product identifier — keeps this
            // robust to either "one-offering-per-product" or "single offering with
            // multiple packages" RevenueCat configurations.
            self.yearlyPackage = self.findPackage(in: offerings, productId: IPA.Year.rawValue)
            self.weeklyPackage = self.findPackage(in: offerings, productId: IPA.Week.rawValue)

            if let yp = self.yearlyPackage {
                self.yearlyPriceLabel.text = "\(yp.localizedPriceString) annually"
            } else {
                self.yearlyPriceLabel.text = "Yearly subscription"
            }

            if let wp = self.weeklyPackage {
                self.trialPriceLabel.text = "Then \(wp.localizedPriceString) per week"
            } else {
                self.trialPriceLabel.text = "3 days free, then weekly"
            }
            stopIndicator()
        }
    }

    private func findPackage(in offerings: Purchases.Offerings, productId: String) -> Purchases.Package? {
        // Strict match: the package's actual product identifier must equal `productId`.
        // (An offering named the same as `productId` may still contain a *different* product
        // — e.g. the old lifetime SKU — so we can't trust the offering name alone.)
        let matches: (Purchases.Package) -> Bool = { $0.product.productIdentifier == productId }

        if let pkg = offerings[productId]?.availablePackages.first(where: matches) {
            return pkg
        }
        if let pkg = offerings.current?.availablePackages.first(where: matches) {
            return pkg
        }
        for (_, offering) in offerings.all {
            if let pkg = offering.availablePackages.first(where: matches) {
                return pkg
            }
        }
        return nil
    }

    private func purchaseComplete() {
        UserDefaults.standard.setValue(true, forKey: "pro")
        dismiss(animated: true)
        present(myAlt(titel: "Congratulations !",
                      message: "You are a pro member now. Enjoy seamless experience without the Ads."),
                animated: true, completion: nil)
        stopIndicator()
    }
}
