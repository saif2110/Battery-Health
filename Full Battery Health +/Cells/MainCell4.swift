//
//  MainCell4.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit

class MainCell4: UITableViewCell {
    
    @IBOutlet weak var turningSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func TurningSwitch(_ sender: UISwitch) {
        
        if sender.tag == 1 {
            
            if sender.isOn {
                UserDefaults.standard.setValue("on", forKey: "vibration")
            }else{
                UserDefaults.standard.setValue("off", forKey: "vibration")
            }
            
        }else if sender.tag == 2 {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {didAllow, error in
                if didAllow {
                    DispatchQueue.main.async {
                        if sender.isOn {
                            UserDefaults.standard.setValue("on", forKey: "notification")
                        }else{
                            UserDefaults.standard.setValue("off", forKey: "notification")
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }else{
                    UserDefaults.standard.setValue("off", forKey: "notification")
                    DispatchQueue.main.async {
                        sender.isOn.toggle()
                    }
                }
            })
            
        }else if sender.tag == 3 {
            if UserDefaults.standard.bool(forKey: "pro") {
                
                if sender.isOn {
                    UserDefaults.standard.setValue("on", forKey: "dim")
                }else{
                    UserDefaults.standard.setValue("off", forKey: "dim")
                }
                
            }else{
                sender.setOn(false, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("Showinapp"), object: nil)
            }
        }
        else if sender.tag == 4 {
            if UserDefaults.standard.bool(forKey: "pro") {
                
                if sender.isOn {
                    UserDefaults.standard.setValue("on", forKey: "hideUI")
                }else{
                    UserDefaults.standard.setValue("off", forKey: "hideUI")
                }
                
            }else{
                sender.setOn(false, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("Showinapp"), object: nil)
            }
            
        }else if sender.tag == 5 {
            
            if UserDefaults.standard.bool(forKey: "pro") {
                
                if sender.isOn {
                    UserDefaults.standard.setValue("on", forKey: "background")
                    
                }else{
                    UserDefaults.standard.setValue("off", forKey: "background")
                }
                
            }else{
                sender.setOn(false, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("Showinapp"), object: nil,userInfo: ["background": true])
            }
            
        }
    }
    
}
