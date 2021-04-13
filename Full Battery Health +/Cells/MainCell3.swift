//
//  MainCell3.swift
//  Full Battery Health
//
//  Created by Junaid Mukadam on 07/03/21.
//

import UIKit
import MediaPlayer

class MainCell3: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(Changed), name: Notification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        slider.value = 1
        DispatchQueue.main.async {
            MPVolumeView.setVolume(self.slider.value)
        }
    }
    
    @objc func Changed(_ notification: Notification) {
        let userInfo = notification.userInfo
        let volume = userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as? Float
        slider.value = volume ?? 1
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        slider?.setValue(sender.value, animated: false)
        MPVolumeView.setVolume(sender.value)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
