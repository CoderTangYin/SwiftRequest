//
//  TestViewController.swift
//  Networking
//
//  Created by George on 2018/6/19.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBAction func upload(_ sender: Any) {
  
        
    }
    
    @IBAction func filter(_ sender: Any) {
        
        BaseRequest.sharedConfig { (req) in
            req
            .isCache(true)
            .isLog(false)
            .baseUrl("https://wxapi.9fbank.com")
            .url("/api/account/regist")
            .parameters(["phoneNum, ":"13100000000","verifyCode":"1234"])
            .requestCompletion(encodingType: { () -> EncodingType in
                return .DestinationMethodDependent
            }, filterCondition: { (obj) -> Bool in
                return true
            }, filterOk: { (obj) -> Any in
                return ["Age":"18"]
            }, filterFailure: { (obj) -> Any in
                return NSObject()
            }, professionsuccess: { (obj, req) in
                print(obj)
            }, professionFailure: { (obj, req) in
                
            }, netErrorFailure: { (err) in
                
            })
        }
        
        
//        BaseRequest.sharedConfig { (req) in
//                req
//                .isCache(true)
//                .isLog(false)
//                .baseUrl("https://mob.tmbms.teamar.cn/MobileAppV100")
//                .url("/Public/checkCode")
//                .parameters(["phoneNum, ":"13100000004","verifyCode":"1234"])
//                .requestCompletion(encodingType: { () -> EncodingType in
//                    return .DestinationMethodDependent
//                }, filterCondition: { (obj) -> Bool in
//                    return true
//                }, filterOk: { (obj) -> Any in
//                    return ["Age":"18"]
//                }, filterFailure: { (obj) -> Any in
//                    return NSObject()
//                }, professionsuccess: { (obj, req) in
//
//                }, professionFailure: { (obj, req) in
//
//                }, netErrorFailure: { (err) in
//
//                })
//        }
    }
    
    @IBAction func batch(_ sender: Any) {
        
//        let b1 = BaseRequest()
//        b1.url(URLPath.login.rawValue)
//        let b2 = BaseRequest()
//        b2.url(URLPath.login.rawValue)
//        let b3 = BaseRequest()
//        b3.url(URLPath.login.rawValue)
//
//        let batch = BatchRequest()
//        batch.requestArray = [b1, b2, b3]
//        batch.startWithCompletion(.normal, { (bat) in
//           _ = bat.requestArray.map({
//                print($0.batchSuccessData ?? "")
//            })
//        }) { (bat) in
//
//        }
//
        
        
//        BaseRequest.sharedConfig { (base) in
//            base.url(URLPath.login.rawValue).isLog(false)
//            base.requestCompletionCloser({ (obj) in
//                print(obj)
//
//            }, failure: { (err, obj) in
//                print(obj)
//            })
//        }
//
//        BaseRequest.sharedConfig { (base) in
//            base.url(URLPath.login.rawValue).isLog(false)
//
//        }
        
        
//        let b = BaseRequest.sharedInstance
//        b.url(URLPath.login.rawValue)
//        .isLog(false)
//        .requestCompletionCloser({ (obj) in
//            print(obj)
//        }, failure: { (err, obj) in
//            print(obj)
//        })
        
        
        
    }
   
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let i = BaseRequest.sharedInstance
        i.url(URLPath.login.rawValue)
//        i.startRequestForImpementationDelegate()
        
//        let b = BaseRequest.sharedInstance
//        b.url("")
//
//
//        let a = Bundle(for: Agent.self).path(forResource: "NetError.plist", ofType: nil)
//        let arr = NSArray.init(contentsOfFile: a ?? "")
//        print(arr)
    }
    
    deinit {
       // b.cancelThisRequest()
        print("----")
    }
    

}

//extension TestViewController: BaseRequestDelegate {
////    func requestFinished(_ obj: Any, _ req: BaseRequest) {
////        print(obj)
////    }
////
////    func requestFailed(_ err: NSError, _ obj: Any, _ req: BaseRequest) {
////        print("--")
////    }
//    
//    
//}
