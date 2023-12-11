//
//  ScreenshotCollectionViewCell.swift
//  Cleaner
//
//  Created by Alexey on 20.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

class ScreenshotCollectionViewCell: UICollectionViewCell {
    var currentId = 0
    var showedId = ""
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    
    var photoAsset: ImageObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reload() {
        if let asset = photoAsset?.asset {
            if showedId != asset.localIdentifier {
                currentId = ImageManager.takeImageFromAsset(asset: asset, completion: { photo, id in
                    DispatchQueue.main.async {
                        if id == self.currentId {
                            self.imageView.image = photo
                            self.showedId = asset.localIdentifier
                            self.labelView.text = Formatter.humanReadableByteCount(bytes: self.photoAsset?.size ?? 0)
                        }
                    }
                })
            }
        }
    }
    
    override func prepareForReuse() {
        ImageManager.cancelImageRequest(id: currentId)
    }
}
