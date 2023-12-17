//
//  ScreenshotsViewController.swift
//  Cleaner
//
//  Created by Alexey on 20.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos
//import SPStorkController


class ScreenshotsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet weak var saveSpaceUpto: UILabel!
  @IBOutlet weak var duplicatesScreenShot: UILabel!
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var counutLabelView: UILabel!
  @IBOutlet weak var constraint: NSLayoutConstraint!
  
  @IBAction func removeAction() {
    self.deleteAssetes(toDelete: self.arrayOfRemoveScreenshots.map({$0.asset!}))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  func deleteAssetes(toDelete: [PHAsset]) {
    let alert = UIAlertController(title: "Delete Screeenshots!", message: "Delete all selected screeenshots from phone.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(toDelete.count) images", style: .destructive) { _ in
      
      //            if !UserDefaults.standard.bool(forKey: "isBuyed") {
      //                self.showSubscription()
      //                return
      //            }
      
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
      }) { bool, error in
        if bool {
          self.arrayOfRemoveScreenshots = []
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
      self.counutLabelView.text = "\(self.arrayOfRemoveScreenshots.count)"
      if self.arrayOfRemoveScreenshots.count > 0 {
        self.constraint.constant = 16
      } else {
        self.constraint.constant = -200
      }
      UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  
  @IBAction func removeAll(_ sender: Any) {
    
    let alert = UIAlertController(title: "Delete Screeenshots!", message: "Delete all selected screeenshots shown below.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(self.arrayOfScreenshots?.count ?? 0) images", style: .destructive) { _ in
      
      //            if !UserDefaults.standard.bool(forKey: "isBuyed") {
      //                self.showSubscription()
      //                return
      //            }
      
      var phpAssets = self.arrayOfScreenshots?.compactMap { $0.asset }
      if let phpAssets = phpAssets {
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.deleteAssets(phpAssets as NSArray)
        }) { bool, error in
          if bool {
            self.arrayOfRemoveScreenshots = []
            self.updateButton()
            self.arrayOfScreenshots?.removeAll()
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
  
  var screenshotAsset: PHFetchResult<PHAsset>?
  var arrayOfRemoveScreenshots: [ImageObject] = []
  var arrayOfScreenshots: [ImageObject]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    
    photoLibraryAuthorization(success: { self.takeAssets() }, failed: { fatalError("You need to be authorized") })
    self.updateButton()
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
  
  func takeAssets() {
    self.screenshotAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.image.rawValue, subtypeOfAlbum: .smartAlbumScreenshots)
    
    self.takeAssetsDataToModel()
    
  }
  
  func takeAssetsDataToModel() {
    guard let screenshotAsset = screenshotAsset else { return }
    ImageManager.takeAllDataFromAssetFetchResult(fetchedResult: screenshotAsset, mediaType: .screenshots) { self.arrayOfScreenshots = $0; if $1 == true {
      self.arrayOfScreenshots?.sort(by: { i1, i2 in i1.size > i2.size})
      self.collectionView.reloadData()
      //self.activityView.isHidden = true
    }
      
      self.duplicatesScreenShot.text = String(self.arrayOfScreenshots?.count ?? 0)
      let totalSize = self.arrayOfScreenshots?.reduce(0) {$0 + $1.size}
      self.saveSpaceUpto.text =  Formatter.humanReadableByteCount(bytes:  totalSize ?? 0 )
      
    }
    
    
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
      if self.arrayOfScreenshots?.count == 0 || self.arrayOfScreenshots?.count == nil {
        self.collectionView.setEmptyMessage("✨ Great news!\nYour photo collection is pristine – no unnecessary screenshots found!")
      } else {
        self.collectionView.restore()
      }
    
    return arrayOfScreenshots?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScreenshotCollectionViewCell
    if let image = arrayOfScreenshots?[indexPath.row] {
      cell.photoAsset = image
      cell.reload()
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let image = arrayOfScreenshots?[indexPath.row] {
      self.arrayOfRemoveScreenshots.append(image)
      updateButton()
    }
    collectionView.performBatchUpdates({
      arrayOfScreenshots?.remove(at: indexPath.row)
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
