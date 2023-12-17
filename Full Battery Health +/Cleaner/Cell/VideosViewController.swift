//
//  VideosViewController.swift
//  Cleaner
//
//  Created by Alexey on 22.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos
import SPStorkController


class VideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var counutLabelView: UILabel!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    @IBAction func removeAction() {
        self.deleteAssetes(toDelete: self.arrayOfRemoveVideos.map({$0.asset!}))
    }
    
    func deleteAssetes(toDelete: [PHAsset]) {
        let alert = UIAlertController(title: "Delete videos", message: "save selected image and delete duplicates", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete \(toDelete.count) videos", style: .destructive) { _ in
            
            if !UserDefaults.standard.bool(forKey: "isBuyed") {
                self.showSubscription()
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
            }) { bool, error in
                if bool {
                    self.arrayOfRemoveVideos = []
                    self.updateButton()
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
                self.constraint.constant = -100
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
                self.activityView.isHidden = true
            }
        }
    }

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
        self.VideoAsset = ImageManager.takeAssetsfor(mediaType: PHAssetMediaType.video.rawValue, subtypeOfAlbum: .smartAlbumVideos)
        self.takeAssetsDataToModel()
    }
    
    func takeAssetsDataToModel() {
        guard let VideoAsset = VideoAsset else { return }
        ImageManager.takeAllDataFromAssetFetchResult(fetchedResult: VideoAsset, mediaType: .video) { self.arrayOfVideos = $0; if $1 == true {
        self.arrayOfVideos?.sort(by: { i1, i2 in i1.size > i2.size})
        self.collectionView.reloadData()
        self.activityView.isHidden = true} }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func showSubscription() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SubscribeViewController")
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = 460
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        
        self.present(controller, animated: true, completion: nil)
    }


}
