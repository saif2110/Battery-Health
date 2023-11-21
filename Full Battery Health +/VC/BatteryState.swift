//
//  BatteryState.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 11/03/21.
//

import UIKit
import Charts
import UserDefaultsStore

class BatteryState: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var BatteryHistory = true
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersStore.objectsCount == 0 {
            self.myView.setEmptyMessage("Data will be displayed once you charged phone for more than 10 minutes using this app.")
        }else{
            self.myView.restore()
        }
        return usersStore.objectsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BatteryStateCell", for: indexPath) as! BatteryStateCell
        
        let obj = usersStore.object(withId: indexPath.row+1)
        
        let StartTime = getDatefromMili(milisecond: (obj?.TimeStarted ?? 80))
        let Ended = getDatefromMili(milisecond: (obj?.TimeEnded ?? 80))
        
        let BattryStart = obj?.currentBatteryPercentage ?? 0
        let BattryEnded = obj?.lastBatteryPercentage ?? 00
        
        if BatteryHistory {
            cell.imageView?.image = #imageLiteral(resourceName: "charging")
            cell.textLabel?.text = "Charged \(BattryStart)% To \(BattryEnded)%"
            cell.detailTextLabel?.text = "Start- \(StartTime) | End- \(Ended)"
            return cell
        }else{
            
            var mins = (obj?.TimeEnded ?? 100) - (obj?.TimeStarted ?? 100)
            mins = mins/60000
            cell.imageView?.image = #imageLiteral(resourceName: "charging")
            cell.textLabel?.text = "Charged - \(BattryEnded - BattryStart)%"
            cell.detailTextLabel?.text = "Time taken to charge - \(Int(mins)) Mins"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if BatteryHistory {
            return headerView(label: "Battery History")
        }else{
            return headerView(label: "Battery Time State")
        }
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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var myView: UITableView!
    
    @IBOutlet weak var Chart: BarChartView!
    
    let usersStore = UserDefaultsStore<BatteryInfo>(uniqueIdentifier: "Batteryinfo")
    var months: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAds(Myself: self)
        
        if BatteryHistory {
            label.text = "Charging history will display 30 days charging state of your phone. It may help you to learn about battery charge and battery discharge rate"
        }else{
            label.text = "Battery Time State will display 30 days time state of your phone. It may help you to learn about how many percentage battery charge in a particular time"
        }
        
        Chart.noDataText = "You need to provide data for the chart."
        updateChartWithData()
        
        myView.delegate = self
        myView.dataSource = self
        myView.tableFooterView = UIView()
        myView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func updateChartWithData() {
        var dataEntries = [BarChartDataEntry]()
        for i in 0...usersStore.objectsCount {
            let obj = usersStore.object(withId: i+1)
            let totalCharge = (obj?.lastBatteryPercentage ?? 80) - (obj?.currentBatteryPercentage ?? 20)
            let timeTaken = (obj?.TimeEnded ?? 40) - (obj?.TimeStarted ?? 200)
            dataEntries.append(BarChartDataEntry(x: Double(totalCharge), y: timeTaken/60000))
        }
        
        
        let BarChartSet = BarChartDataSet(entries: dataEntries, label: "Minutes")
        let BarData = BarChartData(dataSet: BarChartSet)
        //BarData.addDataSet(BarChartSet)
        Chart.data = BarData
    }
}
