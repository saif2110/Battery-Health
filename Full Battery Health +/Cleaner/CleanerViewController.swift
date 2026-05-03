//
//  CleanerViewController.swift
//  Full Battery Health
//
//  Created by Saif on 12/12/23.
//

import UIKit
import MultiProgressView
import Photos

// MARK: - Storage Ring View

private class StorageRingView: UIView {

    private let backgroundRing = CAShapeLayer()
    private let progressRing = CAShapeLayer()
    private let accentColor = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)

    var progress: CGFloat = 0 {
        didSet { animateProgress() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backgroundRing)
        layer.addSublayer(progressRing)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(backgroundRing)
        layer.addSublayer(progressRing)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        let start = -CGFloat.pi / 2
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: start, endAngle: start + 2 * .pi,
                                clockwise: true).cgPath

        backgroundRing.path = path
        backgroundRing.fillColor = UIColor.clear.cgColor
        backgroundRing.strokeColor = UIColor.systemGray5.cgColor
        backgroundRing.lineWidth = 16
        backgroundRing.lineCap = .round

        progressRing.path = path
        progressRing.fillColor = UIColor.clear.cgColor
        progressRing.strokeColor = accentColor.cgColor
        progressRing.lineWidth = 16
        progressRing.lineCap = .round
        progressRing.strokeEnd = progress
    }

    private func animateProgress() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = progressRing.strokeEnd
        anim.toValue = progress
        anim.duration = 1.0
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        progressRing.add(anim, forKey: "progressAnim")
        progressRing.strokeEnd = progress
    }
}

// MARK: - CleanerViewController

class CleanerViewController: UIViewController, StorageInfoControllerDelegate {

    // IBOutlets kept for storyboard compatibility — connected to hidden views
    @IBOutlet weak var totalSpace: UILabel!
    @IBOutlet weak var progressView: MultiProgressView!
    @IBOutlet weak var freeSpace: UILabel!
    @IBOutlet weak var usedSpace: UILabel!
    @IBOutlet weak var photosSpace: UILabel!
    @IBOutlet weak var videosSpace: UILabel!

    var storageInfo: StorageInfo?
    let systemServices = SystemServices()

    // Modern UI labels
    private let ringView = StorageRingView()
    private let percentLabel = UILabel()
    private let usedStatLabel = UILabel()
    private let totalStatLabel = UILabel()
    private let freeStatLabel = UILabel()
    private let photosSizeLabel = UILabel()
    private let videosSizeLabel = UILabel()

    private let accentColor = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)

    // Hidden detached labels keep the storyboard outlets valid so legacy code paths don't crash
    private let detachedTotalSpace = UILabel()
    private let detachedFreeSpace = UILabel()
    private let detachedUsedSpace = UILabel()
    private let detachedPhotosSpace = UILabel()
    private let detachedVideosSpace = UILabel()
    private let detachedProgressView = MultiProgressView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Wipe storyboard layout entirely to avoid any constraint interference
        view.subviews.forEach { $0.removeFromSuperview() }
        // Re-point outlets at off-screen detached labels so any code that touches them is safe
        totalSpace = detachedTotalSpace
        freeSpace = detachedFreeSpace
        usedSpace = detachedUsedSpace
        photosSpace = detachedPhotosSpace
        videosSpace = detachedVideosSpace
        progressView = detachedProgressView
        view.backgroundColor = .systemGroupedBackground
        buildModernUI()
    }

    private var didLoadStorageData = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didLoadStorageData else { return }
        didLoadStorageData = true
        loadStorageData()
    }

    // MARK: - Data Loading

    private func loadStorageData() {
        // Heavy photo-library scan happens off the main thread
        DispatchQueue.global(qos: .background).async {
            SystemMonitor.storageInfoCtrl().delegate = self
            self.storageInfo = SystemMonitor.storageInfoCtrl().getStorageInfo()
        }

        // Lightweight disk-space stats can run on the main thread
        let usedFraction = Float(systemServices.longDiskSpace - systemServices.longFreeDiskSpace)
            / Float(max(systemServices.longDiskSpace, 1))

        ringView.progress = CGFloat(usedFraction)
        percentLabel.text = "\(Int(usedFraction * 100))%"
        usedStatLabel.text = systemServices.usedDiskSpaceinRaw ?? "--"
        totalStatLabel.text = systemServices.diskSpace ?? "--"
        freeStatLabel.text = systemServices.freeDiskSpaceinRaw ?? "--"

        requestPhotoPermission()
    }

    private func requestPhotoPermission() {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else { return }
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Permission Required",
                        message: "Please enable photo access in Settings",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self.present(alert, animated: true)
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    self.storageInfo = SystemMonitor.storageInfoCtrl().getStorageInfo()
                }
            }
        }
    }

    func storageInfoUpdated() {
        DispatchQueue.main.async {
            let photos = AMUtils.toNearestMetric(self.storageInfo!.totalPictureSize, desiredFraction: 1)
            let videos = AMUtils.toNearestMetric(self.storageInfo!.totalVideoSize, desiredFraction: 1)
            self.photosSizeLabel.text = photos
            self.videosSizeLabel.text = videos
            self.photosSpace?.text = photos
            self.videosSpace?.text = videos
        }
    }

    // MARK: - Navigation

    @objc private func openDuplicatePhotos() {
        push(storyboardId: "DuplicatePhotosViewController")
    }

    @objc private func openScreenshots() {
        push(storyboardId: "ScreenshotsViewController")
    }

    @objc private func openLargeVideos() {
        push(storyboardId: "VideosViewController")
    }

    private func push(storyboardId: String) {
        guard let sb = storyboard,
              let vc = sb.instantiateViewController(withIdentifier: storyboardId) as UIViewController? else { return }
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - UI Construction

    private func buildModernUI() {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .always
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
        ])

        let hp: CGFloat = 16

        // Header
        let titleLabel = makeLabel("Phone Cleaner", font: .systemFont(ofSize: 32, weight: .bold), color: .label)
        let subtitleLabel = makeLabel("Keep your iPhone clean & fast", font: .systemFont(ofSize: 14), color: .secondaryLabel)

        // Storage card
        let storageCard = makeCard()
        let storageCardContent = buildStorageCardContent()
        storageCard.addSubview(storageCardContent)
        pin(storageCardContent, to: storageCard)

        // Action cards
        let duplicateCard = makeActionCard(
            icon: "photo.on.rectangle.angled",
            iconColor: accentColor,
            title: "Duplicate Photos",
            subtitle: "Remove similar & duplicate photos",
            buttonTitle: "Scan for Duplicates",
            action: #selector(openDuplicatePhotos)
        )
        let screenshotCard = makeActionCard(
            icon: "camera.viewfinder",
            iconColor: .systemBlue,
            title: "Screenshot Cleaner",
            subtitle: "Delete large screenshot files",
            buttonTitle: "Scan Screenshots",
            action: #selector(openScreenshots)
        )
        let videoCard = makeActionCard(
            icon: "play.rectangle.fill",
            iconColor: .systemPurple,
            title: "Large Videos",
            subtitle: "Free up space from big video files",
            buttonTitle: "Scan Large Videos",
            action: #selector(openLargeVideos)
        )

        [titleLabel, subtitleLabel, storageCard, duplicateCard, screenshotCard, videoCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: hp),
            titleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -hp),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            storageCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            storageCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: hp),
            storageCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -hp),

            duplicateCard.topAnchor.constraint(equalTo: storageCard.bottomAnchor, constant: 14),
            duplicateCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: hp),
            duplicateCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -hp),

            screenshotCard.topAnchor.constraint(equalTo: duplicateCard.bottomAnchor, constant: 12),
            screenshotCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: hp),
            screenshotCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -hp),

            videoCard.topAnchor.constraint(equalTo: screenshotCard.bottomAnchor, constant: 12),
            videoCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: hp),
            videoCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -hp),
            videoCard.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28),
        ])
    }

    private func buildStorageCardContent() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        // Ring + center labels
        ringView.translatesAutoresizingMaskIntoConstraints = false

        percentLabel.font = .systemFont(ofSize: 38, weight: .bold)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center
        percentLabel.text = "0%"
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        let usedRingLabel = makeLabel("Used", font: .systemFont(ofSize: 13, weight: .medium), color: .secondaryLabel)
        usedRingLabel.textAlignment = .center
        usedRingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stat strip: Used | Total | Free
        let statStrip = UIStackView()
        statStrip.axis = .horizontal
        statStrip.distribution = .fillEqually
        statStrip.translatesAutoresizingMaskIntoConstraints = false

        let usedStat = makeStatCell(icon: "internaldrive.fill", color: accentColor, title: "Used", valueLabel: usedStatLabel)
        let totalStat = makeStatCell(icon: "externaldrive.fill", color: .systemBlue, title: "Total", valueLabel: totalStatLabel)
        let freeStat = makeStatCell(icon: "checkmark.seal.fill", color: .systemTeal, title: "Free", valueLabel: freeStatLabel)

        statStrip.addArrangedSubview(usedStat)
        statStrip.addArrangedSubview(totalStat)
        statStrip.addArrangedSubview(freeStat)

        let statDivider = makeHorizontalDivider()

        // Media strip: Photos | Videos
        let mediaStrip = UIStackView()
        mediaStrip.axis = .horizontal
        mediaStrip.distribution = .fillEqually
        mediaStrip.translatesAutoresizingMaskIntoConstraints = false

        let photoCell = makeStatCell(icon: "photo.fill", color: .systemOrange, title: "Photos", valueLabel: photosSizeLabel)
        let videoCell = makeStatCell(icon: "video.fill", color: .systemPurple, title: "Videos", valueLabel: videosSizeLabel)

        mediaStrip.addArrangedSubview(photoCell)
        mediaStrip.addArrangedSubview(videoCell)

        [ringView, percentLabel, usedRingLabel, statStrip, statDivider, mediaStrip].forEach {
            wrapper.addSubview($0)
        }

        NSLayoutConstraint.activate([
            ringView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 28),
            ringView.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            ringView.widthAnchor.constraint(equalToConstant: 180),
            ringView.heightAnchor.constraint(equalToConstant: 180),

            percentLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor, constant: -10),

            usedRingLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 2),
            usedRingLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),

            statStrip.topAnchor.constraint(equalTo: ringView.bottomAnchor, constant: 16),
            statStrip.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            statStrip.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            statStrip.heightAnchor.constraint(equalToConstant: 92),

            statDivider.topAnchor.constraint(equalTo: statStrip.bottomAnchor),
            statDivider.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            statDivider.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),

            mediaStrip.topAnchor.constraint(equalTo: statDivider.bottomAnchor),
            mediaStrip.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            mediaStrip.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            mediaStrip.heightAnchor.constraint(equalToConstant: 92),
            mediaStrip.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
        ])

        return wrapper
    }

    // MARK: - View Factory Helpers

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeStatCell(icon: String, color: UIColor, title: String, valueLabel: UILabel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConfig))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeLabel(title, font: .systemFont(ofSize: 11, weight: .medium), color: .secondaryLabel)
        titleLabel.textAlignment = .center
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.text = "--"
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.numberOfLines = 1
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        [iconView, titleLabel, valueLabel].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 31),
            iconView.heightAnchor.constraint(equalToConstant: 31),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
        ])
        return container
    }

    private func makeVerticalDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    private func makeHorizontalDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    private func makeActionCard(icon: String, iconColor: UIColor, title: String,
                                subtitle: String, buttonTitle: String, action: Selector) -> UIView {
        let card = makeCard()

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConfig))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 12
        iconBg.layer.cornerCurve = .continuous
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        let titleLabel = makeLabel(title, font: .systemFont(ofSize: 17, weight: .semibold), color: .label)
        let subtitleLabel = makeLabel(subtitle, font: .systemFont(ofSize: 13), color: .secondaryLabel)

        let button = UIButton(type: .custom)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = iconColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let tapOverlay = UIButton(type: .custom)
        tapOverlay.translatesAutoresizingMaskIntoConstraints = false
        tapOverlay.addTarget(self, action: action, for: .touchUpInside)

        [iconBg, titleLabel, subtitleLabel, button, chevron, tapOverlay].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.widthAnchor.constraint(equalToConstant: 48),
            iconBg.heightAnchor.constraint(equalToConstant: 48),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor, constant: -9),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            chevron.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16),

            button.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            tapOverlay.topAnchor.constraint(equalTo: card.topAnchor),
            tapOverlay.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            tapOverlay.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            tapOverlay.heightAnchor.constraint(equalTo: iconBg.heightAnchor, constant: 36),
        ])

        return card
    }

    private func pin(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }
}

// MARK: - MultiProgressView DataSource (hidden progress view stays functional)

extension CleanerViewController: MultiProgressViewDataSource {

    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let s = ProgressViewSection()
        s.borderColor = .clear
        s.backgroundColor = section == 0
            ? UIColor(red: 0.517, green: 0.948, blue: 0.440, alpha: 1)
            : UIColor(red: 0.522, green: 0.522, blue: 0.522, alpha: 1)
        return s
    }

    func numberOfSections(in progressView: MultiProgressView) -> Int { 2 }
}
