//
//  ViewController.swift
//  Full Battery Health +
//
//  Created by Junaid Mukadam on 02/03/21.
//


import UIKit
import UserDefaultsStore
import AudioToolbox
import MBCircularProgressBar
import SwiftySound
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var ChargingLabel: UILabel!
    var batteryLevel:Double = 0
    
    @IBOutlet weak var UIbutton: UIButton!
    @IBOutlet weak var lightbulb: UIButton!
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var MBView: MBCircularProgressBarView!
    
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        hide
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOpenfromWidget {
            showAds(Myself: self)
        }
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(tapMethod))
        self.MBView.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        self.MBView.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap)
        
        tabBar.layer.cornerRadius = 30
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.shadow()
        
        if UserDefaults.standard.string(forKey: "dim") != nil {
            if UserDefaults.standard.string(forKey: "dim") == "on"{
                UIScreen.main.brightness = CGFloat(-1)
            }
        }
        
        if UserDefaults.standard.string(forKey: "hideUI") != nil {
            if UserDefaults.standard.string(forKey: "hideUI") == "on"{
                DispatchQueue.main.async{
                    self.HideUI()
                }
            }
        }
        
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        MBView.value = CGFloat(Double(UIDevice.current.batteryLevel) * 100)
        
        if UserDefaults.standard.integer(forKey: "percentage") != 0 {
            if CGFloat(Double(UIDevice.current.batteryLevel) * 100) >= CGFloat(UserDefaults.standard.integer(forKey: "percentage")) {
                Playsound()
            }
        }else{
            if CGFloat(Double(UIDevice.current.batteryLevel) * 100) >= CGFloat(80) {
                Playsound()
            }
            
        }
    }
    
    @objc func batteryStateChanged(_ notification: Notification) {
        if (UIDevice.current.batteryState == .charging) {
            ChargingLabel.isHidden = false
        }else{
            ChargingLabel.isHidden = true
        }
    }
    
    @objc func tapMethod(){
        if tabBar.isHidden {
            HideUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = Double(UIDevice.current.batteryLevel)
        
        UIView.animate(withDuration: 1) {
            self.MBView.value = CGFloat(self.batteryLevel * 100)
        }
        
        
        if (UIDevice.current.batteryState == .charging) {
            ChargingLabel.isHidden = false
        }else{
            ChargingLabel.isHidden = true
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil)
        
    }
    
    
    @IBAction func lightbulbSetting(_ sender: Any) {
        if lightbulb.currentBackgroundImage == UIImage(systemName: "lightbulb.fill") {
            lightbulb.setBackgroundImage(UIImage(systemName: "lightbulb"), for: .normal)
            UIScreen.main.brightness = CGFloat(-1)
        }else{
            lightbulb.setBackgroundImage(UIImage(systemName: "lightbulb.fill"), for: .normal)
            UIScreen.main.brightness = CGFloat(0.45)
        }
        
    }
    
    var hide = true
    
    func HideUI() {
        if hide {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.ChargingLabel.isHidden = true
            self.MBView.progressColor = .none
            self.MBView.progressStrokeColor = .none
            self.MBView.emptyLineStrokeColor = .none
            self.MBView.value = CGFloat(UIDevice.current.batteryLevel * 100) - 1
            self.MBView.value =  CGFloat(UIDevice.current.batteryLevel * 100)
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut],
                           animations: {
                            self.tabBar.center.y += self.tabBar.frame.height
                           },completion: nil)
            self.tabBar.isHidden = true
            self.hide = false
            self.view.layoutIfNeeded()
            
        }else{
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            ChargingShouldHide()
            self.MBView.progressColor = .white
            self.MBView.progressStrokeColor = .systemOrange
            self.MBView.emptyLineStrokeColor = .darkGray
            self.MBView.value = CGFloat(UIDevice.current.batteryLevel * 100) - 1
            self.MBView.value =  CGFloat(UIDevice.current.batteryLevel * 100)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                           animations: {
                            self.tabBar.center.y -= self.tabBar.frame.height
                           },completion: nil)
            self.tabBar.isHidden = false
            self.hide = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    func ChargingShouldHide(){
        
        if getBattryState() == "Charging" {
            self.ChargingLabel.isHidden = false
        }else{
            self.ChargingLabel.isHidden = true
        }
    }
    
    @IBAction func UIsetting(_ sender: Any) {
        self.HideUI()
    }
    
    let usersStore = UserDefaultsStore<BatteryInfo>(uniqueIdentifier: "Batteryinfo")
    
    @IBAction func exitApp(_ sender: Any) {
        UIScreen.main.brightness = CGFloat(0.5)
        info.TimeEnded = Date().timeIntervalSince1970 * 1000
        info.lastBatteryPercentage = Int(getBatteyPercentage()) ?? 10
        
        if info.TimeStarted != 0 {
            var mins = info.TimeEnded - info.TimeStarted
            mins = mins/60000
            if mins > 5 {
                
                info.id = usersStore.objectsCount + 1
                try! usersStore.save(info)
                
            }else{
                
                NotificationofClosed()
            }
        }
        
        exit(0)
    }
    
    var mySound:Sound?
    func Playsound() {
        
        if UIDevice.current.batteryState == .charging {
            if UserDefaults.standard.string(forKey: "ring") != nil {
                Sound.stopAll()
                mySound = Sound(url: Bundle.main.url(forResource: UserDefaults.standard.string(forKey: "ring"), withExtension: "mp3")!)
                backgroundAudioPermission()
                mySound?.play(numberOfLoops: 100000, completion: nil)
                
            }else{
                Sound.stopAll()
                mySound = Sound(url: Bundle.main.url(forResource: "bell", withExtension: "mp3")!)
                backgroundAudioPermission()
                mySound?.play(numberOfLoops: 100000, completion: nil)
                
            }
            
            if UserDefaults.standard.string(forKey: "notification") != nil {
                if UserDefaults.standard.string(forKey: "notification") == "on"{
                    Notification()
                }
            }
            
            
            if UserDefaults.standard.string(forKey: "vibration") != nil {
                if UserDefaults.standard.string(forKey: "vibration") == "on"{
                    for _ in 1...5 {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        sleep(2)
                    }
                }
            }
        }
    }
}

