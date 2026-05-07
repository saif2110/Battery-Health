//
//  InAppVC.swift
//  Stock Market India
//
//  Created by Junaid Mukadam on 05/04/21.
//

import UIKit
import Lottie
import Purchases
import SafariServices
import InAppPurchase
import StoreKit

enum IPA:String {
  case OneYearPro = "BatteryHealthPro"
  case Year       = "BatteryHealthProYear"
  case Week       = "BatteryHealthProWeek"
}

class InAppVC: UIViewController {
  var sysmbol = ""
  var myprice = 0.0

  /// 0 = Yearly, 1 = Weekly (3-day free trial).
  var selectedIPA = 0
  private var yearlyPackage: Purchases.Package?
  private var weeklyPackage: Purchases.Package?

  private let themeGreen = UIColor(red: 0.529, green: 0.737, blue: 0.345, alpha: 1.0)

  private let yearlyCard = UIView()
  private let weeklyCard = UIView()
  private let yearlyTitleLabel = UILabel()
  private let yearlySubtitleLabel = UILabel()
  private let weeklyTitleLabel = UILabel()
  private let weeklySubtitleLabel = UILabel()
  private let yearlyRadio = UIImageView()
  private let weeklyRadio = UIImageView()
  private let trialBadge = UILabel()

  @IBOutlet weak var priceLabel: UILabel!

  @IBOutlet weak var buyButton: UIButton!{
    didSet{
      buyButton.clipsToBounds = true
      buyButton.layer.cornerRadius = buyButton.bounds.height/2
    }
  }

  @IBOutlet weak var imageLotti: UIImageView!

  @IBOutlet weak var dismissOutlet: UIButton!

  @IBAction func dismissVC(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    if !Apps15init.shared.HSB {
       dismissOutlet.fadeIn()
    }
  }

  func jumpButtonAnimation(sender: UIButton) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.toValue = NSNumber(value: 1.03)
    animation.duration = 0.24
    animation.repeatCount = 100000
    animation.autoreverses = true
    sender.layer.add(animation, forKey: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupPlanCards()
    priceLabel?.isHidden = true

    Purchases.shared.offerings { [weak self] offerings, _ in
      guard let self = self, let offerings = offerings else { return }
      self.yearlyPackage = self.findPackage(in: offerings, productId: IPA.Year.rawValue)
      self.weeklyPackage = self.findPackage(in: offerings, productId: IPA.Week.rawValue)
      self.refreshCardLabels()
      stopIndicator()
    }
  }

  // MARK: - Plan cards

  private func setupPlanCards() {
    [yearlyCard, weeklyCard].forEach { card in
      card.translatesAutoresizingMaskIntoConstraints = false
      card.layer.cornerRadius = 14
      card.layer.borderWidth = 1.5
      card.layer.borderColor = UIColor.clear.cgColor
      card.backgroundColor = UIColor.tertiarySystemFill
      view.addSubview(card)
    }

    [(yearlyTitleLabel, "Yearly Plan"), (weeklyTitleLabel, "3-Day Free Trial")].forEach { (lbl, txt) in
      lbl.translatesAutoresizingMaskIntoConstraints = false
      lbl.text = txt
      lbl.font = .boldSystemFont(ofSize: 17)
      lbl.textColor = .label
    }

    [yearlySubtitleLabel, weeklySubtitleLabel].forEach { lbl in
      lbl.translatesAutoresizingMaskIntoConstraints = false
      lbl.font = .systemFont(ofSize: 13)
      lbl.textColor = .secondaryLabel
      lbl.numberOfLines = 1
    }
    yearlySubtitleLabel.text = "Loading…"
    weeklySubtitleLabel.text = "Then weekly subscription"

    [yearlyRadio, weeklyRadio].forEach { iv in
      iv.translatesAutoresizingMaskIntoConstraints = false
      iv.contentMode = .scaleAspectFit
      iv.tintColor = themeGreen
    }

    trialBadge.translatesAutoresizingMaskIntoConstraints = false
    trialBadge.text = "  3 DAYS FREE  "
    trialBadge.font = .boldSystemFont(ofSize: 11)
    trialBadge.textColor = .white
    trialBadge.backgroundColor = themeGreen
    trialBadge.layer.cornerRadius = 8
    trialBadge.layer.masksToBounds = true
    trialBadge.textAlignment = .center

    yearlyCard.addSubview(yearlyTitleLabel)
    yearlyCard.addSubview(yearlySubtitleLabel)
    yearlyCard.addSubview(yearlyRadio)
    weeklyCard.addSubview(weeklyTitleLabel)
    weeklyCard.addSubview(weeklySubtitleLabel)
    weeklyCard.addSubview(weeklyRadio)
    weeklyCard.addSubview(trialBadge)

    let yearlyTap = UITapGestureRecognizer(target: self, action: #selector(yearlyTapped))
    yearlyCard.addGestureRecognizer(yearlyTap)
    let weeklyTap = UITapGestureRecognizer(target: self, action: #selector(weeklyTapped))
    weeklyCard.addGestureRecognizer(weeklyTap)

    NSLayoutConstraint.activate([
      // Stack cards just above the existing buyButton.
      weeklyCard.bottomAnchor.constraint(equalTo: buyButton.topAnchor, constant: -16),
      weeklyCard.leadingAnchor.constraint(equalTo: buyButton.leadingAnchor),
      weeklyCard.trailingAnchor.constraint(equalTo: buyButton.trailingAnchor),
      weeklyCard.heightAnchor.constraint(equalToConstant: 60),

      yearlyCard.bottomAnchor.constraint(equalTo: weeklyCard.topAnchor, constant: -10),
      yearlyCard.leadingAnchor.constraint(equalTo: buyButton.leadingAnchor),
      yearlyCard.trailingAnchor.constraint(equalTo: buyButton.trailingAnchor),
      yearlyCard.heightAnchor.constraint(equalToConstant: 60),

      yearlyTitleLabel.topAnchor.constraint(equalTo: yearlyCard.topAnchor, constant: 8),
      yearlyTitleLabel.leadingAnchor.constraint(equalTo: yearlyCard.leadingAnchor, constant: 16),

      yearlySubtitleLabel.topAnchor.constraint(equalTo: yearlyTitleLabel.bottomAnchor, constant: 4),
      yearlySubtitleLabel.leadingAnchor.constraint(equalTo: yearlyCard.leadingAnchor, constant: 16),
      yearlySubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: yearlyRadio.leadingAnchor, constant: -8),

      yearlyRadio.centerYAnchor.constraint(equalTo: yearlyCard.centerYAnchor),
      yearlyRadio.trailingAnchor.constraint(equalTo: yearlyCard.trailingAnchor, constant: -16),
      yearlyRadio.widthAnchor.constraint(equalToConstant: 24),
      yearlyRadio.heightAnchor.constraint(equalToConstant: 24),

      weeklyTitleLabel.topAnchor.constraint(equalTo: weeklyCard.topAnchor, constant: 8),
      weeklyTitleLabel.leadingAnchor.constraint(equalTo: weeklyCard.leadingAnchor, constant: 16),

      weeklySubtitleLabel.topAnchor.constraint(equalTo: weeklyTitleLabel.bottomAnchor, constant: 4),
      weeklySubtitleLabel.leadingAnchor.constraint(equalTo: weeklyCard.leadingAnchor, constant: 16),
      weeklySubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trialBadge.leadingAnchor, constant: -8),

      trialBadge.centerYAnchor.constraint(equalTo: weeklyCard.centerYAnchor),
      trialBadge.trailingAnchor.constraint(equalTo: weeklyRadio.leadingAnchor, constant: -10),
      trialBadge.heightAnchor.constraint(equalToConstant: 22),

      weeklyRadio.centerYAnchor.constraint(equalTo: weeklyCard.centerYAnchor),
      weeklyRadio.trailingAnchor.constraint(equalTo: weeklyCard.trailingAnchor, constant: -16),
      weeklyRadio.widthAnchor.constraint(equalToConstant: 24),
      weeklyRadio.heightAnchor.constraint(equalToConstant: 24)
    ])

    refreshSelection()
  }

  private func refreshSelection() {
    let yearlySelected = selectedIPA == 0
    let weeklySelected = selectedIPA == 1
    yearlyCard.layer.borderColor = (yearlySelected ? themeGreen : UIColor.clear).cgColor
    weeklyCard.layer.borderColor = (weeklySelected ? themeGreen : UIColor.clear).cgColor
    yearlyCard.backgroundColor = yearlySelected
      ? themeGreen.withAlphaComponent(0.18)
      : UIColor.tertiarySystemFill
    weeklyCard.backgroundColor = weeklySelected
      ? themeGreen.withAlphaComponent(0.18)
      : UIColor.tertiarySystemFill
    yearlyRadio.image = UIImage(systemName: yearlySelected ? "checkmark.circle.fill" : "circle")
    weeklyRadio.image = UIImage(systemName: weeklySelected ? "checkmark.circle.fill" : "circle")
    buyButton.setTitle(weeklySelected ? "Start Free Trial" : "Continue", for: .normal)
  }

  private func refreshCardLabels() {
    if let yp = yearlyPackage {
      yearlySubtitleLabel.text = "\(yp.localizedPriceString) per year"
    } else {
      yearlySubtitleLabel.text = "Yearly subscription"
    }
    if let wp = weeklyPackage {
      weeklySubtitleLabel.text = "Then \(wp.localizedPriceString) per week"
    } else {
      weeklySubtitleLabel.text = "Then weekly subscription"
    }
  }

  @objc private func yearlyTapped() {
    selectedIPA = 0
    refreshSelection()
  }

  @objc private func weeklyTapped() {
    selectedIPA = 1
    refreshSelection()
  }

  private func findPackage(in offerings: Purchases.Offerings, productId: String) -> Purchases.Package? {
    // Strict match: only return a package whose underlying product identifier equals `productId`.
    // An offering may be named the same as a product but contain a different (legacy) SKU,
    // so we can't trust the offering name alone.
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

  @IBAction func restore(_ sender: Any) {
    let iap = InAppPurchase.default
    iap.restore(handler: { (result) in
      print(result)
      switch result {
      case .success(let products):
        if !products.isEmpty {
          print(products)
          self.PerchesedComplte()
        }
      case .failure(let error):
        print(error)
      }
    })
  }

  @IBAction func buyPro(_ sender: Any) {
    let pkg = (selectedIPA == 0) ? yearlyPackage : weeklyPackage
    guard let package = pkg else { return }
    startIndicator(selfo: self)
    Purchases.shared.purchasePackage(package) { (_, purchaserInfo, _, _) in
      let ents = purchaserInfo?.entitlements.all
      let isPro = ents?[IPA.OneYearPro.rawValue]?.isActive == true
        || ents?[IPA.Year.rawValue]?.isActive == true
        || ents?[IPA.Week.rawValue]?.isActive == true
      if isPro {
        self.PerchesedComplte()
      } else {
        stopIndicator()
      }
    }
  }
  
  func PerchesedComplte(){
    UserDefaults.standard.setValue(true , forKeyPath: "pro")
    self.dismiss(animated: true)
    self.present(myAlt(titel:"Congratulations !",message:"You are a pro member now. Enjoy seamless experience without the Ads."), animated: true, completion: nil)
    stopIndicator()
    
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    DispatchQueue.main.async {
      requestToRate()
    }
  }
  
  @IBAction func toc(sender:UIButton){
    let url = URL(string: "https://apps15.com/termsofuse.html")
    let vc = SFSafariViewController(url: url!)
    present(vc, animated: true, completion: nil)
  }
  
  @IBAction func privacyPolicy(sender:UIButton){
    let url = URL(string: "https://apps15.com/privacy.html")
    let vc = SFSafariViewController(url: url!)
    present(vc, animated: true, completion: nil)
  }
  
}

extension UIView {
  func fadeIn(duration: TimeInterval = 1.4, delay: TimeInterval = 1, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
    self.alpha = 0.0
    
    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
      self.isHidden = false
      self.alpha = 0.7
    }, completion: completion)
  }
}
