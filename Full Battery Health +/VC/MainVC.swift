//
//  MainVC.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit
import MediaPlayer
import InAppPurchase
import AVKit
import AppTrackingTransparency
import SwiftySound
import StoreKit

var info = BatteryInfo(id: 1, currentBatteryPercentage: 0, lastBatteryPercentage: 0, TimeStarted: 0, TimeEnded: 0)

class MainVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else if section == 1 {
            return 1
        }
        else if section == 2 {
            return 6
        }
        else if section == 3 {
            return 3
        }
        else if section == 4 {
            return 3
        }
        return 1
    }
    
    //MARK: TableViewCell Setting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
            cell.selectionStyle = .none
            cell.backgroundColor = .secondarySystemBackground
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 8
            cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
            cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
            
            
            if indexPath.row == 0 {
                cell.imageView?.image = #imageLiteral(resourceName: "battery")
                cell.detailTextLabel?.text = detailTextArray[indexPath.section][indexPath.row] + "%"
            }else{
                cell.imageView?.image = #imageLiteral(resourceName: "charging")
                cell.detailTextLabel?.text = detailTextArray[indexPath.section][indexPath.row]
            }
            
            cell.textLabel?.text = textLabelArray[indexPath.section][indexPath.row]
            cell.accessoryType = .none
            
            return cell
            
        }else if indexPath.section == 1 {
            let  cell = Bundle.main.loadNibNamed("SetBattery", owner: self, options: nil)?.first as! SetBattery
            cell.selectionStyle = .none
            cell.backgroundColor = .secondarySystemBackground
            cell.Note.text = "• When you’re recharging a phone, charge it to at least 20% or more before using it\n\n• Remove charger if your battery reaches 100% (Full Charge)."
            
            return cell
            
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                cell.textLabel?.font = UIFont(name: "Arial", size: 14)
                cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
                
                cell.imageView?.image = #imageLiteral(resourceName: "ring")
                cell.textLabel?.text = "Select Alarm Ringtone"
                cell.detailTextLabel?.text = ""
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                
                return cell
                
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell2", for: indexPath) as! MainCell2
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
                
                cell.imageView?.image = #imageLiteral(resourceName: "volume")
                cell.textLabel?.text = "Alarm Volume"
                cell.detailTextLabel?.text = volumePercentage
                
                return cell
                
            }else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell3", for: indexPath) as! MainCell3
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                return cell
                
            }else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.imageView?.image = #imageLiteral(resourceName: "vibe")
                cell.textLabel?.text = "Alarm Vibration"
                cell.turningSwitch.tag = 1
                
                if UserDefaults.standard.string(forKey: "vibration") != nil {
                    if UserDefaults.standard.string(forKey: "vibration") == "on"{
                        cell.turningSwitch.isOn = true
                    }else{
                        cell.turningSwitch.isOn = false
                    }
                }
                
                return cell
            }else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.imageView?.image = #imageLiteral(resourceName: "noti")
                cell.textLabel?.text = "Alarm Notification"
                cell.turningSwitch.tag = 2
                
                if UserDefaults.standard.string(forKey: "notification") != nil {
                    if UserDefaults.standard.string(forKey: "notification") == "on"{
                        cell.turningSwitch.isOn = true
                    }else{
                        cell.turningSwitch.isOn = false
                    }
                }
                
                return cell
                
            }
            
        }else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell5", for: indexPath) as! MainCell5
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                return cell
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
                cell.backgroundColor = .secondarySystemBackground
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
                if indexPath.row == 1 {
                    cell.imageView?.image = #imageLiteral(resourceName: "timeState")
                }else if indexPath.row == 2 {
                    cell.imageView?.image = #imageLiteral(resourceName: "history")
                }
                
                cell.detailTextLabel?.text = ""
                cell.textLabel?.text = ChargingAnalysis[indexPath.row-1]
                cell.accessoryType = .disclosureIndicator
                
                return cell
                
            }
            
        }else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.imageView?.image = #imageLiteral(resourceName: "dim")
                cell.textLabel?.text = "Always Dim  (Pro)"
                cell.turningSwitch.tag = 3
                
                if UserDefaults.standard.string(forKey: "dim") != nil {
                    if UserDefaults.standard.string(forKey: "dim") == "on"{
                        cell.turningSwitch.isOn = true
                    }else{
                        cell.turningSwitch.isOn = false
                    }
                }
                
                return cell
                
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.imageView?.image = #imageLiteral(resourceName: "UI")
                cell.textLabel?.text = "Always Hide UI  (Pro)"
                cell.turningSwitch.tag = 4
                
                if UserDefaults.standard.string(forKey: "hideUI") != nil {
                    if UserDefaults.standard.string(forKey: "hideUI") == "on"{
                        cell.turningSwitch.isOn = true
                    }else{
                        cell.turningSwitch.isOn = false
                    }
                }
                
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell4", for: indexPath) as! MainCell4
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemBackground
                cell.selectionStyle = .none
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 8
                
                cell.textLabel?.font = UIFont(name: "Arial", size: 15.5)
                cell.imageView?.image = #imageLiteral(resourceName: "battery")
                cell.textLabel?.text = "Change Percentage Position"
                cell.turningSwitch.tag = 5
                
                if UserDefaults.standard.string(forKey: "position") != nil {
                    if UserDefaults.standard.string(forKey: "position") == "on"{
                        cell.turningSwitch.isOn = true
                    }else{
                        cell.turningSwitch.isOn = false
                    }
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    var ChargingAnalysis = ["Charging History","Charger Time State"]
    
    let HeaderString = ["","Set Battery Percentage","Alarm Settings","Charging Analysis","Other Settings"]
    
    var detailTextArray = [[String]]()
    var textLabelArray = [["Battery Percentage","Charging State"],[""],[]]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        HeaderString.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }else{
            return 50
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }else if indexPath.section == 1 {
            return 140
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
                return 125
            }else{
                return 50
            }
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView(label: HeaderString[section])
    }
    
    func headerView(label:String) -> UIView {
        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: myView.frame.width, height: 50))
        sectionHeader.backgroundColor = .black
        let sectionText = UILabel()
        sectionText.frame = CGRect.init(x: 10, y: 15, width: sectionHeader.frame.width-10, height: sectionHeader.frame.height-10)
        sectionText.text = label
        sectionText.font = .systemFont(ofSize: 14, weight: .bold) // my custom font
        sectionText.textColor = neonClr
        sectionHeader.addSubview(sectionText)
        return sectionHeader
    }
    
    @IBOutlet weak var myView: UITableView!
    
    @IBOutlet weak var ButtonView: UIView!
    
    @IBOutlet weak var setAlaram: UIButton!
    
    @IBOutlet weak var batterytestOutlet: UIBarButtonItem!
    
    @IBOutlet weak var pro: UIBarButtonItem!
    
    @IBAction func proAction(_ sender: Any) {
        let vc = InAppVC()
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func setAlarmAction(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
        info.currentBatteryPercentage = Int(getBatteyPercentage()) ?? 10
        info.TimeStarted = Date().timeIntervalSince1970 * 1000
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 1 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BatteryState") as? BatteryState
            vc?.BatteryHistory = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }else  if indexPath.section == 3 && indexPath.row == 2 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BatteryState") as? BatteryState
            vc?.BatteryHistory = false
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Showinapp),
                                               name: NSNotification.Name("Showinapp"),
                                               object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            showAds(Myself: self)
        }
        
        batterytestOutlet.tintColor = neonClr
        
        if UserDefaults.standard.integer(forKey: "AppLaunch") > 5 {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        }
        
        ButtonView.layer.cornerRadius = 20
        ButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        ButtonView.shadow2()
        
        let volumeView = MPVolumeView(frame: .null)
        view.addSubview(volumeView)
        
        var detailTextLabel1 = [String]()
        detailTextLabel1.append(getBatteyPercentage())
        detailTextLabel1.append(getBattryState())
        detailTextArray.append(detailTextLabel1)
        detailTextArray.append([" "])
        detailTextArray.append([" "])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(Changed), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Changed),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Changed), name: Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        let mySound = Sound(url: Bundle.main.url(forResource: "bell", withExtension: "mp3")!)
        mySound?.play()
        mySound?.stop()
        
        self.myView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        
        let iap = InAppPurchase.default
        iap.set(shouldAddStorePaymentHandler: { (product) -> Bool in
            return true
        }, handler: { (result) in
            switch result {
            case .success( _):
                self.PerchesedComplte()
            case .failure( _):
                print("error")
            }
        })
        
        self.myView.delegate = self
        self.myView.dataSource = self
        self.myView.reloadData()
        
    }
    
    @objc func Showinapp() {
        let vc = InAppVC()
        self.present(vc, animated: true, completion: nil)
    }
    
    func PerchesedComplte(){
        UserDefaults.standard.setValue(true , forKeyPath: "pro")
        self.present(myAlt(titel:"Congratulations !",message:"You are a pro member now. Enjoy seamless experience without the Ads."), animated: true, completion: nil)
    }
    
    
    var volumePercentage = "100%"
    @objc func Changed(_ notification: Notification) {
        detailTextArray[0][0] = getBatteyPercentage()
        detailTextArray[0][1] = getBattryState()
        
        if let userInfo = notification.userInfo {
            let volume = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Double
            volumePercentage = String(Int((volume ?? 1 )*100)) + "%"
        }
        
        if (UIDevice.current.batteryState == .charging) {
            setAlaram.backgroundColor = neonClr
            setAlaram.isEnabled = true
            setAlaram.setTitle("Set Alarm", for: .normal)
            
        }else if (UIDevice.current.batteryState == .unplugged) {
            setAlaram.backgroundColor = diableClr
            setAlaram.isEnabled = false
            setAlaram.setTitle("Connect Charger", for: .normal)
            
        }else if (UIDevice.current.batteryState == .full) {
            setAlaram.backgroundColor = diableClr
            setAlaram.isEnabled = false
            setAlaram.setTitle("Connect Charger", for: .normal)
            
        }else{
            setAlaram.backgroundColor = diableClr
            setAlaram.isEnabled = false
            setAlaram.setTitle("Connect Charger", for: .normal)
        }
        
        self.myView.delegate = self
        self.myView.dataSource = self
        self.myView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}
