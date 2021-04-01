//
//  MainCell5.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit

class MainCell5: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text =  "• Charging History - Charging history will display 30 days charging state of your phone. It may help you to learn about battery charge and battery discharge rate.\n\n• Charger Time State - Charger Time State will help to understand how many percentage of battery charge on particular time. It may help you understand battery charging speed."
    }

}
