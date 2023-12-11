//
//  DuplicatePhotosViewController.swift
//  Full Battery Health
//
//  Created by Saif on 07/12/23.
//

import Foundation
import UIKit
import Photos

class DuplicatePhotosViewController:UIViewController, UITableViewDataSource, DublicatesTableViewCellDelegate {
  
  @IBOutlet weak var saveupto: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var photoAsset: PHFetchResult<PHAsset>?
  var videoAsset: PHFetchResult<PHAsset>?
  var screenshotAsset: PHFetchResult<PHAsset>?
  var arrayOfVideos: [ImageObject]?
  var arrayOfScreenshots: [ImageObject]?
  
  var duplicates: [[PHAsset]]?
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewDidLoad() {
    tableView.dataSource = self
    photoLibraryAuthorization(success: { self.takeAssets() }, failed: { fatalError("You need to be authorized") })
  }
  
  @IBAction func removeAllduplicate(_ sender: Any) {
    
    guard duplicates?.count ?? 0 > 0 else { return }
    
    let alert = UIAlertController(title: "🔄🗑️ Delete all duplicate photos", message: "NOTE - You will see a few pop-ups asking if you want to delete. Just choose what you want.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete all images", style: .destructive) { _ in
      
      
      if let dupArrays = self.duplicates {
        for i in dupArrays {
          self.deleteAssetesAll(toDelete: i)
        }
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    self.present(alert, animated: true, completion: nil)
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
    self.photoAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.image.rawValue, subtypeOfAlbum: .smartAlbumUserLibrary)
    self.videoAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.video.rawValue, subtypeOfAlbum: .smartAlbumVideos)
    self.screenshotAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.image.rawValue, subtypeOfAlbum: .smartAlbumScreenshots)
    
    self.takeAssetsDataToModel()
  }
  
  
  func takeAssetsDataToModel() {
    guard let photoAsset = photoAsset else { return }
    
    self.duplicates = []
    //  self.activityIndicator.isHidden = false
    
    ImageManager.takeDuplicatesFromCollection(fetchedAsset: photoAsset, completion: { dupl in
      self.duplicates?.append(contentsOf: dupl)
      DispatchQueue.main.async {
        self.tableView.reloadData()
        //   dupl self.activityIndicator.isHidden = true
        self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
        guard self.duplicates?.count != 0 else {return}
        let numberoDups = self.duplicates?.count ?? 0
        self.saveupto.text = "\(Double(numberoDups) * 4) MB"
      }
    })
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if self.duplicates?.count == 0 {
      self.tableView.setEmptyMessage("✨ Great news!\nYour photo collection is pristine – no duplicate photos found!")
    } else {
      self.tableView.restore()
    }
    
    return self.duplicates?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DublicatesTableViewCell
    ImageManager.cancelImageRequest(id: cell.currentId)
    cell.indexPath = indexPath.item
    cell.reload(duplicates: self.duplicates![indexPath.row])
    cell.delegate = self
    return cell
  }
  
  func deleteAssetes(toDelete: [PHAsset]) {
    let alert = UIAlertController(title: "Delete photos", message: "Save selected image and delete duplicates.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(toDelete.count) images", style: .destructive) { _ in
      
      //      if !UserDefaults.standard.bool(forKey: "isBuyed") {
      //        self.showSubscription()
      //        return
      //      }
      
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
      }) { bool, error in
        if bool {
          if let duplicates = self.duplicates {
            for (indexi, i) in duplicates.enumerated() {
              if i.contains(toDelete.first!) {
                self.duplicates?.remove(at: indexi)
              }
            }
          }
          DispatchQueue.main.async {
            self.tableView.reloadData()
            self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
            
            guard self.duplicates?.count != 0 else {return}
            let numberoDups = self.duplicates?.count ?? 0
            self.saveupto.text = "\(Double(numberoDups) * 1.5) MB"
          }
        }
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    self.present(alert, animated: true, completion: nil)
  }
  
  
  func deleteAssetesAll(toDelete: [PHAsset]) {
    
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
    }) { bool, error in
      if bool {
        if let duplicates = self.duplicates {
          for (indexi, i) in duplicates.enumerated() {
            if i.contains(toDelete.first!) {
              self.duplicates?.remove(at: indexi)
            }
          }
        }
        DispatchQueue.main.async {
          self.tableView.reloadData()
          self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
          
          guard self.duplicates?.count != 0 else {return}
          let numberoDups = self.duplicates?.count ?? 0
          self.saveupto.text = "\(Double(numberoDups) * 1.5) MB"
        }
      }
    }
  }
  
  
  
  
}


