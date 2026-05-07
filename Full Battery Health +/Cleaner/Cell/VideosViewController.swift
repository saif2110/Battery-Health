//
//  VideosViewController.swift
//  Cleaner
//
//  Created by Alexey on 22.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos
//import SPStorkController


class VideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  /// Storyboard header container — same role as Screenshots’ `bNU-K8-OME`.
  private weak var videoHeaderContainer: UIView?
  /// Bottom selection chrome (`MuQ-hy-DH8`); kept above the collection view.
  private weak var selectionChromeView: UIView?

  private var lastCollectionBottomInset: CGFloat = -1

  private static let listSectionTitle = "Manual selection"
  private static let listAccentColor: UIColor = .systemPurple

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var counutLabelView: UILabel!
  @IBOutlet weak var constraint: NSLayoutConstraint!
  @IBOutlet weak var saveSpaceUpto: UILabel!
  @IBOutlet weak var duplicatesScreenShot: UILabel!
  
  @IBAction func removeAction() {
    self.deleteAssetes(toDelete: self.arrayOfRemoveVideos.map({$0.asset!}))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  func deleteAssetes(toDelete: [PHAsset]) {
    
    if !UserDefaults.standard.bool(forKey: "pro"){
        let vc = Apps15init.shared.makeIAPVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      return
    }
    
    
    let alert = UIAlertController(title: "Delete Videos!", message: "Delete all selected videos from phone", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(toDelete.count) videos", style: .destructive) { _ in
      
      //            if !UserDefaults.standard.bool(forKey: "isBuyed") {
      //                self.showSubscription()
      //                return
      //            }
      
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
      }) { bool, error in
        guard bool else { return }
        DispatchQueue.main.async {
          self.arrayOfRemoveVideos = []
          self.updateButton()
          self.takeAssets()
        }
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func updateButton() {
    DispatchQueue.main.async {
      self.counutLabelView.text = "\(self.arrayOfRemoveVideos.count)"
      if self.arrayOfRemoveVideos.count > 0 {
        self.constraint.constant = 16
      } else {
        self.constraint.constant = -200
      }
      UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
      } completion: { _ in
        self.updateCollectionBottomInset()
      }
    }
  }
  
  var VideoAsset: PHFetchResult<PHAsset>?
  var arrayOfRemoveVideos: [ImageObject] = []
  var arrayOfVideos: [ImageObject]? {
    didSet {
      if VideoAsset?.count ?? 0 == arrayOfVideos?.count ?? 0 {
        arrayOfVideos?.sort(by: { i1, i2 in i1.size > i2.size})
        self.collectionView.reloadData()
        //self.activityView.isHidden = true
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hidesBottomBarWhenPushed = true
    view.backgroundColor = .systemGroupedBackground
    collectionView.backgroundColor = .clear
    collectionView.layer.cornerRadius = 0
    collectionView.layer.masksToBounds = false
    collectionView.contentInset = .zero
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(
      CleanerListSectionHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CleanerListSectionHeader.reuseId
    )
    activityView?.isHidden = true
    if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flow.scrollDirection = .vertical
      flow.minimumLineSpacing = 8
      flow.minimumInteritemSpacing = 0
      flow.estimatedItemSize = .zero
      flow.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 28, right: 16)
    }

    title = "Large Videos"
    navigationItem.largeTitleDisplayMode = .never

    installModernHeader()
    installModernSelectionBar()

    photoLibraryAuthorization(success: { self.takeAssets() }, failed: { fatalError("You need to be authorized") })
    updateButton()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let header = videoHeaderContainer {
      view.bringSubviewToFront(header)
    }
    if let chrome = selectionChromeView {
      view.bringSubviewToFront(chrome)
    }
    updateCollectionBottomInset()
  }

  /// Footer scroll padding so the last row can scroll with extra bottom margin (matches Screenshots).
  private static let collectionBottomFooterInset: CGFloat = 200

  private func updateCollectionBottomInset() {
    let bottom = Self.collectionBottomFooterInset
    guard abs(bottom - lastCollectionBottomInset) > 0.5 else { return }
    lastCollectionBottomInset = bottom
    var inset = collectionView.contentInset
    inset.bottom = bottom
    collectionView.contentInset = inset
    collectionView.verticalScrollIndicatorInsets.bottom = bottom
  }

  private func installModernHeader() {
    guard let headerView = saveSpaceUpto.superview else { return }
    videoHeaderContainer = headerView
    headerView.subviews.forEach { $0.removeFromSuperview() }
    headerView.backgroundColor = .clear

    if let h = headerView.constraints.first(where: { $0.firstAttribute == .height }) {
      h.constant = 268
    }

    let card = CleanerHeaderCard(
      icon: "play.rectangle.fill",
      accent: .systemPurple,
      title: "Large Videos",
      countCaption: "Total Videos",
      sizeCaption: "Save up to",
      buttonTitle: "Remove All Videos",
      helpText: "Above option will remove all the videos shown below",
      compactMetrics: true,
      onPrimary: { [weak self] in
        guard let self = self else { return }
        self.removeAll(self)
      }
    )
    headerView.addSubview(card)
    NSLayoutConstraint.activate([
      card.topAnchor.constraint(equalTo: headerView.topAnchor),
      card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
      card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
      card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
    ])

    saveSpaceUpto = card.sizeLabel
    duplicatesScreenShot = card.countLabel

    view.layoutIfNeeded()
    view.bringSubviewToFront(headerView)
  }

  private func installModernSelectionBar() {
    guard let bar = counutLabelView.superview else { return }
    selectionChromeView = bar.superview
    bar.subviews.forEach { $0.removeFromSuperview() }
    bar.backgroundColor = .clear

    let selection = CleanerSelectionBar(
      buttonTitle: "Delete Selected",
      accent: .systemPurple,
      onPrimary: { [weak self] in self?.removeAction() }
    )
    bar.addSubview(selection)
    NSLayoutConstraint.activate([
      selection.topAnchor.constraint(equalTo: bar.topAnchor),
      selection.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
      selection.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
      selection.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
    ])
    counutLabelView = selection.countLabel
  }
  
  func photoLibraryAuthorization(success: @escaping () -> Void, failed: @escaping () -> Void) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      success()
    case .denied:
      failed()
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({ status in
        if status == .authorized {
          DispatchQueue.main.async { success() }
        } else {
          DispatchQueue.main.async { failed() }
        }
      })
    case .restricted:
      failed()
    default:
      failed()
    }
  }
  
  @IBAction func removeAll(_ sender: Any) {
    
    
    if !UserDefaults.standard.bool(forKey: "pro"){
        let vc = Apps15init.shared.makeIAPVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      return
    }

    
    let alert = UIAlertController(title: "Delete Screeenshots!", message: "Delete all selected screeenshots shown below.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(self.arrayOfVideos?.count ?? 0) images", style: .destructive) { _ in
      
      var phpAssets = self.arrayOfVideos?.compactMap { $0.asset }
      if let phpAssets = phpAssets {
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.deleteAssets(phpAssets as NSArray)
        }) { bool, error in
          guard bool else { return }
          DispatchQueue.main.async {
            self.arrayOfRemoveVideos = []
            self.updateButton()
            self.arrayOfVideos?.removeAll()
            self.saveSpaceUpto.text = "0 MB"
            self.duplicatesScreenShot.text = "0"
            self.collectionView.reloadData()
          }
        }
      }
      
      //self.takeAssetsDataToModel()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func takeAssets() {
    self.VideoAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.video.rawValue, subtypeOfAlbum: .smartAlbumVideos)
    self.takeAssetsDataToModel()
  }
  
  func takeAssetsDataToModel() {
    guard let VideoAsset = VideoAsset else { return }

    let loading = CleanerScanLoadingView()
    loading.configure(
      title: "Loading videos",
      detail: "Analyzing video file sizes. iCloud items may take longer."
    )
    loading.attach(to: navigationController?.view ?? view)
    loading.setProgress(0, animated: false)

    ImageManager.takeAllDataFromAssetFetchResult(
      fetchedResult: VideoAsset,
      mediaType: .video,
      progress: { p in loading.setProgress(p) },
      completion: { [weak self] data, isLast in
        guard let self = self else {
          if isLast { loading.dismiss() }
          return
        }
        self.arrayOfVideos = data
        if isLast {
          self.arrayOfVideos?.sort(by: { i1, i2 in i1.size > i2.size })
          self.collectionView.reloadData()
        }
        self.duplicatesScreenShot.text = String(self.arrayOfVideos?.count ?? 0)
        let totalSize = self.arrayOfVideos?.reduce(0) { $0 + $1.size }
        self.saveSpaceUpto.text = Formatter.humanReadableByteCount(bytes: totalSize ?? 0)
        if isLast {
          loading.dismiss()
        }
      }
    )
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if self.arrayOfVideos?.count == 0 || self.arrayOfVideos?.count == nil {
      
      self.collectionView.setEmptyMessage("✨ Great news!\nYour video collection is pristine – no unnecessary videos found!")
      
    } else {
      
      self.collectionView.restore()
    
    }
    
    return arrayOfVideos?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScreenshotCollectionViewCell
    if let image = arrayOfVideos?[indexPath.row] {
      cell.photoAsset = image
      cell.reload()
      cell.configureSelectionState(isMarkedForDeletion(image))
    }
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let image = arrayOfVideos?[indexPath.row] else { return }

    if let existingIdx = arrayOfRemoveVideos.firstIndex(where: { $0.localId == image.localId }) {
      arrayOfRemoveVideos.remove(at: existingIdx)
    } else {
      arrayOfRemoveVideos.append(image)
    }

    if let cell = collectionView.cellForItem(at: indexPath) as? ScreenshotCollectionViewCell {
      let nowSelected = isMarkedForDeletion(image)
      UIView.animate(withDuration: 0.10, animations: {
        cell.contentView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
      }) { _ in
        cell.configureSelectionState(nowSelected)
        UIView.animate(withDuration: 0.18) {
          cell.contentView.transform = .identity
        }
      }
    }
    updateButton()
  }

  private func isMarkedForDeletion(_ image: ImageObject) -> Bool {
    return arrayOfRemoveVideos.contains(where: { $0.localId == image.localId })
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    guard section == 0, (arrayOfVideos?.count ?? 0) > 0 else { return .zero }
    let w = collectionView.bounds.width > 0 ? collectionView.bounds.width : view.bounds.width
    return CGSize(width: w, height: 46)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: CleanerListSectionHeader.reuseId,
      for: indexPath
    ) as! CleanerListSectionHeader
    header.configure(title: Self.listSectionTitle, accent: Self.listAccentColor)
    return header
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let flow = collectionViewLayout as? UICollectionViewFlowLayout
    let insetH = (flow?.sectionInset.left ?? 0) + (flow?.sectionInset.right ?? 0)
    let w = collectionView.bounds.width > 0 ? collectionView.bounds.width : view.bounds.width
    let width = w - insetH
    return CGSize(width: max(width, 0), height: 108)
  }
  
  //    func showSubscription() {
  //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //        let controller = storyboard.instantiateViewController(withIdentifier: "SubscribeViewController")
  //        let transitionDelegate = SPStorkTransitioningDelegate()
  //        transitionDelegate.customHeight = 460
  //        controller.transitioningDelegate = transitionDelegate
  //        controller.modalPresentationStyle = .custom
  //        controller.modalPresentationCapturesStatusBarAppearance = true
  //
  //        self.present(controller, animated: true, completion: nil)
  //    }
  
  
}
