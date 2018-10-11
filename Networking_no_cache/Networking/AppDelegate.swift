//
//  AppDelegate.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        _ = Config.sharedConfig(closure: { (cf) in
             cf
            .globalLogIsOpen(true)
            .baseUrl("https://mob.tmbms.teamar.cn/MobileAppV100").isLog(true)
//            cf.clientCertificateName("123.p12")
//            cf.serviceCertificateName("123.cer")
//            cf.clientCertificatePwd("1234")
            .cdn("http://www.hao123.com/")
            .signedHosts(["http://www.baidu.com","https://mobile.tmbms.teamar.cn/","https://wxapi.9fbank.com"])
            
            cf.filterCondition = { con in
                let dic = con as! [String:Any]
                return dic["status"] as! String == "0004" ? true : false
            }

            cf.filterOk = { con in
                let dic = con as! [String:Any]
                return dic["data"] ?? "empty"
            }

            cf.filterFailure = { (con) in
                let dic = con as! [String:Any]
                return dic["info"] ?? "empty"
            }
            
            cf.saveRequestData = { (isCache, data, cacheKey, req) in
                if isCache && cacheKey.count > 0 {
                   let info = req.cacheData()
                    SqlModel.sharedInstance.cacheData(info.cahceName, obj: ["1":"one","2":"two","3":"three"], time: info.cacheTime, version: info.cacheVersion, callBack: { (res) in
                        if res {
                            print("缓存成功")
                        }else{
                            print("缓存失败")
                        }
                    })
                }
            }

            cf.readRequestCacheDataCloser = { (isRead, cacheKey, callData, req) in
                if isRead && cacheKey.count > 0 {
                    let info = req.cacheData()
                    SqlModel.sharedInstance.readCacheData(info.cahceName, callBack: { (res, obj) in
                        #if false
                        // 模拟数据量大延时的情况
                        DispatchQueue(label: "1").asyncAfter(deadline: DispatchTime.now()+12, execute: {
                            callData(obj)
                        })
                        #else
                        if res == true && obj.count > 0  {
                            callData(obj)
                        }else{
                            callData(nil);
                        }
                        #endif
                    })
                }
            }
            
        })
       
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

