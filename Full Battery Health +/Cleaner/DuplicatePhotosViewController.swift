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

  private var scanLoadingView: CleanerScanLoadingView?
  private var modernHeader: CleanerHeaderCard?
  private var lastDuplicateTableBottomInset: CGFloat = -1
  // Detached labels keep the storyboard outlets alive after we strip the legacy header.
  private let detachedSaveLabel = UILabel()
  private let detachedStatusLabel = UILabel()
  
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
    super.viewDidLoad()
    hidesBottomBarWhenPushed = true
    view.backgroundColor = .systemGroupedBackground
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.estimatedRowHeight = 363
    tableView.rowHeight = UITableView.automaticDimension
    tableView.contentInset = .zero
    activityIndicator?.isHidden = true

    title = "Duplicate Photos"
    navigationItem.largeTitleDisplayMode = .never

    installModernHeader()
    photoLibraryAuthorization(success: { self.takeAssets() }, failed: { fatalError("You need to be authorized") })
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    sizeModernHeader()
    let padding: CGFloat = 24
    var bottom = padding
    if let tab = tabBarController, !tab.tabBar.isHidden {
      let tabFrame = tab.tabBar.convert(tab.tabBar.bounds, to: view)
      bottom += max(0, view.bounds.maxY - tabFrame.minY)
    }
    if abs(bottom - lastDuplicateTableBottomInset) > 0.5 {
      lastDuplicateTableBottomInset = bottom
      tableView.contentInset.bottom = bottom
      tableView.verticalScrollIndicatorInsets.bottom = bottom
    }
  }

  private func installModernHeader() {
    let accent = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)
    let header = CleanerHeaderCard(
      icon: "photo.on.rectangle.angled",
      accent: accent,
      title: "Duplicate Photos",
      countCaption: "Duplicate groups",
      sizeCaption: "Save up to",
      buttonTitle: "Remove All Duplicates",
      helpText: "Only the selected files will not be deleted",
      onPrimary: { [weak self] in
        guard let self = self else { return }
        self.removeAllduplicate(self)
      }
    )
    modernHeader = header
    // Re-point IBOutlets to the modern card's labels so existing code keeps working.
    saveupto = header.sizeLabel
    statusLabel = header.countLabel
    tableView.tableHeaderView = header
  }

  private func sizeModernHeader() {
    guard let header = tableView.tableHeaderView else { return }
    let width = tableView.bounds.width
    guard width > 0 else { return }

    // Pin the header to the table's width and let auto layout compute the height.
    header.translatesAutoresizingMaskIntoConstraints = false
    let widthConstraint = header.widthAnchor.constraint(equalToConstant: width)
    widthConstraint.isActive = true
    header.setNeedsLayout()
    header.layoutIfNeeded()
    let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    widthConstraint.isActive = false

    // Switch back to frame-based layout for tableHeaderView.
    header.translatesAutoresizingMaskIntoConstraints = true
    let target = CGRect(x: 0, y: 0, width: width, height: height)
    if header.frame != target {
      header.frame = target
      tableView.tableHeaderView = header
    }
  }
  
  @IBAction func removeAllduplicate(_ sender: Any) {
    
    if !UserDefaults.standard.bool(forKey: "pro"){
        let vc = InAppVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      return
    }
    
    guard duplicates?.count ?? 0 > 0 else { return }
    
    let alert = UIAlertController(title: "🔄🗑️ Delete all duplicate photos", message: "NOTE - You will see a pop-up asking if you want to delete. Just choose what you want.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete all images", style: .destructive) { _ in
      
      
//      if let dupArrays = self.duplicates {
//       // for i in dupArrays {
//        //  let deletedArray = i.filter {$0 != $0}
//        self.deleteAssetesAll(toDelete: dupArrays)
//        }
//     // }
      
      var dups:[PHAsset] = [PHAsset]()
      self.duplicates = self.duplicates?.map { subArray in
          var modifiedArray = subArray
          if !modifiedArray.isEmpty {
              modifiedArray.removeFirst()
          }
          return modifiedArray
      }
      
      self.duplicates.map { array in [[PHAsset]].self
        for i in array {
          dups.append(contentsOf: i)
        }
      }
      
      //self.deleteAssetesAll(toDelete: self.duplicates!)
      
     // if let phpAssets =  self.dups {
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.deleteAssets(dups as NSArray)
        }) { bool, error in
          guard bool else { return }
          DispatchQueue.main.async {
            self.duplicates?.removeAll()
            self.saveupto.text = "0 MB"
            self.statusLabel.text = "0"
            self.tableView.reloadData()
          }
        }
    //  }
      
      
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

    let loading = CleanerScanLoadingView()
    loading.configure(
      title: "Scanning your library",
      detail: "Finding duplicate photos. This may take a minute for large libraries."
    )
    loading.attach(to: navigationController?.view ?? view)
    loading.setProgress(0, animated: false)
    scanLoadingView = loading

    ImageManager.takeDuplicatesFromCollection(
      fetchedAsset: photoAsset,
      progress: { [weak self] p in
        self?.scanLoadingView?.setProgress(p)
      },
      scanFinished: { [weak self] in
        guard let self = self else { return }
        self.scanLoadingView?.dismiss()
        self.scanLoadingView = nil
      },
      completion: { [weak self] dupl in
        guard let self = self else { return }
        self.duplicates?.append(contentsOf: dupl)
        DispatchQueue.main.async {
          self.tableView.reloadData()
          self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
          guard self.duplicates?.count != 0 else { return }
          let numberoDups = self.duplicates?.count ?? 0
          self.saveupto.text = "\(Double(numberoDups) * 4) MB"
        }
      }
    )
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
      if self.duplicates?.count == 0 {
        self.tableView.setEmptyMessage("✨ Great news!\nYour photo collection is pristine – no duplicate photos found!")
      } else {
        self.tableView.restore()
      }
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
    
    if !UserDefaults.standard.bool(forKey: "pro"){
        let vc = InAppVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      return
    }

    
    let alert = UIAlertController(title: "Delete photos", message: "Save selected image and delete duplicates.", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete \(toDelete.count) images", style: .destructive) { _ in
      
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
      }) { bool, error in
        guard bool else { return }
        DispatchQueue.main.async {
          if let duplicates = self.duplicates {
            for (indexi, i) in duplicates.enumerated() {
              if i.contains(toDelete.first!) {
                self.duplicates?.remove(at: indexi)
              }
            }
          }
          self.tableView.reloadData()
          self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
          
          guard self.duplicates?.count != 0 else { return }
          let numberoDups = self.duplicates?.count ?? 0
          self.saveupto.text = "\(Double(numberoDups) * 1.5) MB"
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
      guard bool else { return }
      DispatchQueue.main.async {
        if let duplicates = self.duplicates {
          for (indexi, i) in duplicates.enumerated() {
            if i.contains(toDelete.first!) {
              self.duplicates?.remove(at: indexi)
            }
          }
        }
        self.tableView.reloadData()
        self.statusLabel.text = "\(self.duplicates?.count ?? 0)"
        
        guard self.duplicates?.count != 0 else { return }
        let numberoDups = self.duplicates?.count ?? 0
        self.saveupto.text = "\(Double(numberoDups) * 1.5) MB"
      }
    }
  }
  
  
  
  
}


