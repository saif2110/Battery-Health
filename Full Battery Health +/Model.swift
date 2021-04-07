//
//  Model.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import MediaPlayer
import Foundation
import UIKit
import UserDefaultsStore
import AppTrackingTransparency

let neonClr = #colorLiteral(red: 0.4682161212, green: 0.7442020774, blue: 0.2786980867, alpha: 1)
let diableClr = #colorLiteral(red: 0.1784194794, green: 0.1792542546, blue: 0.1919928113, alpha: 1)

func getBattryState() -> String {
    
    if (UIDevice.current.batteryState == .charging) {
        return "Charging"
        
    }else if (UIDevice.current.batteryState == .unplugged) {
        return "Not Charging"
        
    }else if (UIDevice.current.batteryState == .full) {
        return "Battery Full"
        
    }else{
        return "Unknown"
    }
}


var indicator = UIActivityIndicatorView()

func startIndicator(selfo:UIViewController) {
    indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    indicator.color = neonClr
    indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    indicator.center = selfo.view.center
    selfo.view.addSubview(indicator)
    selfo.view.bringSubviewToFront(indicator)
    indicator.startAnimating()
}

func stopIndicator() {
    indicator.stopAnimating()
}




func getBatteyPercentage() -> String {
    return String(Int(Double(UIDevice.current.batteryLevel) * 100))
}

func Notification() {
    let content = UNMutableNotificationContent()
    
    //adding title, subtitle, body and badge
    content.title = "Battery Charged"
    //content.subtitle = "Battery is fully as per you desired"
    content.body = "Disconnect cable & close the app"
    content.sound = .default
    
    //getting the notification trigger
    //it will be called after 5 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    //getting the notification request
    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
    
    //adding the notification to notification center
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    
}

extension UIView {
    func shadow()  {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
    
    func shadow2()  {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
}


struct BatteryInfo: Codable, Identifiable {
    var id: Int
    
    var currentBatteryPercentage:Int
    var lastBatteryPercentage:Int
    var TimeStarted:Double
    var TimeEnded:Double
    
}

func getDatefromMili(milisecond:Double) -> String {
    
    let dateVar = Date.init(timeIntervalSinceNow: TimeInterval(milisecond)/1000)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM h:mm a"
    return dateFormatter.string(from: dateVar)
}


//unarchiveObject(with: unarchivedObject as Data) as? [BatteryInfo]

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}


extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 4
        rotation.isCumulative = true
        rotation.repeatCount = 100000000
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func flash(numberOfFlashes: Float) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = numberOfFlashes
        layer.add(flash, forKey: nil)
    }
    
    
    func flashSlow(numberOfFlashes: Float) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 1
        flash.fromValue = 1
        flash.toValue = 0.5
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = numberOfFlashes
        layer.add(flash, forKey: nil)
    }
}

func myAlt(titel:String,message:String)-> UIAlertController{
    let alert = UIAlertController(title: titel, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        switch action.style{
        case .default:
            print("")
        case .cancel:
            print("")
        case .destructive:
            print("")
        @unknown default:
            fatalError()
        }}))
                 
    return alert
    
}

//copy paste this

//self.present(myAlt(titel:"Failure",message:"Something went wrong."), animated: true, completion: nil)

