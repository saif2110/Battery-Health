//
//  Ads.swift
//  Footsteps tracker
//
//  Created by Junaid Mukadam on 29/09/19.
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency

let testIntrest = "ca-app-pub-2710347124980493/6483209140" //Mine

private var interstitial: GADInterstitialAd?

func showAds(Myself:UIViewController) {
    
    if #available(iOS 14, *) {
        if !UserDefaults.standard.bool(forKey: "pro") {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID:testIntrest,
                                       request: request,
                                       completionHandler: { [Myself] ad, error in
                                        if let error = error {
                                            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                            return
                                        }
                                        interstitial = ad
                                        
                                        if interstitial != nil {
                                            interstitial?.present(fromRootViewController: Myself)
                                        } else {
                                            print("Ad wasn't ready")
                                        }
                                        
                                       })
            })
            
        } else {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:testIntrest,
                                   request: request,
                                   completionHandler: { [Myself] ad, error in
                                    if let error = error {
                                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                        return
                                    }
                                    interstitial = ad
                                    
                                    if interstitial != nil {
                                        interstitial?.present(fromRootViewController: Myself)
                                    } else {
                                        print("Ad wasn't ready")
                                    }
                                    
                                   })
        }
    }
}
