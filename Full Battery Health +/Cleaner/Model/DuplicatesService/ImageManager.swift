//
//  ImageManager.swift
//  ChoosePhoto
//
//  Created by Developer on 09/07/2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import UIKit
import Photos

enum MediaType {
  case photo
  case video
  case screenshots
}

class ImageManager {
  // MARK: - Properties
  static let fetchOptions: PHFetchOptions = {
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    return options
  }()
  
  // MARK: - Methods
  // Returns video size from PHAssetResource metadata, which works for iCloud-only assets that
  // requestAVAsset can't resolve to a local file (otherwise large iCloud videos disappear from
  // the Large Video Cleaner list while the storage summary still counts them).
  fileprivate static func videoFileSizeFromResources(asset: PHAsset) -> Int {
    let resources = PHAssetResource.assetResources(for: asset)
    let preferred: [PHAssetResourceType] = [.video, .fullSizeVideo, .pairedVideo, .fullSizePairedVideo]
    let candidates = resources.filter { preferred.contains($0.type) }
    let pool = candidates.isEmpty ? resources : candidates
    var maxSize = 0
    for r in pool {
      if let size = r.value(forKey: "fileSize") as? Int, size > maxSize {
        maxSize = size
      } else if let size = r.value(forKey: "fileSize") as? Int64, Int(size) > maxSize {
        maxSize = Int(size)
      }
    }
    return maxSize
  }

  class func takeAssetsfor(mediaType: CVarArg, subtypeOfAlbum: PHAssetCollectionSubtype) -> PHFetchResult<PHAsset> {
    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType)
    let allCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtypeOfAlbum, options: nil)
    return PHAsset.fetchAssets(in: allCollection.object(at: 0), options: fetchOptions)
  }
  
  class func takeAllDataFromAssetFetchResult(
    fetchedResult: PHFetchResult<PHAsset>,
    mediaType: MediaType,
    progress: ((Float) -> Void)? = nil,
    completion: @escaping ([ImageObject], Bool) -> Void
  ) {
    let total = fetchedResult.count
    if total == 0 {
      DispatchQueue.main.async {
        progress?(1)
        completion([], true)
      }
      return
    }

    final class DoneCounter: @unchecked Sendable {
      var n = 0
      let lock = NSLock()
      func increment() -> Int {
        lock.lock()
        n += 1
        let v = n
        lock.unlock()
        return v
      }
    }
    let doneCounter = DoneCounter()

    func bumpDone() {
      let v = doneCounter.increment()
      DispatchQueue.main.async {
        progress?(min(1, Float(v) / Float(total)))
      }
    }

    var isLast = false
    DispatchQueue.global().async {
      var arrayOfAssets = [ImageObject]() {
        willSet {
          DispatchQueue.main.async {
            completion(arrayOfAssets, isLast)
          }
        }
      }

      fetchedResult.enumerateObjects { (asset, index, _) in
        guard let date = asset.creationDate else {
          if fetchedResult.count - 1 == index {
            isLast = true
          }
          bumpDone()
          return
        }
        let localId = asset.localIdentifier
        switch mediaType {
        case .video:
          if fetchedResult.count - 1 == index {
            isLast = true
          }
          let resourceSize = videoFileSizeFromResources(asset: asset)
          if resourceSize > 0 {
            let imageObject = ImageObject(localId: localId, size: resourceSize, date: date, asset: asset)
            arrayOfAssets.append(imageObject)
            bumpDone()
          } else {
            let videoOptions = PHVideoRequestOptions()
            videoOptions.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { (urlAsset, _, _) in
              var fileSize = 0
              if let urlAsset = urlAsset as? AVURLAsset,
                 let values = try? urlAsset.url.resourceValues(forKeys: [.fileSizeKey]),
                 let size = values.fileSize {
                fileSize = size
              }
              if fileSize > 0 {
                let imageObject = ImageObject(localId: localId, size: fileSize, date: date, asset: asset)
                arrayOfAssets.append(imageObject)
              }
              bumpDone()
            }
          }
        default:
          let photoOptions = PHImageRequestOptions()
          photoOptions.isNetworkAccessAllowed = true
          PHImageManager.default().requestImageData(for: asset, options: photoOptions) { (data, _, _, _) in
            if fetchedResult.count - 1 == index {
              isLast = true
            }
            guard let data = data else {
              bumpDone()
              return
            }
            let imageObject = ImageObject(localId: localId, size: data.count, date: date, asset: asset)
            arrayOfAssets.append(imageObject)
            bumpDone()
          }
        }
      }
    }
  }
  
  class func takeAllDataFromArrayOfDuples(array: [[PHAsset]], completion: @escaping ([[ImageObject]]) -> Void) {
    var result = [[ImageObject]]()
    for i in array {
      makeArrayOfImagesFromArrayOfAssets(arrayOfImages: i) {
        result.append($0)
        if result.count == array.count {
          completion(result)
        }
      }
    }
    
  }
  
  
  class func makeArrayOfImagesFromArrayOfAssets(arrayOfImages: [PHAsset], completion: @escaping ([ImageObject]) -> Void) {
    let photoOptions = PHImageRequestOptions()
    photoOptions.isNetworkAccessAllowed = true
    
    var kk: [ImageObject] = []
    for i in arrayOfImages {
      PHImageManager.default().requestImageData(for: i, options: photoOptions) { (data, _, _, _) in
        guard let resultData = data?.count else { return }
        kk.append(ImageObject(localId: i.localIdentifier, size: resultData, date: i.creationDate!))
        if kk.count == arrayOfImages.count {
          completion(kk)
        }
      }
    }
  }
  
  class func takeImageFromAsset(asset: PHAsset, completion: @escaping (UIImage, Int?) -> Void) -> Int {
    let options = PHImageRequestOptions()
    options.deliveryMode = .opportunistic
    options.isNetworkAccessAllowed = true
    options.isSynchronous = false
    
    let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFit, options: options) { (image, data) in
      guard let image = image else { return }
      completion(image, (data?["PHImageResultRequestIDKey"] as? Int))
    }
    
    return Int(imageRequestID)
  }
  
  class func takeFullImageFromAsset(asset: PHAsset, completion: @escaping (UIImage, Int?) -> Void) -> Int {
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    options.isSynchronous = false
    
    let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFit, options: options) { (image, data) in
      guard let image = image else { return }
      completion(image, (data?["PHImageResultRequestIDKey"] as? Int))
    }
    
    return Int(imageRequestID)
  }
  
  class func cancelImageRequest(id: Int) {
    PHImageManager.default().cancelImageRequest(PHImageRequestID(id))
  }
  
  class func takeAssetsFromArrayOfObjects(arrayOfImageObjects: [ImageObject], completion: @escaping (PHAsset) -> Void) {
    let i = arrayOfImageObjects.map { $0.localId }
    
    PHAsset.fetchAssets(withLocalIdentifiers: i, options: fetchOptions).enumerateObjects { (asset, _, _) in
      completion(asset)
    }
  }
  
  class func takeDuplicatesFromCollection(
    fetchedAsset: PHFetchResult<PHAsset>,
    progress: ((Float) -> Void)? = nil,
    scanFinished: (() -> Void)? = nil,
    completion: @escaping ([[PHAsset]]) -> Void
  ) {
    DispatchQueue.global().async {
      var array = [PHAsset]()
      fetchedAsset.enumerateObjects { (asset, _, _) in
        array.append(asset)
      }

      let arrayChunked = array.chunked(into: 1000)
      let chunkCount = arrayChunked.count

      if chunkCount == 0 {
        DispatchQueue.main.async {
          progress?(1)
          completion([])
          scanFinished?()
        }
        return
      }

      final class ChunkDone: @unchecked Sendable {
        var n = 0
        let lock = NSLock()
      }
      let done = ChunkDone()

      for (idx, arraySlice) in arrayChunked.enumerated() {
        let chunkResult = FindDuplicatesUsingThumbnail.findDuples(assets: arraySlice, strictness: .similar)
        DispatchQueue.main.async {
          progress?(Float(idx + 1) / Float(chunkCount))
          completion(chunkResult)
          done.lock.lock()
          done.n += 1
          let allPosted = done.n == chunkCount
          done.lock.unlock()
          if allPosted {
            progress?(1)
            scanFinished?()
          }
        }
      }
    }
  }
}
