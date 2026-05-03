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


class VideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
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
        let vc = InAppVC()
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
        if bool {
          self.arrayOfRemoveVideos = []
          self.updateButton()
          DispatchQueue.main.async {
            self.takeAssets()
          }
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
    view.backgroundColor = .systemGroupedBackground
    collectionView.backgroundColor = .clear
    collectionView.layer.cornerRadius = 16
    collectionView.layer.masksToBounds = true
    collectionView.delegate = self
    collectionView.dataSource = self
    activityView?.isHidden = true

    title = "Large Videos"
    navigationItem.largeTitleDisplayMode = .never

    installModernHeader()
    installModernSelectionBar()

    photoLibraryAuthorization(success: { self.takeAssets() }, failed: { fatalError("You need to be authorized") })
    updateButton()
  }

  private func installModernHeader() {
    guard let headerView = saveSpaceUpto.superview else { return }
    headerView.subviews.forEach { $0.removeFromSuperview() }
    headerView.backgroundColor = .clear

    if let h = headerView.constraints.first(where: { $0.firstAttribute == .height }) {
      h.constant = 290
    }

    let card = CleanerHeaderCard(
      icon: "play.rectangle.fill",
      accent: .systemPurple,
      title: "Large Videos",
      countCaption: "Total Videos",
      sizeCaption: "Save up to",
      buttonTitle: "Remove All Videos",
      helpText: "Above option will remove all the videos shown below",
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
  }

  private func installModernSelectionBar() {
    guard let bar = counutLabelView.superview else { return }
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
        let vc = InAppVC()
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
          if bool {
            self.arrayOfRemoveVideos = []
            self.updateButton()
            self.arrayOfVideos?.removeAll()
            DispatchQueue.main.async {
              self.saveSpaceUpto.text = "0 MB"
              self.duplicatesScreenShot.text = "0"
              self.collectionView.reloadData()
            }
            
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
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let image = arrayOfVideos?[indexPath.row] {
      self.arrayOfRemoveVideos.append(image)
      updateButton()
    }
    collectionView.performBatchUpdates({
      arrayOfVideos?.remove(at: indexPath.row)
      collectionView.deleteItems(at: [indexPath])
    }, completion: nil)
    
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
