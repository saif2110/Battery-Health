//
//  MainCell2.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit
import SwiftySound
import MediaPlayer
import AudioToolbox

class MainCell2: UITableViewCell {

    var mySound:Sound?
    
    @IBOutlet weak var soundSegment: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.string(forKey: "ring") != nil {
            if UserDefaults.standard.string(forKey: "ring") == "bell"{
                soundSegment.selectedSegmentIndex = 0
            }else if UserDefaults.standard.string(forKey: "ring") == "melody"{
                soundSegment.selectedSegmentIndex = 1
            }else{
                soundSegment.selectedSegmentIndex = 2
            }
        }
        
    }

    
    @IBAction func selectSound(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setandPlaysound(nameofSound:"bell")
        }else if sender.selectedSegmentIndex == 1 {
            setandPlaysound(nameofSound:"melody")
        }else{
            setandPlaysound(nameofSound:"siren")
        }
    }
    
    
    func setandPlaysound(nameofSound:String) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        mySound?.stop()
        mySound?.volume = 1
        mySound = Sound(url: Bundle.main.url(forResource: nameofSound, withExtension: "mp3")!)
        mySound?.play(numberOfLoops: 0, completion: nil)
        UserDefaults.standard.setValue(nameofSound, forKey: "ring")
    }
    
}
