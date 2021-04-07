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


@main
class AppDelegate: UIResponder, UIApplicationDelegate,URLSessionDelegate {
    
    var window: UIWindow?
    
    let usersStore = UserDefaultsStore<BatteryInfo>(uniqueIdentifier: "Batteryinfo")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if UserDefaults.standard.integer(forKey: "AppLaunch") != 0 {
            
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "AppLaunch") + 1, forKey: "AppLaunch")
        }else{
            UserDefaults.standard.setValue(1, forKey: "AppLaunch")
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        if usersStore.objectsCount > 100{
            usersStore.deleteAll()
        }
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["2c1e08f6eb84bb132117da914a0e0b7b"]
        
        let iap = InAppPurchase.default
        iap.addTransactionObserver(fallbackHandler: {_ in
            // Handle the result of payment added by Store
            // See also `InAppPurchase#purchase`
            
            print("what the hell is this")
        })
        
        
        return true
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
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}
