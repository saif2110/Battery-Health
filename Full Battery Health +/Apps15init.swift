//
//  Apps15init.swift
//  AI Chat Bot
//
//  Created by Admin on 05/09/23.
//

import Foundation

class Apps15init {
    static var shared = Apps15init()
    var HSB = false
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

                self.HSB = json["HSB"] as! Bool
                //completion(true, json["result"] as! String)
            } catch {
               // completion(true, "NA")
            }
        })

        task.resume()
    }
    
    
}
