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
import SwiftyJSON
import Alamofire
import SwiftySound
import AppTrackingTransparency

let neonClr = #colorLiteral(red: 0.4682161212, green: 0.7442020774, blue: 0.2786980867, alpha: 1)
let diableClr = #colorLiteral(red: 0.1784194794, green: 0.1792542546, blue: 0.1919928113, alpha: 1)

func getBattryState() -> String {
     UIDevice.current.isBatteryMonitoringEnabled = true
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

var mySound:Sound?
func alarminLockforPRO(){
    if UserDefaults.standard.string(forKey: "background") == "on" && info.TimeStarted != 0{
        Sound.stopAll()
        mySound = Sound(url: Bundle.main.url(forResource: "AlarmB", withExtension: "mp3")!)
        
        backgroundAudioPermission()
        
        mySound?.play(numberOfLoops: 100000, completion: nil)
    }
}


func backgroundAudioPermission(){
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker])
        print("Playback OK")
        try AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        print("Session is Active")
    } catch {
        print(error)
    }
}

func getBatteyPercentage() -> String {
    return String(Int(Double(UIDevice.current.batteryLevel) * 100))
}

func Notification() {
    let content = UNMutableNotificationContent()
    
    //adding title, subtitle, body and badge
    content.title = "Battery Charged"
    //content.subtitle = "Battery is full as per your limit."
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

func NotificationofClosed() {
    let content = UNMutableNotificationContent()
    
    //adding title, subtitle, body and badge
    content.title = "Oops.. App is killed!"
    //content.subtitle = "ALARM IS TURNED OFF. Please open the app & set alarm again."
    content.body = "ALARM IS TURNED OFF. Please open the app & set alarm again."
    content.sound = .default
    
    //getting the notification trigger
    //it will be called after 5 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    //getting the notification request
    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification2", content: content, trigger: trigger)
    
    //adding the notification to notification center
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    
}


func NotificationofBackground() {
    let content = UNMutableNotificationContent()
    //adding title, subtitle, body and badge
    content.title = "Oops.. App is in background!"
    //content.subtitle = "ALARM IS TURNED OFF. Please open the app & set alarm again."
    content.body = "ALARM WILL NOT WORK. Please stay in the foreground of the app."
    content.sound = .default
    
    //it will be called after 5 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    //getting the notification request
    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification3", content: content, trigger: trigger)
    
    //adding the notification to notification center
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

extension UIView {
    func shadow()  {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
    
    func shadow2()  {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.3
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
    
    let dateVar = Date.init(timeIntervalSince1970: TimeInterval(milisecond)/1000)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM h:mm a"
    return dateFormatter.string(from: dateVar)
}

// MARK: - Modern Empty State

private func makeModernEmptyState(message: String, in bounds: CGRect) -> UIView {
    let container = UIView(frame: bounds)
    container.backgroundColor = .clear

    let accent = UIColor(red: 0.533, green: 0.698, blue: 0.278, alpha: 1)

    // Split the message: first line is title, remainder is subtitle.
    var title = message
    var subtitle = ""
    if let range = message.range(of: "\n") {
        title = String(message[..<range.lowerBound])
        subtitle = String(message[range.upperBound...])
    }
    title = title.trimmingCharacters(in: .whitespaces)
    subtitle = subtitle.trimmingCharacters(in: .whitespaces)

    // Strip any leading emoji from the title — we render an icon ourselves.
    let trimmedTitle: String = {
        let scalars = title.unicodeScalars
        guard let first = scalars.first, first.properties.isEmojiPresentation || first.properties.generalCategory == .otherSymbol else {
            return title
        }
        return String(title.dropFirst()).trimmingCharacters(in: .whitespaces)
    }()

    // Tinted circle with big SF Symbol.
    let iconBg = UIView()
    iconBg.backgroundColor = accent.withAlphaComponent(0.15)
    iconBg.layer.cornerRadius = 44
    iconBg.translatesAutoresizingMaskIntoConstraints = false

    let iconConfig = UIImage.SymbolConfiguration(pointSize: 38, weight: .semibold)
    let iconView = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: iconConfig))
    iconView.tintColor = accent
    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconBg.addSubview(iconView)

    let titleLabel = UILabel()
    titleLabel.text = trimmedTitle.isEmpty ? "All clean!" : trimmedTitle
    titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let subtitleLabel = UILabel()
    subtitleLabel.text = subtitle.isEmpty ? "Nothing to clean up here." : subtitle
    subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(iconBg)
    container.addSubview(titleLabel)
    container.addSubview(subtitleLabel)

    NSLayoutConstraint.activate([
        iconBg.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        iconBg.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 40),
        iconBg.widthAnchor.constraint(equalToConstant: 88),
        iconBg.heightAnchor.constraint(equalToConstant: 88),

        iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
        iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: 42),
        iconView.heightAnchor.constraint(equalToConstant: 42),

        titleLabel.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 18),
        titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
        titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),

        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
        subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 36),
        subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -36),
    ])

    // Subtle pop-in animation.
    iconBg.alpha = 0
    iconBg.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    titleLabel.alpha = 0
    subtitleLabel.alpha = 0
    UIView.animate(withDuration: 0.45, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.curveEaseOut], animations: {
        iconBg.alpha = 1
        iconBg.transform = .identity
    })
    UIView.animate(withDuration: 0.35, delay: 0.18, options: [.curveEaseOut], animations: {
        titleLabel.alpha = 1
        subtitleLabel.alpha = 1
    })

    return container
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        self.backgroundView = makeModernEmptyState(message: message, in: bounds)
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        self.backgroundView = makeModernEmptyState(message: message, in: bounds)
    }

    func restore() {
        self.backgroundView = nil
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


func sendToken(token:String,completionhandler:@escaping (JSON, Error?) -> ()){
    postWithParameter(Url: "setToken.php", parameters: ["id":UIDevice.current.identifierForVendor!.uuidString,"notiToken":token]) { (JSON, Err) in
        
    
        
        
        completionhandler(JSON, Err)
    }
    
}


func deleteToken(){
    postWithParameter(Url: "deleteToken.php", parameters: ["id":UIDevice.current.identifierForVendor!.uuidString]) { (JSON, Err) in
        
    }
    
}

//copy paste this

//self.present(myAlt(titel:"Failure",message:"Something went wrong."), animated: true, completion: nil)

extension UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {

            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable
    var shadowOffset : CGSize{

        get{
            return layer.shadowOffset
        }set{

            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor : UIColor{
        get{
            return UIColor.init(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable
    var shadowOpacity : Float {

        get{
            return layer.shadowOpacity
        }
        set {

            layer.shadowOpacity = newValue

        }
    }
}
