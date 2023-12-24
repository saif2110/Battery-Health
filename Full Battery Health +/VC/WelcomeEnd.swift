//
//  WelcomeEnd.swift
//  Full Battery Health
//
//  Created by Saif on 24/12/23.
//

import UIKit

class WelcomeEnd: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  @IBAction func next(_ sender: Any) {
    DispatchQueue.main.async {
      //  let selfVC = UIApplication.topViewController()
      let vc = InAppVC()
      vc.modalPresentationStyle = .fullScreen
      self.navigationController?.pushViewController(vc, animated: true)
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



extension UIApplication {
  class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navController = base as? UINavigationController {
      return topViewController(base: navController.visibleViewController)
    }
    if let tabController = base as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topViewController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}



import UIKit

class AnimatedVisibilityButton: UIButton {
  // Initializer to set the initial state (hidden)
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.alpha = 0.0 // Initially fully transparent
    performVisibilityAnimationAfterDelay()
  }
  
  // Required initializer when creating the button in Interface Builder (Storyboard)
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.alpha = 0.0 // Initially fully transparent
    performVisibilityAnimationAfterDelay()
  }
  
  // Function to toggle visibility with animation after a delay
  private func performVisibilityAnimationAfterDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change the delay as needed
      UIView.animate(withDuration: 0.7) {
        self.alpha = 1.0 // Show the button gradually with animation
      }
    }
  }
}

