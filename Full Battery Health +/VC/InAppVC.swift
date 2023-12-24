//
//  InAppVC.swift
//  Stock Market India
//
//  Created by Junaid Mukadam on 05/04/21.
//

import UIKit
import Lottie
import Purchases
import SafariServices
import InAppPurchase
import StoreKit

enum IPA:String {
    case OneYearPro = "BatteryHealthPro"
}

class InAppVC: UIViewController {
    var sysmbol = ""
    var myprice = 0.0
    
    var selectedIPA = 0
    var AllPackage = [Purchases.Package]()
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!{
        didSet{
            buyButton.clipsToBounds = true
            buyButton.layer.cornerRadius = buyButton.bounds.height/2
        }
    }
  
    @IBOutlet weak var imageLotti: UIImageView!
    
    @IBOutlet weak var dismissOutlet: UIButton!
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //jumpButtonAnimation(sender: buyButton)
        dismissOutlet.fadeIn()
    }
    
    func jumpButtonAnimation(sender: UIButton) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.03)
        animation.duration = 0.24
        animation.repeatCount = 100000
        animation.autoreverses = true
        sender.layer.add(animation, forKey: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let LottiV = AnimationView()
//        LottiV.frame = self.imageLotti.bounds
//        LottiV.backgroundColor = .clear
//        LottiV.animation = Animation.named("pro")
//        LottiV.contentMode = .scaleAspectFit
//        LottiV.loopMode = .repeat(0)
//        DispatchQueue.main.async {
//            self.imageLotti.addSubview(LottiV)
//            LottiV.play()
//        }
        
        let iap = InAppPurchase.default
        iap.fetchProduct(productIdentifiers: ["BatteryHealthPro"], handler: { (result) in
            switch result {
            case .success(let products):
                //self.buyButton.setTitle("PAY " + (products[0].priceLocale.currencySymbol ?? "$") + String(products[0].price.description + " (Lifetime)"), for: .normal)
                //self.priceLabel.text = "Try 3 days for free\nThen \(products[0].priceLocale.currencySymbol ?? "$") \(String(products[0].price.description)) Lifetime"
                break
            case .failure(let error):
                print(error)
            }
        })
        
        
        Purchases.shared.offerings { (offerings, error) in
            
            if let offerings = offerings {
                
                guard let package = offerings[IPA.OneYearPro.rawValue]?.availablePackages.first else {
                    return
                }
                
                self.AllPackage.append(package)
                
                let pricetwo = offerings[IPA.OneYearPro.rawValue]?.lifetime?.localizedPriceString
                
                //self.priceLabel.text = "Try 3 days for free\nThen \(String(describing: pricetwo ?? "00"))/year."
                
                //self.priceLabel.text = "Subscribe for \(String(describing: pricetwo ?? "00"))/year."
              
              self.priceLabel.text = "Access unlocked app forever with 40% off at just \(String(describing: pricetwo ?? "00")) billed for lifetime with all the benefits."
                
                stopIndicator()
                
            }
        }
        
    }
    
    @IBAction func restore(_ sender: Any) {
        let iap = InAppPurchase.default
        iap.restore(handler: { (result) in
            print(result)
            switch result {
            case .success(let products):
                if !products.isEmpty{
                    print(products)
                    
                    self.PerchesedComplte()
                    
                }
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    @IBAction func buyPro(_ sender: Any) {
        
        if AllPackage.count > 0 {
            startIndicator(selfo: self)
            Purchases.shared.purchasePackage(AllPackage[selectedIPA]) { (transaction, purchaserInfo, error, userCancelled) in
                if purchaserInfo?.entitlements.all[IPA.OneYearPro.rawValue]?.isActive == true {
                    
                    
                    self.PerchesedComplte()
                    
                }else{
                    
                    stopIndicator()
                    
                }
                
               // print(error)
                
            }
            
        }
        
    }
    
    func PerchesedComplte(){
        UserDefaults.standard.setValue(true , forKeyPath: "pro")
        self.dismiss(animated: true)
        self.present(myAlt(titel:"Congratulations !",message:"You are a pro member now. Enjoy seamless experience without the Ads."), animated: true, completion: nil)
        stopIndicator()
       
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            requestToRate()
        }
    }
    
    @IBAction func toc(sender:UIButton){
        let url = URL(string: "https://apps15.com/termsofuse.html")
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func privacyPolicy(sender:UIButton){
        let url = URL(string: "https://apps15.com/privacy.html")
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
}

extension UIView {
    func fadeIn(duration: TimeInterval = 1.4, delay: TimeInterval = 1, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 0.7
        }, completion: completion)
    }
}
