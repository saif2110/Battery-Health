//
//  AppDelegate.swift
//  Full Battery Health +
//
//  Created by Junaid Mukadam on 02/03/21.
//

import UIKit
import UserDefaultsStore
import GoogleMobileAds
import AVFoundation
import InAppPurchase
import SwiftySound
import BackgroundTasks
import CoreLocation
import MediaPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate,URLSessionDelegate {
    
    var window: UIWindow?
    
    let usersStore = UserDefaultsStore<BatteryInfo>(uniqueIdentifier: "Batteryinfo")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = neonClr
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if UserDefaults.standard.integer(forKey: "AppLaunch") != 0 {
            
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "AppLaunch") + 1, forKey: "AppLaunch")
        }else{
            UserDefaults.standard.setValue(1, forKey: "AppLaunch")
            UserDefaults.standard.setValue(80, forKey: "percentage")
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        if usersStore.objectsCount > 100{
            usersStore.deleteAll()
        }
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["86ceecc627a1fd92ef110d638ddae2da"]
        
        let iap = InAppPurchase.default
        iap.addTransactionObserver(fallbackHandler: {_ in
            // Handle the result of payment added by Store
            // See also `InAppPurchase#purchase`
            
            //print("what the hell is this")
        })
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        alarminLockforPRO()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        info.TimeEnded = Date().timeIntervalSince1970 * 1000
        info.lastBatteryPercentage = Int(getBatteyPercentage()) ?? 10
        
        if info.TimeStarted != 0 {
            
            var mins = info.TimeEnded - info.TimeStarted
            mins = mins/60000
            if mins > 5 {
                
                info.id = usersStore.objectsCount + 1
                print(usersStore.objectsCount+1)
                try! usersStore.save(info)
            }else{
                
                NotificationofClosed()
                
            }
        }
        
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print(token)
        
        sendToken(token: token) { (JSON, Err) in
            UserDefaults.standard.setValue(JSON["featureTitel"].string ?? "Alarm in lock  (Pro)", forKey: "featureTitel")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        info.TimeEnded = Date().timeIntervalSince1970 * 1000
        info.lastBatteryPercentage = Int(getBatteyPercentage()) ?? 10
        if UserDefaults.standard.string(forKey: "background") == "off" && info.TimeStarted != 0 {
                var mins = (Date().timeIntervalSince1970 * 1000) - info.TimeStarted
                mins = mins/60000
                if mins < 5 {
                    NotificationofBackground()
                }
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func Playsound() {
        
        if UIDevice.current.batteryState == .charging {
            if UserDefaults.standard.string(forKey: "ring") != nil {
                mySound?.stop()
                mySound = Sound(url: Bundle.main.url(forResource: UserDefaults.standard.string(forKey: "ring"), withExtension: "mp3")!)
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker])
                    print("Playback OK")
                    try AVAudioSession.sharedInstance().setActive(true)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    print("Session is Active")
                } catch {
                    print(error)
                }
                
                mySound?.play(numberOfLoops: 100000, completion: nil)
                
            }else{
                mySound?.stop()
                mySound = Sound(url: Bundle.main.url(forResource: "bell", withExtension: "mp3")!)
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker])
                    print("Playback OK")
                    try AVAudioSession.sharedInstance().setActive(true)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    print("Session is Active")
                } catch {
                    print(error)
                }
                
                mySound?.play(numberOfLoops: 100000, completion: nil)
                
            }
            
            
            if UserDefaults.standard.string(forKey: "notification") != nil {
                if UserDefaults.standard.string(forKey: "notification") == "on"{
                    Notification()
                }
            }
            
        }
    }
}
