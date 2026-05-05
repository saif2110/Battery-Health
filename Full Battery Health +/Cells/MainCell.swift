//
//  MainCell.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit
import SwiftySound
import AudioToolbox

class MainCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
        backgroundConfiguration = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
        accessoryType = .none
    }
}
