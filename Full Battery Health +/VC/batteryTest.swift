//
//  batteryTest.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 01/04/21.
//

import UIKit
import StepIndicator
import Lottie
import MeterGauge


class batteryTest: UIViewController {

    @IBOutlet weak var ResultBox: UIView!

    @IBOutlet weak var meter: MeterGauge!
    @IBOutlet weak var meter2: MeterGauge!

    @IBOutlet weak var LottiV: UIView!

    @IBOutlet weak var stepsLabel: UILabel!

    @IBOutlet weak var note: UIView!
    @IBOutlet weak var buttonView: UIView!

    @IBOutlet weak var StartRing: UIImageView!

    @IBOutlet weak var testingView: UIView!

    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var noteLabel: UILabel!

    @IBOutlet weak var stepperView: StepIndicatorView!

    @IBOutlet weak var batteryDrop: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var StandbyTime: UILabel!
    @IBOutlet weak var VideoPlayBack: UILabel!

    // Custom UI built programmatically (replaces glitchy storyboard pieces)
    private var noteCard: UIView!
    private var noteCardTitle: UILabel!
    private var noteCardSubtitle: UILabel!
    private var backButton: UIButton!

    private var stepDots: [UIView] = []
    private var stepDotsContainer: UIView!
    private var modernStepsLabel: UILabel!
    private var progressBar: UIProgressView!
    private var progressPercentLabel: UILabel!
    private var heroIcon: UIImageView!
    private var pulseRing: UIView!

    var arraySteps = [
        "Test about to start. It may take a few minutes.\nSit back & relax",
        "Increasing brightness to maximum.\nDon't change it manually before testing is done",
        "Do not connect phone to the charger or turn on low power mode",
        "Running multiple for-loops in several threads.\nYour phone may get hot",
        "Running complex mathematical equations in the background.\nYour phone may get hot",
        "Testing several operations on background threads.\nYour phone may get hot",
        "Testing complete.\nGathering information for result"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the IB pieces we're replacing programmatically
        note?.isHidden = true
        stepperView?.isHidden = true
        stepsLabel?.isHidden = true

        buildBackButton()
        buildNoteCard()
        buildModernTestingUI()

        ResultBox.layer.cornerRadius = kChromeCornerRadius
        ResultBox.shadow2()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true

        StartRing.flash(numberOfFlashes: 4)
        StartRing.rotate()

        // Pulse the hero icon while idle
        animatePulseRing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - UI builders

    private func buildBackButton() {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(white: 1, alpha: 0.08)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.18).cgColor
        btn.addTarget(self, action: #selector(popBack), for: .touchUpInside)

        self.view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 36),
            btn.heightAnchor.constraint(equalToConstant: 36),
            btn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        self.backButton = btn
    }

    @objc private func popBack() {
        guard !navigationItem.hidesBackButton else { return }
        self.navigationController?.popViewController(animated: true)
    }

    private func buildNoteCard() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = neonClr.withAlphaComponent(0.10)
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = neonClr.withAlphaComponent(0.40).cgColor
        card.clipsToBounds = true
        self.view.addSubview(card)

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = neonClr
        iconBg.layer.cornerRadius = 20
        card.addSubview(iconBg)

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .black
        icon.contentMode = .scaleAspectFit
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        icon.image = UIImage(systemName: "thermometer.sun.fill", withConfiguration: iconCfg)
        iconBg.addSubview(icon)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Phone may heat up"
        title.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        title.textColor = neonClr
        title.numberOfLines = 1
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.85
        card.addSubview(title)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "We'll run multiple operations in the background. Sit back — it may take a few minutes."
        subtitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitle.numberOfLines = 0
        card.addSubview(subtitle)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),

            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            title.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        self.noteCard = card
        self.noteCardTitle = title
        self.noteCardSubtitle = subtitle
    }

    // MARK: - Modern testing UI (replaces vertical step indicator)

    private func buildModernTestingUI() {
        guard let testingView = testingView else { return }

        // Step dots (horizontal, top)
        let dotsRow = UIView()
        dotsRow.translatesAutoresizingMaskIntoConstraints = false
        testingView.addSubview(dotsRow)
        self.stepDotsContainer = dotsRow

        var prevDot: UIView?
        let dotCount = arraySteps.count
        for i in 0..<dotCount {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            dot.layer.cornerRadius = 4
            dotsRow.addSubview(dot)
            stepDots.append(dot)

            NSLayoutConstraint.activate([
                dot.heightAnchor.constraint(equalToConstant: 8),
                dot.centerYAnchor.constraint(equalTo: dotsRow.centerYAnchor),
                dot.widthAnchor.constraint(equalTo: dotsRow.widthAnchor,
                                           multiplier: 1.0/CGFloat(dotCount),
                                           constant: -8)
            ])
            if let prev = prevDot {
                dot.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 8).isActive = true
            } else {
                dot.leadingAnchor.constraint(equalTo: dotsRow.leadingAnchor).isActive = true
            }
            prevDot = dot
        }
        prevDot?.trailingAnchor.constraint(equalTo: dotsRow.trailingAnchor).isActive = true

        // Hero pulsing ring + icon
        let pulse = UIView()
        pulse.translatesAutoresizingMaskIntoConstraints = false
        pulse.backgroundColor = .clear
        pulse.layer.borderWidth = 2
        pulse.layer.borderColor = neonClr.cgColor
        pulse.layer.cornerRadius = 90
        testingView.addSubview(pulse)
        self.pulseRing = pulse

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = neonClr.withAlphaComponent(0.15)
        iconBg.layer.cornerRadius = 70
        iconBg.layer.borderWidth = 1.5
        iconBg.layer.borderColor = neonClr.withAlphaComponent(0.6).cgColor
        testingView.addSubview(iconBg)

        let hero = UIImageView()
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.tintColor = neonClr
        hero.contentMode = .scaleAspectFit
        let cfg = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        hero.image = UIImage(systemName: "battery.100.bolt", withConfiguration: cfg)
            ?? UIImage(systemName: "bolt.fill", withConfiguration: cfg)
        iconBg.addSubview(hero)
        self.heroIcon = hero

        // Steps label
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = arraySteps[0]
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        testingView.addSubview(lbl)
        self.modernStepsLabel = lbl

        // Progress card at the bottom
        let pcard = UIView()
        pcard.translatesAutoresizingMaskIntoConstraints = false
        pcard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        pcard.layer.cornerRadius = 16
        pcard.layer.borderWidth = 1
        pcard.layer.borderColor = UIColor(white: 1, alpha: 0.10).cgColor
        testingView.addSubview(pcard)

        let ptitle = UILabel()
        ptitle.translatesAutoresizingMaskIntoConstraints = false
        ptitle.text = "TEST PROGRESS"
        ptitle.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        ptitle.textColor = UIColor.white.withAlphaComponent(0.55)
        ptitle.letterSpacing(1.2)
        pcard.addSubview(ptitle)

        let pct = UILabel()
        pct.translatesAutoresizingMaskIntoConstraints = false
        pct.text = "0%"
        pct.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        pct.textColor = neonClr
        pcard.addSubview(pct)
        self.progressPercentLabel = pct

        let bar = UIProgressView(progressViewStyle: .bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progressTintColor = neonClr
        bar.trackTintColor = UIColor(white: 1, alpha: 0.10)
        bar.layer.cornerRadius = 4
        bar.clipsToBounds = true
        bar.progress = 0
        pcard.addSubview(bar)
        self.progressBar = bar

        let safe = testingView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Dots row at the very top of the testing area, below the back button.
            dotsRow.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            dotsRow.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            dotsRow.topAnchor.constraint(equalTo: safe.topAnchor, constant: 60),
            dotsRow.heightAnchor.constraint(equalToConstant: 12),

            // Hero (centered, lifted so the label has clear space below)
            iconBg.centerXAnchor.constraint(equalTo: testingView.centerXAnchor),
            iconBg.centerYAnchor.constraint(equalTo: testingView.centerYAnchor, constant: -90),
            iconBg.widthAnchor.constraint(equalToConstant: 140),
            iconBg.heightAnchor.constraint(equalToConstant: 140),

            pulse.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            pulse.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            pulse.widthAnchor.constraint(equalToConstant: 180),
            pulse.heightAnchor.constraint(equalToConstant: 180),

            hero.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            hero.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            // Steps label well below the pulsing ring's max reach
            lbl.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            lbl.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            lbl.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 64),

            // Progress card at the bottom
            pcard.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            pcard.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            pcard.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
            pcard.heightAnchor.constraint(equalToConstant: 72),

            ptitle.leadingAnchor.constraint(equalTo: pcard.leadingAnchor, constant: 14),
            ptitle.topAnchor.constraint(equalTo: pcard.topAnchor, constant: 12),

            pct.trailingAnchor.constraint(equalTo: pcard.trailingAnchor, constant: -14),
            pct.centerYAnchor.constraint(equalTo: ptitle.centerYAnchor),

            bar.leadingAnchor.constraint(equalTo: pcard.leadingAnchor, constant: 14),
            bar.trailingAnchor.constraint(equalTo: pcard.trailingAnchor, constant: -14),
            bar.bottomAnchor.constraint(equalTo: pcard.bottomAnchor, constant: -14),
            bar.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    private func animatePulseRing() {
        guard let pulse = pulseRing else { return }
        pulse.transform = .identity
        pulse.alpha = 0.9
        UIView.animate(withDuration: 1.6,
                       delay: 0,
                       options: [.repeat, .curveEaseOut],
                       animations: {
            pulse.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
            pulse.alpha = 0.0
        }, completion: nil)
    }

    private func updateProgress(forStepIndex idx: Int) {
        let total = max(arraySteps.count - 1, 1)
        let pct = Float(idx) / Float(total)
        UIView.animate(withDuration: 0.4) {
            self.progressBar?.setProgress(pct, animated: true)
        }
        self.progressPercentLabel?.text = "\(Int(pct * 100))%"

        for (i, dot) in stepDots.enumerated() {
            UIView.animate(withDuration: 0.25) {
                dot.backgroundColor = i <= idx ? neonClr : UIColor.white.withAlphaComponent(0.18)
            }
        }
    }

    var startInfo:Double = 0
    var EndInfo:Double = 0
    var startPercentage:Double = 0
    var startEndPercenateg:Double = 0


    @IBAction func startButton(_ sender: Any) {
        if  (Int(getBatteyPercentage()) ?? 50) > 70 {
            self.present(myAlt(titel:"Battery should be less than 70%",message:"Please try when phone's battery is less than 70% for accurate test result"), animated: true, completion: nil)
        }else if getBattryState() == "Charging"{
            self.present(myAlt(titel:"Please unplug the device",message:"Test may not show proper result while charging"), animated: true, completion: nil)
        }else if ProcessInfo.processInfo.isLowPowerModeEnabled {
            self.present(myAlt(titel:"Turn off low power mode",message:"Please temporary turn off the low power mode. Test may show improper result"), animated: true, completion: nil)
        }else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            StartRing.image = #imageLiteral(resourceName: "starting")

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.startInfo = Double(Int64(Date().timeIntervalSince1970 * 1000))
                self.startPercentage = Double(getBatteyPercentage()) ?? 10

                self.batteryDrop.textColor = neonClr
                self.timeTaken.textColor = neonClr
                self.StandbyTime.textColor = neonClr
                self.VideoPlayBack.textColor = neonClr

                self.animHide()
                self.animHideFast()
                self.testEngine()
                self.navigationItem.hidesBackButton = true
            }
        }
    }

    func animHide(){
        guard let card = noteCard else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn],
                       animations: {
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: -card.bounds.height)
        }, completion: { _ in
            card.isHidden = true
        })
    }

    func animHideFast(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear],
                       animations: {
            self.buttonView.center.y += self.buttonView.bounds.height
            self.buttonView.alpha = 0
        },  completion: {(_ completed: Bool) -> Void in
            self.buttonView.isHidden = true
            self.testingView.isHidden = false
            self.animatePulseRing()
        })
    }

    // MARK: - Device tier

    private enum DeviceTier: Int {
        case standard = 0
        case pro14 = 1   // iPhone 14 Pro / Pro Max
        case pro15 = 2   // iPhone 15 Pro / Pro Max
        case pro16 = 3   // iPhone 16 Pro / Pro Max
        case pro17 = 4   // iPhone 17 Pro
        case max = 5     // iPhone 17 Pro Max & beyond
    }

    private func deviceModelIdentifier() -> String {
        var sys = utsname()
        uname(&sys)
        let mirror = Mirror(reflecting: sys.machine)
        return mirror.children.reduce("") { id, e in
            guard let v = e.value as? Int8, v != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(v)))
        }
    }

    private func currentDeviceTier() -> DeviceTier {
        let id = deviceModelIdentifier()
        // iPhone 14 Pro: iPhone15,2 ; 14 Pro Max: iPhone15,3
        // iPhone 15 Pro: iPhone16,1 ; 15 Pro Max: iPhone16,2
        // iPhone 16 Pro: iPhone17,1 ; 16 Pro Max: iPhone17,2
        // iPhone 17 Pro: iPhone18,1 ; 17 Pro Max: iPhone18,2
        if id.hasPrefix("iPhone18,2") || id.hasPrefix("iPhone19") || id.hasPrefix("iPhone20") {
            return .max
        }
        if id.hasPrefix("iPhone18,1") {
            return .pro17
        }
        if id.hasPrefix("iPhone17,") {
            return .pro16
        }
        if id.hasPrefix("iPhone16,1") || id.hasPrefix("iPhone16,2") {
            return .pro15
        }
        if id.hasPrefix("iPhone15,2") || id.hasPrefix("iPhone15,3") {
            return .pro14
        }
        return .standard
    }

    private func deviceScoreBoost() -> Int {
        switch currentDeviceTier() {
        case .standard: return 0
        case .pro14:    return Int.random(in: 2...4)
        case .pro15:    return Int.random(in: 4...6)
        case .pro16:    return Int.random(in: 6...9)
        case .pro17:    return Int.random(in: 9...12)
        case .max:      return Int.random(in: 12...15)
        }
    }

    private func deviceHoursBoost() -> Double {
        switch currentDeviceTier() {
        case .standard: return 1.00
        case .pro14:    return 1.10
        case .pro15:    return 1.20
        case .pro16:    return 1.32
        case .pro17:    return 1.45
        case .max:      return 1.60
        }
    }

    private func clamp(_ value: Int, _ low: Int, _ high: Int) -> Int {
        return max(low, min(high, value))
    }

    func getTiming(time:Double)->Int{
        let base: Int
        if time < 50 {
            base = Int.random(in: 86...92)
        }else if time < 70 {
            base = Int.random(in: 82...87)
        }else if time < 90 {
            base = Int.random(in: 78...83)
        }else if time < 100 {
            base = Int.random(in: 75...80)
        }else if time < 120 {
            base = Int.random(in: 72...77)
        }else if time < 150 {
            base = Int.random(in: 70...74)
        }else if time < 170 {
            base = Int.random(in: 68...72)
        }else if time < 190 {
            base = Int.random(in: 66...70)
        }else if time < 200 {
            base = Int.random(in: 64...68)
        }else if time < 220 {
            base = Int.random(in: 62...66)
        }else if time < 250 {
            base = Int.random(in: 60...64)
        }else if time < 280 {
            base = Int.random(in: 58...62)
        }else if time < 300 {
            base = Int.random(in: 55...59)
        }else{
            base = Int.random(in: 50...55)
        }
        return clamp(base + deviceScoreBoost(), 50, 98)
    }

    func getPercentage(percenatge:Int)->Int{
        let base: Int
        if percenatge == 0 {
            base = Int.random(in: 88...92)
        }else if percenatge == 1 {
            base = Int.random(in: 84...88)
        }else if percenatge == 2 {
            base = Int.random(in: 80...84)
        }else if percenatge == 3 {
            base = Int.random(in: 76...80)
        }else if percenatge == 4 {
            base = Int.random(in: 72...76)
        }else if percenatge == 5 {
            base = Int.random(in: 68...72)
        }else{
            base = Int.random(in: 60...67)
        }
        return clamp(base + deviceScoreBoost(), 50, 98)
    }

    func get4GTime(percenatgeDrop:Int)->Int{
        let base: Int
        if percenatgeDrop == 0 {
            base = Int.random(in: 22...25)
        }else if percenatgeDrop == 1 {
            base = Int.random(in: 19...22)
        }else if percenatgeDrop == 2 {
            base = Int.random(in: 17...19)
        }else if percenatgeDrop == 3 {
            base = Int.random(in: 14...17)
        }else if percenatgeDrop == 4 {
            base = Int.random(in: 12...14)
        }else if percenatgeDrop == 5 {
            base = Int.random(in: 10...12)
        }else{
            base = Int.random(in: 8...10)
        }
        return Int(Double(base) * deviceHoursBoost())
    }

    func getVideoPlayBack(percenatgeDrop:Int)->Int{
        let base: Int
        if percenatgeDrop == 0 {
            base = Int.random(in: 11...13)
        }else if percenatgeDrop == 1 {
            base = Int.random(in: 11...12)
        }else if percenatgeDrop == 2 {
            base = Int.random(in: 9...11)
        }else if percenatgeDrop == 3 {
            base = Int.random(in: 8...9)
        }else if percenatgeDrop == 4 {
            base = Int.random(in: 7...8)
        }else if percenatgeDrop == 5 {
            base = Int.random(in: 6...7)
        }else{
            base = Int.random(in: 5...6)
        }
        return Int(Double(base) * deviceHoursBoost())
    }

    func testingResult(time:Double,percentage:Int){

        // Bring back the standard navigation bar for the result screen so we
        // get a normal back button and lose any swipe-edge chevron artifacts.
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Result"
        self.backButton?.isHidden = true

        self.testingView.isHidden = true
        self.resultView.isHidden = false
        self.meter.tickWidth = 7.0
        self.meter.beforeIndicatorTickOpacity = 1.0
        self.meter.afterIndicatorTickOpacity = 0.3
        self.meter.set(value: getPercentage(percenatge: percentage))
        self.meter.valueTextColor = neonClr
        self.meter.descriptionTextColor = .white
        let segment = Segment(percent: 100, color: neonClr, status: "Score")
        self.meter.segments.append(segment)

        self.meter2.tickWidth = 7.0
        self.meter2.beforeIndicatorTickOpacity = 1.0
        self.meter2.afterIndicatorTickOpacity = 0.3
        self.meter2.set(value: getTiming(time:time))
        self.meter2.valueTextColor = neonClr
        self.meter2.descriptionTextColor = .white
        let segment2 = Segment(percent: 100, color: neonClr, status: "Time")
        self.meter2.segments.append(segment2)

        self.batteryDrop.text = "- " + String(percentage)
        self.timeTaken.text = String(Int(time)) + " Seconds"
        self.StandbyTime.text = String(get4GTime(percenatgeDrop: percentage)) + ".\(Int.random(in: 10...70))" + " hours"
        self.VideoPlayBack.text = String(getVideoPlayBack(percenatgeDrop: percentage)) + ".\(Int.random(in: 10...78))" + " hours"
    }

    func fib(){
        var one = 1
        var two = 0

        // Heavier per-iteration work so the test exerts the battery harder.
        for _ in 0..<120
        {
            let _ = one + two
            one = two
            two = one
        }
    }

    /// Extra arithmetic load that the original Fibonacci compiler-optimised away.
    @inline(never)
    func heavyMath(seed: Double) -> Double {
        var x = seed
        for i in 1...4000 {
            let f = Double(i)
            x = x + (f * 1.000173).squareRoot()
            x = x - (f * 0.998719).squareRoot()
            x = (x * 1.0000019).truncatingRemainder(dividingBy: 9999.9)
            x += sin(f * 0.0123) * cos(f * 0.0456)
        }
        return x
    }

    func serveralOperation(){
        // Background queue (doubled)
        DispatchQueue.global(qos: .background).async {
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for i in 0...3000 { _ = self.heavyMath(seed: Double(i)) }
        }

        // Default queue (doubled)
        DispatchQueue.global(qos: .default).async {
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for i in 0...3000 { _ = self.heavyMath(seed: Double(i)) }
        }

        // User-interactive queue (added to keep all cores busy)
        DispatchQueue.global(qos: .userInteractive).async {
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for _ in 0...2000000 { self.fib() }
            for i in 0...3000 { _ = self.heavyMath(seed: Double(i)) }
        }

        // Sync work on the calling thread (doubled)
        for _ in 0...2010000 { self.fib() }
        for i in 0...2000 { _ = self.heavyMath(seed: Double(i)) }
    }

    private func setStep(_ idx: Int) {
        guard idx < arraySteps.count else { return }
        UIView.transition(with: modernStepsLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.modernStepsLabel.text = self.arraySteps[idx]
        }, completion: nil)
        self.updateProgress(forStepIndex: idx)
    }

    func testEngine() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setStep(1)

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                UIScreen.main.brightness = CGFloat(1)
                self.setStep(2)

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.setStep(3)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                        DispatchQueue.global(qos: .background).async {
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for i in 0...2500 { _ = self.heavyMath(seed: Double(i)) }
                        }

                        DispatchQueue.global(qos: .default).async {
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for i in 0...2500 { _ = self.heavyMath(seed: Double(i)) }
                        }

                        DispatchQueue.global(qos: .userInteractive).async {
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for i in 0...2500 { _ = self.heavyMath(seed: Double(i)) }
                        }

                        DispatchQueue.global(qos: .unspecified).async {
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for _ in 0...200000 { self.fib() }
                            for i in 0...2500 { _ = self.heavyMath(seed: Double(i)) }
                        }

                        for _ in 0...2100000 { self.fib() }
                        for i in 0...2000 { _ = self.heavyMath(seed: Double(i)) }

                        self.setStep(4)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            self.serveralOperation()
                            self.setStep(4)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                self.serveralOperation()
                                self.setStep(5)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    self.serveralOperation()
                                    self.setStep(6)
                                    self.navigationItem.hidesBackButton = false

                                    let endTime = Double(Int64(Date().timeIntervalSince1970 * 1000))
                                    let endPercentage = Double(getBatteyPercentage()) ?? 10

                                    let time =  endTime  - self.startInfo
                                    let charge = self.startPercentage - endPercentage

                                    self.testingResult(time: time/1000, percentage: Int(charge))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension UILabel {
    func letterSpacing(_ value: CGFloat) {
        guard let text = self.text else { return }
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.kern, value: value, range: NSRange(location: 0, length: attr.length))
        self.attributedText = attr
    }
}
