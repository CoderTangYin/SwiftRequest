//
//  ChainTestRequest.swift
//  Networking
//
//  Created by George on 2018/6/15.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit

class ChainTestRequest: BaseRequest {
    
    override var url: String? {
        return URLPath.login.rawValue
    }
    
    override var isLog: Bool? {
        return false
    }
    
    func login () {
//        requestCompletionCloser({ (obj) in
//            self.name = "11"
//        }) { (err, obj) in
//            self.name = "11"
//
//        }
    }
    
}
