//
//  ChainRequest.swift
//  Networking
//
//  Created by George on 2018/6/15.
//  Copyright © 2018年 George. All rights reserved.
//

/************************************
 
   按顺序执行的类
   示例：
         ① 创建实例对象
         let chain = ChainRequest()
 
         ② 第一个要执行的请求
         let a = BaseRequest()
         a.url(URLPath.login.rawValue)
         a.requestCompletionCloser({ (obj) in
 
         }, failure: { (err, obj) in
 
         })
 
         ③  把第一个请求添加进顺序执行中
         chainReq.addRequest(a, callBack: { (chainReq, baseReq) in
 
             ④ 第一个执行成功后会执行到这里
             let b = BaseRequest()
             b.url(URLPath.sms.rawValue)
             ⑤ 第一个接口获取到的电话号码是第二个接口的参数
             b.parameters(["mobile":baseReq.mobile])
             b.requestCompletionCloser({ (obj) in
 
             }, failure: { (err, obj) in
 
             })
 
 
             chainReq.addRequest(b, callBack: { (chainReq, baseReq) in
                ⑤ 执行全部请求结束的回调 如果需要有⑥的操作就必须要实现这一步
                chainReq.onComplete()
             })
         })
 
         ⑤ 调用这个方法才会执行
         chain.startRequest()

         ⑥ 全部执行结束后会回到
         chain.allRequestFinished = { _ in
 
         }
 
 *************************************/

import UIKit

final class ChainRequest {
    
    /// 全部请求的缓存
    public var requestArray = [BaseRequest]()
    /// 全部请求的回调
    fileprivate var requestCallBackArray = [ChainCallBack]()
    /// 传nil时候的空回调
    fileprivate var emptyCallBack: ChainCallBack = {_,_ in}
    /// 获取请求缓存的索引
    fileprivate var requestIndex = 0
    /// 完成的设置
    fileprivate var isComplete: Bool?
    
    /// 回调闭包
    typealias ChainCallBack = (_ chainRequest: ChainRequest, _ baseRequest: BaseRequest)->Void
    
    /// 全部请求结束时候的回调 必须要实现requestCount才会回调
    public var allRequestFinished: ((_ chain: ChainRequest)->Void)?
    
}

// MARK: - 基本方法的调用
extension ChainRequest {
    
    /// 添加要回调API的方法
    /// 回调一定是要触发了BaseRequest的requestCompletionCloser的方法才会执行
    /// 如果中间的某一个接口请求失败了 后边的不会继续在执行
    public func addRequest (_ baseReq: BaseRequest, callBack: ChainCallBack?) {
        requestArray.append(baseReq)
        if let callB = callBack {
            requestCallBackArray.append(callB)
        }else{
            requestCallBackArray.append(emptyCallBack)
        }
        
        if requestArray.count > 1 {
            requestIndex += 1
            startRequest()
        }
    }
    
    /// 开始按顺序进行请求
    public func startRequest () {
        
        guard requestArray.count > 0 else {return}
        
        let tempRequest = self.requestArray[self.requestIndex]
        let tempCallBack = self.requestCallBackArray[self.requestIndex]

        tempRequest.chainRequestFinished = {request in

            tempCallBack(self,request)
            
            if let complete = self.isComplete, complete == true {
                self.allRequestFinished?(self)
            }
        }

        tempRequest.chainRequestFailure = {
           Utils.showError("请求返回错误了")
        }
    }
    
    /// 如果在最后一个执行的方法中这函数 实现allRequestFinished
    /// 会在所有请求成功结束后回调这个方法
    public func onComplete () {
        isComplete = true
    }
    
    
    
}
