//
//  DublicateCollectionViewCell.swift
//  Cleaner
//
//  Created by Alexey on 19.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

class DublicateCollectionViewCell: UICollectionViewCell {
    
    var currentId = 0
    var showedId = ""
    var parentCell: DublicatesTableViewCell?
    
    @IBOutlet weak var imageView: UIImageView!
    var photoAsset: PHAsset?
    @IBOutlet weak var selectedImageview: UIImageView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reload() {
        if let asset = photoAsset {
            if showedId != asset.localIdentifier {
                currentId = ImageManager.takeImageFromAsset(asset: asset, completion: { photo, id in
                    DispatchQueue.main.async {
                        if id == self.currentId {
                            self.imageView.image = photo
                            self.showedId = asset.localIdentifier
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
