//
//  DublicatesTableViewCell.swift
//  Cleaner
//
//  Created by Alexey on 19.07.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import UIKit
import Photos

protocol DublicatesTableViewCellDelegate {
    func deleteAssetes(toDelete: [PHAsset])
}

class DublicatesTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var dubsCollectionView: UICollectionView!
    
    var duplicates: [PHAsset]?
    var currentId = 0
    var previewAsset: PHAsset?
    var previewId = 0
    var delegate: DublicatesTableViewCellDelegate?
    
    @IBAction func saveThisAction() {
        if let duplicates = self.duplicates {
            var toDelete: [PHAsset] = []
            for i in duplicates {
                if i != previewAsset {
                    toDelete.append(i)
                }
            }
            
            if toDelete.count == duplicates.count {
                toDelete.remove(at: 0)
            }
            
            self.delegate?.deleteAssetes(toDelete: toDelete)
        }
    }
    
    var alertWindow: UIWindow?
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dubsCollectionView.delegate = self
        dubsCollectionView.dataSource = self
        
    }
    
    func reload(duplicates: [PHAsset]) {
        if duplicates == self.duplicates { return }
        self.duplicates = duplicates
        self.dubsCollectionView.reloadData()
        self.setPreview()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        ImageManager.cancelImageRequest(id: currentId)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DublicateCollectionViewCell
        
        self.dubsCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.05, animations: {cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)}) { _ in
            UIView.animate(withDuration: 0.20) {
                cell.transform = .identity
            }
        }
        
        self.layoutSubviews()
        if let asset = cell.photoAsset {
            if asset == self.previewAsset { return }
            self.previewAsset = asset
            self.setPreview()
        }
    }
    
    
    override func prepareForReuse() {
        self.previewAsset = nil
    }
    
    func setPreview() {
        self.previewAsset = self.previewAsset ?? self.duplicates?.first
        self.currentId = ImageManager.takeImageFromAsset(asset: self.previewAsset!, completion: { photo, id in
            DispatchQueue.main.async {
                if self.currentId == id {
                    self.previewImageView.image = photo
                    self.layoutIfNeeded()
                    self.layoutSubviews()
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return duplicates?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DublicateCollectionViewCell
        ImageManager.cancelImageRequest(id: cell.currentId)
        cell.photoAsset = self.duplicates![indexPath.row]
        cell.reload()
        if cell.photoAsset?.localIdentifier == self.previewAsset?.localIdentifier {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
            cell.imageView.borderColor = UIColor().mainColorFirst()
            cell.imageView.borderWidth = 3.0
        } else {
            cell.imageView.borderColor = UIColor().bgFloat()
            cell.imageView.borderWidth = 2.0
        }
        return cell
    }

}
