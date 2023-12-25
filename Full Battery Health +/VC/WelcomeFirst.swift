//
//  WelcomeFirst.swift
//  Full Battery Health
//
//  Created by Saif on 25/12/23.
//

import UIKit
import AppTrackingTransparency

class WelcomeFirst: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      if #available(iOS 15.0, *) {
          ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
              
          })
      }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
