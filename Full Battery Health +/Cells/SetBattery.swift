//
//  SetBattery.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit

class SetBattery: UITableViewCell {
    @IBOutlet weak var percentageSegment: UISegmentedControl!
    @IBOutlet weak var Note: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.integer(forKey: "percentage") != 0 {
            if UserDefaults.standard.integer(forKey: "percentage") == 80{
                percentageSegment.selectedSegmentIndex = 0
            }else if UserDefaults.standard.integer(forKey: "percentage") == 90 {
                percentageSegment.selectedSegmentIndex = 1
            }else{
                percentageSegment.selectedSegmentIndex = 2
                
            }
        }
    }
    
    
    @IBAction func percentageSegActio(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            UserDefaults.standard.setValue(80, forKey: "percentage")
            UserDefaults(suiteName:
            "group.com.Full-Battery.Health.percentage")!.set(80, forKey: "percentage")

            
        }else if sender.selectedSegmentIndex == 1 {
            UserDefaults.standard.setValue(90, forKey: "percentage")
            UserDefaults(suiteName:
            "group.com.Full-Battery.Health.percentage")!.set(90, forKey: "percentage")
        }else{
            UserDefaults.standard.setValue(100, forKey: "percentage")
            UserDefaults(suiteName:
            "group.com.Full-Battery.Health.percentage")!.set(100, forKey: "percentage")
        }
        
    }
    
}
