//
//  TestRequest.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit

class TestRequest: BaseRequest {

    
    override var url: String? {
        return URLPath.login.rawValue
    }
//
//    override var isRepeatRequest: Bool? {
//        return false
//    }
    
//    override var isLog: Bool? {
//        return true
//    }
    
//    override var version: String? {
//        return "1.0"
//    }
    
//    override var cacheDataKey: String? {
//        return "123"
//    }
    

//    override var jsonValidator: Any? {
//       // return [[String:String]].self
//        return ["p":"1"]
//    }
    
//    override var isUseCdn: Bool? {
//        return true
//    }
//
//    override var cdn: String? {
//        return "http://www.baidu.com"
//    }
    
    override func cacheData() -> (cahceName: String, cacheTime: String, cacheVersion: String, obj: Any) {
        let tump = super.cacheData()
        
        SqlModel.sharedInstance.cacheData(tump.cahceName, obj: tump.obj, time: tump.cacheTime, version: tump.cacheVersion) { (res) in
            print(res == true ? "ok" : "fail")
        }
        return tump
    }
    
    override func readCacheData(_ callBack: @escaping (Any) -> Void) {
        let info =  getCacheDataInfo()
        print(info)
        
        SqlModel.sharedInstance.readCacheData(info.cahceName) { (res, obj) in
            if res == true && obj.count > 0  {
                callBack(obj)
            }
        }
    }
 
    
    
}
