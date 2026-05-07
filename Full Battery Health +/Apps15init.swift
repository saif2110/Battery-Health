//
//  Apps15init.swift
//  AI Chat Bot
//
//  Created by Admin on 05/09/23.
//

import Foundation
import UIKit
class Apps15init {
    static var shared = Apps15init()

    private static let hsbKey = "Apps15init.HSB"
    private static let iapTypeKey = "Apps15init.IAPTYPE"

    var HSB: Bool {
        didSet { UserDefaults.standard.set(HSB, forKey: Apps15init.hsbKey) }
    }
    var IAPTYPE: Int {
        didSet { UserDefaults.standard.set(IAPTYPE, forKey: Apps15init.iapTypeKey) }
    }

    private init() {
        let d = UserDefaults.standard
        self.HSB = d.bool(forKey: Apps15init.hsbKey)
        self.IAPTYPE = d.integer(forKey: Apps15init.iapTypeKey)
    }

    func start(id:String){
        let params = ["id":id] as Dictionary<String, Any>

        var request = URLRequest(url: URL(string: "https://apps15.com/initApp.php")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {return}
            guard data != nil else {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>

                if let hsb = json["HSB"] as? Bool {
                    self.HSB = hsb
                }
                if let raw = json["IAPTYPE"] {
                    if let i = raw as? Int {
                        self.IAPTYPE = i
                    } else if let s = raw as? String, let i = Int(s) {
                        self.IAPTYPE = i
                    }
                }
            } catch {
               // completion(true, "NA")
            }
        })

        task.resume()
    }

    /// Returns the IAP screen to show based on remote `IAPTYPE` flag.
    /// 0 → existing storyboard-backed `InAppVC`, 1 → new `InAppVC2`.
    func makeIAPVC() -> UIViewController {
        return IAPTYPE == 1 ? InAppVC2() : InAppVC()
    }
}
