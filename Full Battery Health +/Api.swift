//
//  Api.swift
//  EVV
//
//  Created by Abhisar Bhatnagar on 19/11/19.
//  Copyright © 2019 Abhisar Bhatnagar. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

let baseUrl = "https://safeapps.online/StockMarket/"

func postWithParameter(Url:String,parameters:Parameters,completionhandler:@escaping (JSON, Error?) -> ()){
    let url =  baseUrl + Url
    let header : HTTPHeaders = ["Content-Type":"application/json"]//,"Token":(UserDefaults.standard.getToken())
    AF.request(url,method:.post,parameters:parameters,encoding: JSONEncoding.default,headers:header).responseJSON {
        response in
        switch(response.result){
        case .success(_:):
            completionhandler(JSON(response.data!), nil)
            break
        case .failure(_:):
            completionhandler(JSON.null,response.error)
            break
        }
    }
}


func getWithParameter(Url:String,completionhandler:@escaping (JSON, Error?) -> ()){
    AF.request(Url,method:.get).responseJSON {
        response in
        switch(response.result){
        case .success(_:):
            completionhandler(JSON(response.data!), nil)
            break
        case .failure(_:):
            completionhandler(JSON.null,response.error)
            break
        }
    }
}
