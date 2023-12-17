//
//  CleanerViewController.swift
//  Full Battery Health
//
//  Created by Saif on 12/12/23.
//

import UIKit
import MultiProgressView
import Photos

class CleanerViewController: UIViewController,StorageInfoControllerDelegate {

  @IBOutlet weak var totalSpace: UILabel!
  @IBOutlet weak var progressView: MultiProgressView!
  @IBOutlet weak var freeSpace: UILabel!
  @IBOutlet weak var usedSpace: UILabel!
  @IBOutlet weak var photosSpace: UILabel!
  @IBOutlet weak var videosSpace: UILabel!
  var storageInfo: StorageInfo?
  let systemServices = SystemServices()
  
    override func viewDidLoad() {
        super.viewDidLoad()
       // progressView.clipsToBounds = tr
        //progressView.layer.cornerRadius = 14
        progressView.layoutSubviews()
       
    }

  override func viewDidAppear(_ animated: Bool) {
    setupController()
    showSpaceInfo()
  }
  
  func getStorageInfo() {
      SystemMonitor.storageInfoCtrl().delegate = self
      self.storageInfo = SystemMonitor.storageInfoCtrl().getStorageInfo()
  }
  
  func setupController() {
      progressView.dataSource = self
  }
  
  func showSpaceInfo() {
      DispatchQueue.global(qos: .background).async {
          self.getStorageInfo()
      }

      let usedSpace = Float(systemServices.longDiskSpace - systemServices.longFreeDiskSpace) / Float(systemServices.longDiskSpace)
    

      progressView.setProgress(section: 0, to: usedSpace)
      progressView.setProgress(section: 1, to: 1.0 - usedSpace)
    
      self.totalSpace.text =  systemServices.diskSpace
      self.usedSpace.text = systemServices.usedDiskSpaceinRaw
      self.freeSpace.text = "Free Space - " + (systemServices.freeDiskSpaceinRaw ?? "NA")

      if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
          PHPhotoLibrary.requestAuthorization({ (status) -> Void in
              if status != PHAuthorizationStatus.authorized {
                  DispatchQueue.main.async {
                      let alert = UIAlertController(title: "Permission require", message: "Please enable photo permission access in setting", preferredStyle: UIAlertController.Style.alert)
                      alert.addAction(UIAlertAction(title: "Setting", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                      }))
                      alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) in
                          alert.dismiss(animated: true, completion: nil)
                      }))
                      self.present(alert, animated: true, completion: nil)
                  }
              } else {
                  self.storageInfo = SystemMonitor.storageInfoCtrl().getStorageInfo()
              }
          })
      }
  }
    

  func storageInfoUpdated() {
      DispatchQueue.main.async {
          self.videosSpace.text = AMUtils.toNearestMetric(self.storageInfo!.totalVideoSize, desiredFraction: 1)
          self.photosSpace.text = AMUtils.toNearestMetric(self.storageInfo!.totalPictureSize, desiredFraction: 1)
      }
  }

}

extension CleanerViewController:MultiProgressViewDataSource {
 
  func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
      let sectionView = ProgressViewSection()
    sectionView.borderColor = .clear
      if section == 0 {
          sectionView.backgroundColor = #colorLiteral(red: 0.5174177289, green: 0.9475852847, blue: 0.4396975636, alpha: 1)
      } else {
          sectionView.backgroundColor = #colorLiteral(red: 0.5215685964, green: 0.5215685964, blue: 0.5215685964, alpha: 1)
      }
      return sectionView
  }
  
  
  func numberOfSections(in progressView: MultiProgressView) -> Int {
      return 2
  }
}
