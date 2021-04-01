//
//  Ads.swift
//  Footsteps tracker
//
//  Created by Junaid Mukadam on 29/09/19.
//

import Foundation
import GoogleMobileAds

let testIntrest = "ca-app-pub-2710347124980493/6483209140" //Mine

private var interstitial: GADInterstitialAd?

func LoadIntrest(Myself:UIViewController) {
    let request = GADRequest()
    GADInterstitialAd.load(withAdUnitID:testIntrest,
                           request: request,
                           completionHandler: { [Myself] ad, error in
                            if let error = error {
                                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                return
                            }
                            interstitial = ad
                           })
}



func showAds(Myself:UIViewController) {
    if interstitial != nil {
        interstitial?.present(fromRootViewController: Myself)
    } else {
        print("Ad wasn't ready")
    }
}
