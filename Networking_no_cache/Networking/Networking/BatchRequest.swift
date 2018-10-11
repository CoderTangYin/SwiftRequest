//
//  BatchRequest.swift
//  Networking
//
//  Created by George on 2018/6/15.
//  Copyright © 2018年 George. All rights reserved.
//

/*********************************************
 
    批量请求执行
 
    示例：
    ① 创建批量请求的数据
    let b1 = BaseRequest()
    b1.url(URLPath.login.rawValue)
    let b2 = BaseRequest()
    b2.url(URLPath.login.rawValue)
    let b3 = BaseRequest()
    b3.url(URLPath.login.rawValue)
 
    ② 示例化批量请求实例
    let batch = BatchRequest()
    ③ 添加实例
    batch.requestArray = [b1, b2, b3]
    ④ 全部请求结束后回调
    batch.startWithCompletion(.normal, { (bat) in
    _ = bat.requestArray.map({
        print($0.batchSuccessData ?? "")
    })
    }) { (bat) in
 
    }
 
 *********************************************/

import UIKit

public enum BatchRequestType {
    /// 普通网络请求
    case normal
    /// 上传
    case upload
    /// 下载
    case download
}

final class BatchRequest {
    
    /// 请求成功返回的接口数据
    public var requestArray = [BaseRequest]()
    /// 失败返回的数据
    public var failureArray = [BaseRequest]()
    
    fileprivate var count = 0
    fileprivate var failureCount = 0
    
    fileprivate var successBatchGlobal: ((_ batchReq: BatchRequest)->Void)?
    fileprivate var failureBatchGlobal: ((_ batchReq:BatchRequest)->Void)?
    
    /// 批量请求全部开始
    public func startWithCompletion (_ type: BatchRequestType,
                                     _ success: @escaping (_ batchReq: BatchRequest)->Void,
                                     failure: @escaping (_ batchReq:BatchRequest)->Void) {
        successBatchGlobal = success
        failureBatchGlobal = failure
        
        switch type {
        case .normal:
            normal()
        case .upload:
            upload()
        case .download:
            download()
        }
    }
    
    /// 批量处理一般网络请求
    fileprivate func normal () {
        
        guard requestArray.count > 0 else {return}
        count = 0
        failureCount = 0
        
        for req in requestArray {
            
            req.requestCompletion(professionsuccess: { (obj, req) in
                req.batchSuccessData = (obj)
                self.count += 1
                if self.count == (self.requestArray.count - self.failureCount) {
                    self.successBatchGlobal?(self)
                }
            }, professionFailure: { (obj, req) in
                self.failureCount += 1
                self.failureArray.append(req)
                self.failureBatchGlobal?(self)
            }) { (err) in
                self.failureCount += 1
                self.failureArray.append(req)
                self.failureBatchGlobal?(self)
            }
        }
    }
    
    /// 批量上传
    fileprivate func upload () {
        guard requestArray.count > 0 else {return}
        count = 0
        failureCount = 0
        
        for req in requestArray {
            req.requestCompletionUpLoadPic({ (pro) in
                
            }, success: { (obj) in
                req.batchSuccessData = (obj)
                self.count += 1
                if self.count == (self.requestArray.count - self.failureCount) {
                    self.successBatchGlobal?(self)
                }
            }) { (err) in
                self.failureCount += 1
                self.failureArray.append(req)
                self.failureBatchGlobal?(self)
            }
        }
    }
    
    /// 批量下载
    fileprivate func download () {
        guard requestArray.count > 0 else {return}
        count = 0
        failureCount = 0
        
        for req in requestArray {
            req.requestDownload({ (pro, total) in
                
            }) { (res, path) in
                if res {
                    req.batchSuccessData = (path)
                    self.count += 1
                    if self.count == (self.requestArray.count - self.failureCount) {
                        self.successBatchGlobal?(self)
                    }
                }else{
                    self.failureCount += 1
                    self.failureArray.append(req)
                    self.failureBatchGlobal?(self)
                }
            }
        }
        
    }
    
}
