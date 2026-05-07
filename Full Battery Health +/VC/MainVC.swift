//
//  MainVC.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit
import MediaPlayer
import InAppPurchase
import AVKit
import AppTrackingTransparency
import SwiftySound
import StoreKit
import CoreLocation

var info = BatteryInfo(id: 1, currentBatteryPercentage: 0, lastBatteryPercentage: 0, TimeStarted: 0, TimeEnded: 0)

// MARK: - Battery Ring View (mirrors StorageRingView from CleanerViewController)

private final class BatteryRingView: UIView {
    private let trackRing = CAShapeLayer()
    private let progressRing = CAShapeLayer()
    private var trackColor: UIColor = .systemGray5
    private var fillColor: UIColor = neonClr

    var progress: CGFloat = 0 {
        didSet { animateProgress() }
    }

    func setRingColor(_ color: UIColor) {
        fillColor = color
        progressRing.strokeColor = color.cgColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(trackRing)
        layer.addSublayer(progressRing)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(trackRing)
        layer.addSublayer(progressRing)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 9
        let start = -CGFloat.pi / 2
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: start, endAngle: start + 2 * .pi,
                                clockwise: true).cgPath

        trackRing.path = path
        trackRing.fillColor = UIColor.clear.cgColor
        trackRing.strokeColor = trackColor.cgColor
        trackRing.lineWidth = 14
        trackRing.lineCap = .round

        progressRing.path = path
        progressRing.fillColor = UIColor.clear.cgColor
        progressRing.strokeColor = fillColor.cgColor
        progressRing.lineWidth = 14
        progressRing.lineCap = .round
        progressRing.strokeEnd = progress
    }

    private func animateProgress() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = progressRing.strokeEnd
        anim.toValue = progress
        anim.duration = 0.9
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        progressRing.add(anim, forKey: "battProgress")
        progressRing.strokeEnd = progress
    }
}

/// Matches Cleaner cards + hero: `UIView` with `kChromeCornerRadius` and **continuous** corner curve.
/// Bezier-path rounding looks different from `cornerCurve = .continuous` at the same pt value.
private final class BatterySectionBackgroundView: UIView {
  private let card = UIView()
  private let maskedCorners: CACornerMask
  private let horizontalInset: CGFloat

  init(maskedCorners: CACornerMask, horizontalInset: CGFloat) {
    self.maskedCorners = maskedCorners
    self.horizontalInset = horizontalInset
    super.init(frame: .zero)

    backgroundColor = .clear
    card.backgroundColor = .secondarySystemBackground
    card.layer.cornerCurve = .continuous
    card.clipsToBounds = true
    addSubview(card)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    card.frame = bounds.insetBy(dx: horizontalInset, dy: 0)

    if maskedCorners.isEmpty {
      card.layer.cornerRadius = 0
      card.layer.maskedCorners = []
    } else {
      card.layer.cornerRadius = kChromeCornerRadius
      card.layer.maskedCorners = maskedCorners
    }
  }
}

class MainVC: UIViewController,UITableViewDelegate,UITableViewDataSource { //CLLocationManagerDelegate

  private var chromeLayoutWidth: CGFloat = 0
  /// Outer inset from screen edge for battery cards (matches hero `pad` and footers).
  private let batteryCardHorizontalInset: CGFloat = 12
  /// Inner padding from card edge to cell content.
  private let batteryCardContentPadding: CGFloat = 10
  /// Leading chrome size for table rows (smaller than Cleaner action cards).
  private let tableSymbolPlate: CGFloat = 36
  private weak var heroBatteryValueLabel: UILabel?
  private weak var heroStateValueLabel: UILabel?
  private weak var heroRingView: BatteryRingView?
  private weak var heroPercentLabel: UILabel?
  private weak var heroStateChipLabel: UILabel?
  private weak var heroStateChipIcon: UIImageView?
  private weak var heroStateChipIconChrome: UIView?
  private weak var heroAlarmAtLabel: UILabel?

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 0
    }else if section == 1 {
      return 1
    }
    else if section == 2 {
      return 6
    }
    else if section == 3 {
      return 3
    }
    else if section == 4 {
      return 4
    }
    return 1
  }
  
  /// Inset-grouped section containers match the hero card radius.
  private func applyInsetGroupedCellChrome(_ cell: UITableViewCell, verticalTop: CGFloat = 8, verticalBottom: CGFloat = 8) {
    cell.backgroundConfiguration = .clear()
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    cell.backgroundView = nil
    cell.selectedBackgroundView = nil

    let horizontal = batteryCardHorizontalInset + batteryCardContentPadding
    let margins = NSDirectionalEdgeInsets(top: verticalTop, leading: horizontal, bottom: verticalBottom, trailing: horizontal)
    cell.preservesSuperviewLayoutMargins = false
    cell.contentView.preservesSuperviewLayoutMargins = false
    cell.directionalLayoutMargins = margins
    cell.contentView.directionalLayoutMargins = margins
  }

  private func applyInsetGroupedSectionChrome(_ cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
    let vt: CGFloat
    let vb: CGFloat
    if indexPath.section == 2 {
      switch indexPath.row {
      case 1: (vt, vb) = (4, 2)
      case 2: (vt, vb) = (2, 8)
      case 3: (vt, vb) = (2, 2)
      default: (vt, vb) = (8, 8)
      }
    } else {
      (vt, vb) = (8, 8)
    }
    applyInsetGroupedCellChrome(cell, verticalTop: vt, verticalBottom: vb)

    let rowCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
    let corners: CACornerMask
    if rowCount == 1 {
      corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else if indexPath.row == 0 {
      corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    } else if indexPath.row == rowCount - 1 {
      corners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else {
      corners = []
    }

    cell.backgroundView = makeBatterySectionBackground(maskedCorners: corners)
  }

  private func makeBatterySectionBackground(maskedCorners: CACornerMask) -> UIView {
    BatterySectionBackgroundView(maskedCorners: maskedCorners, horizontalInset: batteryCardHorizontalInset)
  }

  private func cleanerChromeSymbolImage(symbolName: String, tint: UIColor) -> UIImage {
    let plate = tableSymbolPlate
    let plateCorner = max(8, kChromeCornerRadius * (plate / 48))
    let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
    guard let raw = UIImage(systemName: symbolName, withConfiguration: cfg) else {
      return UIImage()
    }
    let symbolImage = raw.withTintColor(tint, renderingMode: .alwaysOriginal)
    let format = UIGraphicsImageRendererFormat()
    format.scale = UIScreen.main.scale
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: plate, height: plate), format: format)
    return renderer.image { _ in
      let bounds = CGRect(x: 0, y: 0, width: plate, height: plate)
      let bg = UIBezierPath(roundedRect: bounds, cornerRadius: plateCorner)
      tint.withAlphaComponent(0.12).setFill()
      bg.fill()
      let sz = symbolImage.size
      let r = CGRect(
        x: (plate - sz.width) / 2,
        y: (plate - sz.height) / 2,
        width: sz.width,
        height: sz.height
      )
      symbolImage.draw(in: r)
    }
  }

  private func applyValueListRow(_ cell: UITableViewCell, title: String, value: String?, symbolName: String, symbolTint: UIColor = neonClr) {
    var content = UIListContentConfiguration.valueCell()
    content.text = title
    content.secondaryText = value
    content.image = cleanerChromeSymbolImage(symbolName: symbolName, tint: symbolTint)
    content.imageProperties.reservedLayoutSize = CGSize(width: tableSymbolPlate, height: tableSymbolPlate)
    content.imageToTextPadding = 10
    content.textProperties.font = .systemFont(ofSize: 15, weight: .regular)
    content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .medium)
    content.secondaryTextProperties.color = .secondaryLabel
    cell.contentConfiguration = content
    cell.textLabel?.text = nil
    cell.detailTextLabel?.text = nil
    cell.imageView?.image = nil
    applyInsetGroupedCellChrome(cell)
  }

  private func styleMainCell4Row(_ cell: MainCell4, title: String, symbolName: String, symbolTint: UIColor) {
    cell.contentConfiguration = nil
    cell.textLabel?.text = title
    cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
    cell.textLabel?.textColor = .label
    cell.imageView?.image = cleanerChromeSymbolImage(symbolName: symbolName, tint: symbolTint)
    cell.imageView?.clipsToBounds = false
    cell.imageView?.layer.cornerRadius = 0
    cell.imageView?.contentMode = .scaleAspectFit
    applyInsetGroupedCellChrome(cell)
  }

  //MARK: TableViewCell Setting
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      return UITableViewCell()
    }else if indexPath.section == 1 {
      let  cell = Bundle.main.loadNibNamed("SetBattery", owner: self, options: nil)?.first as! SetBattery
      cell.selectionStyle = .none
      applyInsetGroupedCellChrome(cell)
      cell.Note.text = "• When you’re recharging a phone, charge it to at least 20% or more before using it\n\n• Remove charger if your battery reaches 100% (Full Charge)."

      return cell
      
    }else if indexPath.section == 2 {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        applyValueListRow(cell, title: "Alarm Ringtone", value: nil, symbolName: "music.note.list", symbolTint: neonClr)
        return cell
        
      }else if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell2", for: indexPath) as! MainCell2
        applyInsetGroupedCellChrome(cell)
        cell.selectionStyle = .none
        
        return cell
      }else if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        applyValueListRow(cell, title: "Alarm Volume", value: volumePercentage, symbolName: "speaker.wave.3.fill", symbolTint: .systemOrange)
        return cell
        
      }else if indexPath.row == 3 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell3", for: indexPath) as! MainCell3
        cell.selectionStyle = .none
        applyInsetGroupedCellChrome(cell)
        return cell
        
      }else if indexPath.row == 4 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
        cell.selectionStyle = .none
        styleMainCell4Row(cell, title: "Alarm Vibration", symbolName: "iphone.radiowaves.left.and.right", symbolTint: neonClr)
        cell.turningSwitch.tag = 1
        
        if UserDefaults.standard.string(forKey: "vibration") != nil {
          if UserDefaults.standard.string(forKey: "vibration") == "on"{
            cell.turningSwitch.isOn = true
          }else{
            cell.turningSwitch.isOn = false
          }
        }
        
        return cell
      }else if indexPath.row == 5 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
        cell.selectionStyle = .none
        styleMainCell4Row(cell, title: "Alarm Notification", symbolName: "bell.badge.fill", symbolTint: .systemRed)
        cell.turningSwitch.tag = 2
        
        if UserDefaults.standard.string(forKey: "notification") != nil {
          if UserDefaults.standard.string(forKey: "notification") == "on"{
            cell.turningSwitch.isOn = true
          }else{
            cell.turningSwitch.isOn = false
          }
        }
        
        return cell
        
      }
      
    }else if indexPath.section == 3 {
      
      if indexPath.row == 0 {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell5", for: indexPath) as! MainCell5
        applyInsetGroupedCellChrome(cell)
        cell.selectionStyle = .none
        return cell
        
      }else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .default
        let title = ChargingAnalysis[indexPath.row - 1]
        let symbol = indexPath.row == 1 ? "list.bullet.rectangle.portrait" : "clock"
        applyValueListRow(cell, title: title, value: nil, symbolName: symbol, symbolTint: indexPath.row == 1 ? .systemTeal : .systemBlue)
        cell.accessoryType = .disclosureIndicator
        return cell
        
      }
      
    }else if indexPath.section == 4 {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
        cell.selectionStyle = .none
        styleMainCell4Row(cell, title: "Always Dim  (Pro)", symbolName: "moon.stars.fill", symbolTint: .systemIndigo)
        cell.turningSwitch.tag = 3
        
        if UserDefaults.standard.string(forKey: "dim") != nil {
          if UserDefaults.standard.string(forKey: "dim") == "on"{
            cell.turningSwitch.isOn = true
          }else{
            cell.turningSwitch.isOn = false
          }
        }
        
        return cell
        
      }else if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
        cell.selectionStyle = .none
        styleMainCell4Row(cell, title: "Always Hide UI  (Pro)", symbolName: "rectangle.slash", symbolTint: .systemCyan)
        cell.turningSwitch.tag = 4
        
        if UserDefaults.standard.string(forKey: "hideUI") != nil {
          if UserDefaults.standard.string(forKey: "hideUI") == "on"{
            cell.turningSwitch.isOn = true
          }else{
            cell.turningSwitch.isOn = false
          }
        }
        
        return cell
        
      }else if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
        cell.selectionStyle = .none
        styleMainCell4Row(cell, title: UserDefaults.standard.string(forKey: "featureTitel") ?? "Alarm in lock  (Pro)", symbolName: "lock.iphone", symbolTint: .systemBrown)
        cell.turningSwitch.tag = 5
        
        if UserDefaults.standard.string(forKey: "background") != nil {
          if UserDefaults.standard.string(forKey: "background") == "on"{
            cell.turningSwitch.isOn = true
          }else{
            cell.turningSwitch.isOn = false
          }
        }
        
        return cell
        
      }else{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .default
        applyValueListRow(cell, title: "Auto Set Alarm", value: nil, symbolName: "bolt.horizontal.circle.fill", symbolTint: neonClr)
        cell.accessoryType = .disclosureIndicator
        return cell
      }
    }
    
    return UITableViewCell()
  }
  
  var ChargingAnalysis = ["Charging History","Charging Time State"]
  
  let HeaderString = ["","Set Battery Percentage","Alarm Settings","Charging Analysis","Other Settings"]
  
  var detailTextArray = [[String]]()
  var textLabelArray = [["Battery Percentage","Charging State"],[""],[]]
  
  func numberOfSections(in tableView: UITableView) -> Int {
    HeaderString.count
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 0
    }
    return 32
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    let last = numberOfSections(in: tableView) - 1
    if section == 0 || section == last {
      return .leastNormalMagnitude
    }
    return 8
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 1 {
      return 148
    }
    if indexPath.section == 2 {
      switch indexPath.row {
      case 1: return 44
      case 3: return 38
      default: break
      }
    }
    if indexPath.section == 3 {
      if indexPath.row == 0 {
        return 125
      }
      return 68
    }
    return 68
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 { return nil }
    return headerView(label: HeaderString[section])
  }
  
  func headerView(label: String) -> UIView {
    let w = max(myView.bounds.width, UIScreen.main.bounds.width)
    let h: CGFloat = 32
    let sectionHeader = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
    sectionHeader.backgroundColor = .clear
    let side = batteryCardHorizontalInset + batteryCardContentPadding
    let sectionText = UILabel(frame: CGRect(x: side, y: 0, width: w - 2 * side, height: h))
    sectionText.autoresizingMask = [.flexibleWidth]
    sectionText.text = label.uppercased(with: Locale.current)
    sectionText.font = .systemFont(ofSize: 12, weight: .semibold)
    sectionText.textColor = neonClr
    sectionHeader.addSubview(sectionText)
    return sectionHeader
  }

  private func installBatteryHeroHeader() {
    let w = max(view.bounds.width, UIScreen.main.bounds.width)
    let pad = batteryCardHorizontalInset
    let outer = UIView(frame: CGRect(x: 0, y: 0, width: w, height: 373))
    outer.backgroundColor = .clear

    var y: CGFloat = 4
    let title = UILabel(frame: CGRect(x: pad, y: y, width: w - 2 * pad, height: 30))
    title.font = .systemFont(ofSize: 28, weight: .bold)
    title.textColor = .label
    title.text = "Battery Alarm"
    outer.addSubview(title)
    y += 32

    let subtitle = UILabel(frame: CGRect(x: pad, y: y, width: w - 2 * pad, height: 18))
    subtitle.font = .systemFont(ofSize: 13, weight: .regular)
    subtitle.textColor = .secondaryLabel
    subtitle.numberOfLines = 1
    subtitle.text = "Charge alerts, sounds & battery tools"
    outer.addSubview(subtitle)
    y = subtitle.frame.maxY + 12

    // ── Hero card with circular battery ring ──────────
    let cardW = w - 2 * pad
    let card = UIView(frame: CGRect(x: pad, y: y, width: cardW, height: 303))
    card.backgroundColor = .secondarySystemBackground
    card.layer.cornerRadius = kChromeCornerRadius
    card.layer.cornerCurve = .continuous
    card.layer.shadowColor = UIColor.black.cgColor
    card.layer.shadowOpacity = 0.08
    card.layer.shadowOffset = CGSize(width: 0, height: 4)
    card.layer.shadowRadius = 12
    outer.addSubview(card)

    // Ring (square gauge — width & height match)
    let ringSize: CGFloat = 167
    let ringTopPadding: CGFloat = 8
    let ring = BatteryRingView(frame: CGRect(
      x: (cardW - ringSize) / 2,
      y: ringTopPadding,
      width: ringSize,
      height: ringSize
    ))
    card.addSubview(ring)
    heroRingView = ring

    // Big % centered slightly above ring centre
    let percentHeight: CGFloat = 42
    let percentLabel = UILabel(frame: CGRect(
      x: ring.frame.minX,
      y: ring.frame.midY - percentHeight / 2 - 4,
      width: ringSize,
      height: percentHeight
    ))
    percentLabel.font = .systemFont(ofSize: 32, weight: .bold)
    percentLabel.textColor = .label
    percentLabel.textAlignment = .center
    percentLabel.adjustsFontSizeToFitWidth = true
    percentLabel.minimumScaleFactor = 0.6
    percentLabel.text = "0%"
    card.addSubview(percentLabel)
    heroPercentLabel = percentLabel

    let captionLabel = UILabel(frame: CGRect(
      x: ring.frame.minX,
      y: percentLabel.frame.maxY,
      width: ringSize,
      height: 14
    ))
    captionLabel.font = .systemFont(ofSize: 11, weight: .medium)
    captionLabel.textColor = .secondaryLabel
    captionLabel.textAlignment = .center
    captionLabel.text = "Battery"
    card.addSubview(captionLabel)

    // Stats strip below ring (2 cells: charging state, alarm threshold)
    let gapBelowGauge: CGFloat = 6
    let stripY: CGFloat = ring.frame.maxY + gapBelowGauge
    let divider = UIView(frame: CGRect(x: 0, y: stripY, width: cardW, height: 0.5))
    divider.backgroundColor = .separator
    card.addSubview(divider)

    let stripH: CGFloat = 103
    let cellW = cardW / 2

    let stateCell = makeBatteryStatCell(
      frame: CGRect(x: 0, y: stripY, width: cellW, height: stripH),
      iconName: "bolt.fill",
      iconTint: neonClr,
      caption: "Charging",
      initialValue: "—"
    )
    card.addSubview(stateCell.cell)
    heroStateChipIcon = stateCell.iconView
    heroStateChipIconChrome = stateCell.iconChrome
    heroStateChipLabel = stateCell.valueLabel
    heroStateValueLabel = stateCell.valueLabel

    let alarmCell = makeBatteryStatCell(
      frame: CGRect(x: cellW, y: stripY, width: cellW, height: stripH),
      iconName: "bell.badge.fill",
      iconTint: .systemOrange,
      caption: "Alarm at",
      initialValue: "—"
    )
    card.addSubview(alarmCell.cell)
    heroAlarmAtLabel = alarmCell.valueLabel

    // Vertical separator between the 2 cells
    let vDivider = UIView(frame: CGRect(x: cellW - 0.25, y: stripY + 6, width: 0.5, height: stripH - 12))
    vDivider.backgroundColor = .separator
    card.addSubview(vDivider)

    let cardHeight = stripY + stripH + 4
    card.frame.size.height = cardHeight
    y += cardHeight + 4

    outer.frame.size.height = y
    myView.tableHeaderView = outer
    refreshBatteryHeroLabels()
  }

  private func makeBatteryStatCell(frame: CGRect, iconName: String, iconTint: UIColor,
                                   caption: String, initialValue: String)
    -> (cell: UIView, iconView: UIImageView, valueLabel: UILabel, iconChrome: UIView) {
    let cell = UIView(frame: frame)
    cell.backgroundColor = .clear

    let chromeSize: CGFloat = 40
    let iconGlyph: CGFloat = 18
    let chromeTop: CGFloat = 11
    let iconChrome = UIView(frame: CGRect(
      x: (frame.width - chromeSize) / 2,
      y: chromeTop,
      width: chromeSize,
      height: chromeSize
    ))
    iconChrome.backgroundColor = iconTint.withAlphaComponent(0.12)
    iconChrome.layer.cornerRadius = min(kChromeCornerRadius, chromeSize * 0.28)
    iconChrome.layer.cornerCurve = .continuous
    cell.addSubview(iconChrome)

    let iconConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    let iconView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
    iconView.tintColor = iconTint
    iconView.contentMode = .scaleAspectFit
    iconView.frame = CGRect(
      x: (chromeSize - iconGlyph) / 2,
      y: (chromeSize - iconGlyph) / 2,
      width: iconGlyph,
      height: iconGlyph
    )
    iconChrome.addSubview(iconView)

    let captionToValueGap: CGFloat = 0

    let captionLabel = UILabel(frame: CGRect(x: 4, y: iconChrome.frame.maxY + 4, width: frame.width - 8, height: 13))
    captionLabel.text = caption
    captionLabel.font = .systemFont(ofSize: 11, weight: .medium)
    captionLabel.textColor = .secondaryLabel
    captionLabel.textAlignment = .center
    captionLabel.adjustsFontSizeToFitWidth = true
    captionLabel.minimumScaleFactor = 0.85
    cell.addSubview(captionLabel)

    let valueTop = captionLabel.frame.maxY + captionToValueGap
    let valueH = max(0, frame.height - valueTop)
    let valueLabel = UILabel(frame: CGRect(x: 6, y: valueTop, width: frame.width - 12, height: valueH))
    valueLabel.text = initialValue
    valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
    valueLabel.textColor = .label
    valueLabel.textAlignment = .center
    valueLabel.adjustsFontSizeToFitWidth = true
    valueLabel.minimumScaleFactor = 0.65
    valueLabel.numberOfLines = 2
    valueLabel.lineBreakMode = .byWordWrapping
    cell.addSubview(valueLabel)

    return (cell, iconView, valueLabel, iconChrome)
  }

  private func refreshBatteryHeroLabels() {
    let pctString = getBatteyPercentage()
    let pct = Int(pctString) ?? 0
    let fraction = max(0, min(1, CGFloat(pct) / 100))
    heroPercentLabel?.text = "\(pct)%"
    heroBatteryValueLabel?.text = "\(pct)%"
    heroRingView?.progress = fraction

    // Tint the ring + state chip based on level/state.
    let state = getBattryState()
    let charging = state.lowercased().contains("charg") || state.lowercased().contains("full")
    let lowBattery = pct <= 20 && !charging
    let ringColor: UIColor
    if charging { ringColor = neonClr }
    else if lowBattery { ringColor = .systemRed }
    else { ringColor = .systemBlue }
    heroRingView?.setRingColor(ringColor)

    heroStateChipLabel?.text = state
    let chipTint = charging ? neonClr : (lowBattery ? .systemRed : .systemBlue)
    heroStateChipIcon?.tintColor = chipTint
    heroStateChipIconChrome?.backgroundColor = chipTint.withAlphaComponent(0.12)

    let threshold = UserDefaults.standard.integer(forKey: "percentage")
    heroAlarmAtLabel?.text = threshold > 0 ? "\(threshold)%" : "Not set"
  }

  private func installBatteryFooter() {
    let w = max(view.bounds.width, UIScreen.main.bounds.width)
    let pad = batteryCardHorizontalInset
    let footerTopPadding: CGFloat = 16
    let cardWidth = w - pad * 2
    let copy = "Automatically set an alarm when the charger is connected. Tap the option above to enable this automation."
    let font = UIFont.systemFont(ofSize: 13, weight: .regular)
    let textRect = (copy as NSString).boundingRect(
      with: CGSize(width: max(1, cardWidth - 28), height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: font],
      context: nil
    )
    let textH = ceil(textRect.height)
    let cardH = min(160, max(72, textH + 28))
    let outerH = cardH + 24 + footerTopPadding
    let outer = UIView(frame: CGRect(x: 0, y: 0, width: w, height: outerH))
    outer.backgroundColor = .clear
    let cardShell = UIView(frame: CGRect(x: pad, y: footerTopPadding, width: cardWidth, height: cardH))
    cardShell.backgroundColor = .secondarySystemBackground
    cardShell.layer.cornerRadius = kChromeCornerRadius
    cardShell.layer.cornerCurve = .continuous
    cardShell.layer.shadowColor = UIColor.black.cgColor
    cardShell.layer.shadowOpacity = 0.08
    cardShell.layer.shadowOffset = CGSize(width: 0, height: 4)
    cardShell.layer.shadowRadius = 12
    let label = UILabel(frame: CGRect(x: 14, y: 14, width: cardShell.bounds.width - 28, height: cardShell.bounds.height - 28))
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    label.text = copy
    label.font = font
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    cardShell.addSubview(label)
    outer.addSubview(cardShell)
    myView.tableFooterView = outer
  }

  private func ensureBatteryChromeLayout() {
    let w = myView.bounds.width
    guard w > 0 else { return }
    if abs(w - chromeLayoutWidth) < 0.5 { return }
    chromeLayoutWidth = w
    installBatteryHeroHeader()
    installBatteryFooter()
  }

  private func styleBottomChromeLabels() {
    for sub in ButtonView.subviews {
      guard let label = sub as? UILabel else { continue }
      label.font = .preferredFont(forTextStyle: .footnote)
      label.textColor = .secondaryLabel
      label.numberOfLines = 0
    }
  }

  @IBOutlet weak var myView: UITableView!
  
  @IBOutlet weak var ButtonView: UIView!
  
  @IBOutlet weak var setAlaram: UIButton!
  
  @IBOutlet weak var batterytestOutlet: UIBarButtonItem!
  
  @IBOutlet weak var pro: UIBarButtonItem!
  
  @IBAction func proAction(_ sender: Any) {
    let vc = Apps15init.shared.makeIAPVC()
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func setAlarmAction(_ sender: Any) {
    
    if Int(getBatteyPercentage()) ?? 10 <= UserDefaults.standard.integer(forKey: "percentage") {
      
      print(UserDefaults.standard.integer(forKey: "percentage"))
      
      startAlarm()
      
    }else{
      
      self.present(myAlt(titel:"Something is wrong",message:"Your current battery level is greater than the selected battery percentage for alarm"), animated: true, completion: nil)
    }
    
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 3 && indexPath.row == 1 {
      let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BatteryState") as? BatteryState
      vc?.BatteryHistory = true
      self.navigationController?.pushViewController(vc!, animated: true)
    }else if indexPath.section == 3 && indexPath.row == 2 {
      let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BatteryState") as? BatteryState
      vc?.BatteryHistory = false
      self.navigationController?.pushViewController(vc!, animated: true)
    }else if indexPath.section == 4 && indexPath.row == 3 {
      UIApplication.shared.open(URL(string: "https://www.youtube.com/watch?v=cWbpY7vcW68")!, completionHandler: nil)
    }
  }

  /// Re-apply after the system finishes grouped styling so section corners match the hero card.
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard indexPath.section >= 1 else { return }
    applyInsetGroupedSectionChrome(cell, at: indexPath, in: tableView)
  }

  //MARK: viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(Showinapp),
                                           name: NSNotification.Name("Showinapp"),
                                           object: nil)
    
    
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fromWidget),
                                           name: NSNotification.Name("fromWidget"),
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(forcepro),
                                           name: NSNotification.Name("forcepro"),
                                           object: nil)
    
    
    batterytestOutlet.tintColor = neonClr

    view.backgroundColor = .systemGroupedBackground
    myView.backgroundColor = .systemGroupedBackground
    myView.separatorStyle = .none
    myView.showsVerticalScrollIndicator = true
    if #available(iOS 15.0, *) {
      myView.sectionHeaderTopPadding = 20
    }

    ButtonView.backgroundColor = .secondarySystemBackground
    ButtonView.layer.cornerRadius = kChromeCornerRadius
    ButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    ButtonView.layer.cornerCurve = .continuous
    ButtonView.layer.shadowColor = UIColor.black.cgColor
    ButtonView.layer.shadowOpacity = 0.08
    ButtonView.layer.shadowOffset = CGSize(width: 0, height: -4)
    ButtonView.layer.shadowRadius = 12
    ButtonView.shadow2()

    let volumeView = MPVolumeView(frame: .null)
    view.addSubview(volumeView)
    
    
    DispatchQueue.main.async {
      MPVolumeView.setVolume(1.0)
      self.loadViewIfNeeded()
    }
    
    var detailTextLabel1 = [String]()
    detailTextLabel1.append(getBatteyPercentage())
    detailTextLabel1.append(getBattryState())
    detailTextArray.append(detailTextLabel1)
    detailTextArray.append([" "])
    detailTextArray.append([" "])
    
    NotificationCenter.default.addObserver(self, selector: #selector(Changed), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Changed),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(Changed), name: Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(alarmThresholdDidChange), name: .batteryAlarmThresholdDidChange, object: nil)

    let mySound = Sound(url: Bundle.main.url(forResource: "bell", withExtension: "mp3")!)
    mySound?.play()
    mySound?.stop()

    let iap = InAppPurchase.default
    iap.set(shouldAddStorePaymentHandler: { (product) -> Bool in
      return true
    }, handler: { (result) in
      switch result {
      case .success( _):
        self.PerchesedComplte()
      case .failure( _):
        print("error")
      }
    })
    
    
    self.myView.delegate = self
    self.myView.dataSource = self

    installBatteryHeroHeader()
    installBatteryFooter()
    chromeLayoutWidth = myView.bounds.width

    stateofBattery()
    styleBottomChromeLabels()
    self.myView.reloadData()

    DispatchQueue.main.async {
      if !UserDefaults.standard.bool(forKey: "pro") && UserDefaults.standard.integer(forKey: "AppLaunch") > 1{
        let vc = Apps15init.shared.makeIAPVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      }
    }
    
    
    /// Welcome Screen Logic
    if UserDefaults.standard.integer(forKey: "AppLaunch") == 1 {
      DispatchQueue.main.async {
        let story = UIStoryboard(name: "Welcome", bundle: Bundle.main)
        let vc = story.instantiateViewController(withIdentifier: "Navigation")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
      }
    }

    updateMainTableBottomInset()
  }

  private var lastAppliedTableBottomContentInset: CGFloat = -1

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateMainTableBottomInset()
    ensureBatteryChromeLayout()
  }

  /// Extra bottom inset so the last rows can scroll clear of the tab bar (and home indicator).
  private func updateMainTableBottomInset() {
    let padding: CGFloat = 28
    var bottomInset = padding
    if let tab = tabBarController, !tab.tabBar.isHidden {
      let tabFrame = tab.tabBar.convert(tab.tabBar.bounds, to: view)
      bottomInset += max(0, view.bounds.maxY - tabFrame.minY)
    }
    guard abs(bottomInset - lastAppliedTableBottomContentInset) > 0.5 else { return }
    lastAppliedTableBottomContentInset = bottomInset
    myView.contentInset.bottom = bottomInset
    myView.verticalScrollIndicatorInsets.bottom = bottomInset
  }
  
  @objc func forcepro(){
    
    self.present(myAlt(titel:"Not Pro Member",message:"bla bla bla"), animated: true, completion: nil)
  }
  
  
  
  @objc func fromWidget(noti:Notification) {
    
    if  getBattryState() == "Charging" {
      
      if Int(getBatteyPercentage()) ?? 10 <= UserDefaults.standard.integer(forKey: "percentage") {
        
        
        info.currentBatteryPercentage = Int(getBatteyPercentage()) ?? 10
        info.TimeStarted = Date().timeIntervalSince1970 * 1000
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
      }else{
        
        self.present(myAlt(titel:"Something is wrong",message:"Your current battery level is greater than the selected battery percentage for alarm"), animated: true, completion: nil)
      }
      
    }else{
      
      self.present(myAlt(titel:"Phone isn't charging",message:"Please connect the charger to set alarm"), animated: true, completion: nil)
    }
    
  }
  
  @objc func Showinapp(notification:Notification) {
    let vc = Apps15init.shared.makeIAPVC()
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
  func PerchesedComplte(){
    UserDefaults.standard.setValue(true , forKeyPath: "pro")
    self.present(myAlt(titel:"Congratulations !",message:"You are a pro member now. Enjoy seamless experience without the Ads."), animated: true, completion: nil)
  }
  
  
  func startAlarm() {
    
    info.currentBatteryPercentage = Int(getBatteyPercentage()) ?? 10
    info.TimeStarted = Date().timeIntervalSince1970 * 1000
    
    //        if UserDefaults.standard.integer(forKey: "AppLaunch") > 4 && !UserDefaults.standard.bool(forKey: "pro")  {
    //
    //            requestToRate()
    //
    //        }
    
    
    self.tabBarController?.tabBar.isHidden = true
    
    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
    self.navigationController?.pushViewController(vc!, animated: true)
    
  }
  
  
  @objc private func alarmThresholdDidChange() {
    stateofBattery()
    myView.reloadData()
  }

  var volumePercentage = "100%"
  @objc func Changed(_ notification: Notification) {
    detailTextArray[0][0] = getBatteyPercentage()
    detailTextArray[0][1] = getBattryState()
    
    if let userInfo = notification.userInfo {
      let volume = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Double
      volumePercentage = String(Int((volume ?? 1 )*100)) + "%"
    }
    
    stateofBattery()

    self.myView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = nil
    navigationItem.titleView = UIView()
    refreshBatteryHeroLabels()

    if UserDefaults.standard.bool(forKey: "pro"){
      self.navigationItem.leftBarButtonItem = nil
    }
  }
  
  
  func stateofBattery() {
    refreshBatteryHeroLabels()

    var cfg = UIButton.Configuration.filled()
    cfg.cornerStyle = .large
    cfg.buttonSize = .large
    cfg.background.cornerRadius = kChromeCornerRadius
    cfg.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 22, bottom: 16, trailing: 22)
    cfg.imagePadding = 10
    cfg.imagePlacement = .leading
    cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var o = incoming
      o.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
      o.kern = 1.6
      return o
    }

    let glyphConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)

    switch UIDevice.current.batteryState {
    case .charging:
      let title = "SET ALARM"
      var attr = AttributedString(title)
      attr.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
      attr.kern = 1.6
      cfg.attributedTitle = attr
      cfg.image = UIImage(systemName: "bolt.fill", withConfiguration: glyphConfig)
      cfg.baseForegroundColor = .white
      cfg.baseBackgroundColor = neonClr
      setAlaram.isEnabled = true
    default:
      let title = "CONNECT CHARGER"
      var attr = AttributedString(title)
      attr.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
      attr.kern = 1.6
      cfg.attributedTitle = attr
      cfg.image = UIImage(systemName: "powerplug.fill", withConfiguration: glyphConfig)
      cfg.baseForegroundColor = .white
      cfg.baseBackgroundColor = diableClr
      setAlaram.isEnabled = false
    }
    setAlaram.configuration = cfg
    setAlaram.layer.shadowOpacity = 0
  }
  
}
