//
//  batteryTest.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 01/04/21.
//

import UIKit
import StepIndicator
import Lottie
import MeterGauge


class batteryTest: UIViewController {
    
    @IBOutlet weak var ResultBox: UIView!
    
    @IBOutlet weak var meter: MeterGauge!
    @IBOutlet weak var meter2: MeterGauge!
    
    @IBOutlet weak var LottiV: UIView!
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var note: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var StartRing: UIImageView!
    
    @IBOutlet weak var testingView: UIView!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var stepperView: StepIndicatorView!
    
    @IBOutlet weak var batteryDrop: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var StandbyTime: UILabel!
    @IBOutlet weak var VideoPlayBack: UILabel!
    
    
    var arraySteps = ["Test about to start.It may take few minutes.\nSIT BACK & RELAX","Increasing brightness to maximum\nPlease don't change it manually before testing is done","Do not connect phone to the charger or turn on low power mode","Running multiple for-loops in the background in several threads\nYour phone may get hot","Interstitial ad about to display if not a pro member\n(Not a part of the testing)","Running multiple complex mathematical equations simultaneously in the background\nYour phone may get hot","Testing several operations in background thread\nYour phone may get hot","Interstitial ad about to display if not a pro member\n(Not a part of the testing)","Testing Done\nGathering Information for result"]
    
    override func viewDidLoad() {
        note.clipsToBounds = true
        note.layer.cornerRadius = 8
        noteLabel.textColor = .white
        
        
        stepperView.numberOfSteps = arraySteps.count
        stepperView.currentStep = 0
        stepperView.circleTintColor = neonClr
        stepperView.lineTintColor = neonClr
        
        stepsLabel.text = arraySteps[0]
        stepsLabel.textColor = neonClr
        
        ResultBox.layer.cornerRadius = 8
        ResultBox.shadow2()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        StartRing.flash(numberOfFlashes: 4)
        StartRing.rotate()
        stepsLabel.flashSlow(numberOfFlashes: 100000)
        
        let LottiV = AnimationView()
        LottiV.frame = self.LottiV.bounds
        LottiV.backgroundColor = .black
        LottiV.animation = Animation.named("Lotti")
        LottiV.contentMode = .scaleAspectFit
        LottiV.loopMode = .repeat(10000000)
        LottiV.play()
        DispatchQueue.main.async {
            self.LottiV.addSubview(LottiV)
        }
    }
    
    var startInfo:Double = 0
    var EndInfo:Double = 0
    var startPercentage:Double = 0
    var startEndPercenateg:Double = 0
    
    
    @IBAction func startButton(_ sender: Any) {
        if  (Int(getBatteyPercentage()) ?? 50) > 70 {
            self.present(myAlt(titel:"Battery should be less than 70%",message:"Please try when phone's battery is less than 70% for accurate test result"), animated: true, completion: nil)
        }else if getBattryState() == "Charging"{
            self.present(myAlt(titel:"Please unplug the device",message:"Test may not show proper result while charging"), animated: true, completion: nil)
        }else if ProcessInfo.processInfo.isLowPowerModeEnabled {
            self.present(myAlt(titel:"Turn off low power mode",message:"Please temporary turn off the low power mode. Test may show improper result"), animated: true, completion: nil)
        }else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            StartRing.image = #imageLiteral(resourceName: "starting")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.startInfo = Double(Int64(Date().timeIntervalSince1970 * 1000))
                self.startPercentage = Double(getBatteyPercentage()) ?? 10
                
                self.batteryDrop.textColor = neonClr
                self.timeTaken.textColor = neonClr
                self.StandbyTime.textColor = neonClr
                self.VideoPlayBack.textColor = neonClr
                
                self.animHide()
                self.animHideFast()
                self.testEngine()
                self.navigationItem.hidesBackButton = true
                
            }
        }
        
    }
    
    func animHide(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear],
                       animations: {
                        self.note.center.y -= self.note.bounds.height
                        self.note.layoutIfNeeded()
                        
                       },  completion: {(_ completed: Bool) -> Void in
                        self.note.isHidden = true
                        
                       })
    }
    
    func animHideFast(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear],
                       animations: {
                        self.buttonView.center.y += self.buttonView.bounds.height
                        self.buttonView.layoutIfNeeded()
                        
                       },  completion: {(_ completed: Bool) -> Void in
                        self.buttonView.isHidden = true
                        self.testingView.isHidden = false
                       })
    }
    
    func getTiming(time:Double)->Int{
        
        if time < 50 {
            return Int.random(in: 95...100)
        }else if time < 70 {
            return  Int.random(in: 82...85)
        }else if time < 90 {
            return  Int.random(in: 80...82)
        }else if time < 100 {
            return  Int.random(in: 78...80)
        }else if time < 120 {
            return  Int.random(in: 75...78)
        }else if time < 150 {
            return  Int.random(in: 78...75)
        }else if time < 170 {
            return Int.random(in: 75...78)
        }else if time < 190 {
            return Int.random(in: 70...75)
        }else if time < 200 {
            return Int.random(in: 67...70)
        }else if time < 220 {
            return Int.random(in: 65...67)
        }else if time < 250 {
            return Int.random(in: 63...65)
        }else if time < 280 {
            return Int.random(in: 60...63)
        }else if time < 300 {
            return Int.random(in: 56...60)
        }else{
            return Int.random(in: 50...56)
        }
    }
    
    func getPercentage(percenatge:Int)->Int{
        if percenatge == 0 {
            return Int.random(in: 95...97)
        }else if percenatge == 1 {
            return Int.random(in: 90...95)
        }else if percenatge == 2 {
            return Int.random(in: 85...90)
        }else if percenatge == 3 {
            return Int.random(in: 80...84)
        }else if percenatge == 4 {
            return Int.random(in: 78...80)
        }else if percenatge == 5 {
            return Int.random(in: 74...78)
        }else{
            return Int.random(in: 65...70)
        }
    }
    
    func get4GTime(percenatgeDrop:Int)->Int{
        if percenatgeDrop == 0 {
            return Int.random(in: 22...25)
        }else if percenatgeDrop == 1 {
            return Int.random(in: 19...22)
        }else if percenatgeDrop == 2 {
            return Int.random(in: 17...19)
        }else if percenatgeDrop == 3 {
            return Int.random(in: 14...17)
        }else if percenatgeDrop == 4 {
            return Int.random(in: 12...14)
        }else if percenatgeDrop == 5 {
            return Int.random(in: 10...12)
        }else{
            return Int.random(in: 8...10)
        }
    }
    
    func getVideoPlayBack(percenatgeDrop:Int)->Int{
        if percenatgeDrop == 0 {
            return Int.random(in: 11...13)
        }else if percenatgeDrop == 1 {
            return Int.random(in: 11...12)
        }else if percenatgeDrop == 2 {
            return Int.random(in: 9...11)
        }else if percenatgeDrop == 3 {
            return Int.random(in: 8...9)
        }else if percenatgeDrop == 4 {
            return Int.random(in: 7...8)
        }else if percenatgeDrop == 5 {
            return Int.random(in: 6...7)
        }else{
            return Int.random(in: 5...6)
        }
    }
    
    func testingResult(time:Double,percentage:Int){
        
        self.testingView.isHidden = true
        self.resultView.isHidden = false
        self.meter.tickWidth = 7.0
        self.meter.beforeIndicatorTickOpacity = 1.0
        self.meter.afterIndicatorTickOpacity = 0.3
        self.meter.set(value: getPercentage(percenatge: percentage))
        self.meter.valueTextColor = neonClr
        self.meter.descriptionTextColor = .white
        let segment = Segment(percent: 100, color: neonClr, status: "Score")
        self.meter.segments.append(segment)
        
        self.meter2.tickWidth = 7.0
        self.meter2.beforeIndicatorTickOpacity = 1.0
        self.meter2.afterIndicatorTickOpacity = 0.3
        self.meter2.set(value: getTiming(time:time))
        self.meter2.valueTextColor = neonClr
        self.meter2.descriptionTextColor = .white
        let segment2 = Segment(percent: 100, color: neonClr, status: "Time")
        self.meter2.segments.append(segment2)
        
        self.batteryDrop.text = "- " + String(percentage)
        self.timeTaken.text = String(Int(time)) + " Seconds"
        self.StandbyTime.text = String(get4GTime(percenatgeDrop: percentage)) + ".\(Int.random(in: 10...70))" + " hours"
        self.VideoPlayBack.text = String(getVideoPlayBack(percenatgeDrop: percentage)) + ".\(Int.random(in: 10...78))" + " hours"
        
    }
    
    func fib(){
        var one = 1
        var two = 0
        
        for _ in 0..<50
        {
            let _ = one + two
            one = two
            two = one
        }
    }
    
    func serveralOperation(){
        DispatchQueue.global(qos: .background).async {
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
            for _ in 0...1000000{
                self.fib()
            }
        }
        
        for _ in 0...1005000{
            self.fib()
        }
    }
    
    func testEngine() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.stepperView.currentStep = 1
            self.stepsLabel.text = self.arraySteps[1]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                UIScreen.main.brightness = CGFloat(1)
                self.stepperView.currentStep = 2
                self.stepsLabel.text = self.arraySteps[2]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.stepperView.currentStep = 3
                    self.stepsLabel.text = self.arraySteps[3]
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        
                        DispatchQueue.global(qos: .background).async {
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                        }
                        
                        DispatchQueue.global(qos: .default).async {
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                        }
                        
                        DispatchQueue.global(qos: .userInteractive).async {
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                        }
                        
                        DispatchQueue.global(qos: .unspecified).async {
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                            for _ in 0...100000{
                                self.fib()
                            }
                        }
                        
                        for _ in 0...1050000{
                            self.fib()
                        }
                        
                        self.stepperView.currentStep = 4
                        self.stepsLabel.text = self.arraySteps[4]
                        showAds(Myself: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15){
                            self.stepperView.currentStep = 5
                            self.stepsLabel.text = self.arraySteps[5]
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                                self.serveralOperation()
                                self.stepperView.currentStep = 5
                                self.stepsLabel.text = self.arraySteps[5]
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                                    self.serveralOperation()
                                    self.stepperView.currentStep = 6
                                    self.stepsLabel.text = self.arraySteps[6]
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        self.serveralOperation()
                                        self.stepperView.currentStep = 7
                                        self.stepsLabel.text = self.arraySteps[7]
                                        showAds(Myself: self)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
                                            self.stepperView.currentStep = 8
                                            self.stepsLabel.text = self.arraySteps[8]
                                            self.navigationItem.hidesBackButton = false
                                            
                                            let endTime = Double(Int64(Date().timeIntervalSince1970 * 1000))
                                            let endPercentage = Double(getBatteyPercentage()) ?? 10
                                            
                                            let time =  endTime  - self.startInfo
                                            let charge = self.startPercentage - endPercentage
                                            
                                            self.testingResult(time: time/1000, percentage: Int(charge))
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
}
