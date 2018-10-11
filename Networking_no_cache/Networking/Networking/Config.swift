//
//  Config.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

/****************************************************
 
    全局的坏境变量
    示例：
    _ = Config.sharedConfig(closure: { (cf) in
        cf.baseUrl("你的URL").isLog(false)
        cf.cdn("你的cdn")
        cf.filterCondition = { con in
            // 填写你的过滤条件
           return "根据条件返回true或者false"
        }
 
        cf.filterOk = { con in
            return 过滤条件为true时候 这里返回服务器的对应要解析字段
        }

        cf.filterFailure = { (error, con) in
        // 可以读取本地的errorcode表返回error给 把对应的服务器返回的数据返回去
           let result =  Utils.errorPlist("NetError").filter({
                     ($0 as! [String:Any])["code"] as! String == dic["status"] as! String
           })
          return ["err":NSError,"obj":con]
        }
 
         /*******************************
            这里可以调用自己的缓存框架
          ********************************/
         cf.saveRequestData = { (isCache, data, cacheKey, req) in
            if isCache && cacheKey.count > 0 {
                let info = req.cacheData()
                SqlModel.sharedInstance.cacheData(info.cacheTime, obj: info.objc, time: info.cacheTime, version: info.cacheVersion, callBack: { (res) in
                    if res {
                        print("缓存成功")
                    }else{
                        print("缓存失败")
                    }
                })
            }
         }
 
         /******************************
            这里可以读取自己的缓存数据
          ******************************/
         cf.readRequestCacheDataCloser = { (isRead, cacheKey, callData, req) in
            if isRead && cacheKey.count > 0 {
                let info = req.cacheData()
                SqlModel.sharedInstance.readCacheData(info.cahceName, callBack: { (res, obj) in
                    if res == true && obj.count > 0  {
                        callData(obj)
                    }
                })
              }
            }
        })
 
 ********************************************/

import UIKit

final class Config {
   
    private static var instance: Config?
    public static var sharedInstance: Config {
        if instance == nil {
            instance = Config()
        }
        return instance!
    }
    
    private init() {}
    
    // MARK: - 属性
    /// 基准路径
    public final var baseUrl: String?
    /// 是否打印
    public final var isLog: Bool?
    /// 版本号
    public final var version: String?
    /// header
    public final var header: (()->[String:Any])?
    /// 请求超时时间
    public final var overTime: TimeInterval?
    /// 是否支持重复请求
    public final var isSupportRepetRequest: Bool? {return true}
    /// cdn
    public final var cdn: String?
    /// 客户端认证服务器自签名网站地址
    public final var signedHosts: [String]? {
        didSet{
            ///
            for (index, item) in (signedHosts?.enumerated())! {
                if item.contains("http://")   {
                    let value = dealString(item, "http://")
                    signedHosts?.remove(at: index)
                    signedHosts?.insert(value, at: index)
                }else if item.contains("https://") {
                    let value = dealString(item, "https://")
                    signedHosts?.remove(at: index)
                    signedHosts?.insert(value, at: index)
                }else{}
            }
            
            // didSet方法中建议不要使用map等高级函数 容易产生异响不到的错误
//            _ = signedHosts.map({$0.map({
//                print($0)
//                if $0.contains("http://")   {
//                    let value = dealString($0, "http://")
//                    signedHosts?.append(value)
//                }else if $0.contains("https://") {
//                    let value = dealString($0, "https://")
//                    signedHosts?.append(value)
//                }else{
//                    signedHosts?.append($0)
//                }
//            })})
            
            if let cdn = cdn {
                if cdn.contains("http://")   {
                    let value = dealString(cdn, "http://")
                    signedHosts?.append(value)
                }else if cdn.contains("https://") {
                    let value = dealString(cdn, "https://")
                    signedHosts?.append(value)
                }else{
                    signedHosts?.append(cdn)
                }
            }
        }
    }
    
    public final var globalLogIsOpen = true
    
    // MARK: - 双向验证
    /// 服务器证书的名字
    public final var serviceCertificateName: String?
    /// 客户端证书的名字
    public final var clientCertificateName: String?
    /// 客户端证书的密码
    public final var clientCertificatePwd: String?
    
    
    // MARK: - 过滤条件
    public final var filterCondition: ((_ con: Any)->Bool)?
    public final var filterOk: ((_ con: Any)->Any)?
    public final var filterFailure: ((_ con: Any)->Any)?
    
    // MARK: - 处理缓存
    
    /// isCache 是否缓存
    /// data 要缓存的数据
    /// cacheKey 缓存的路径
    /// req 当前Request对象回调
    public final var saveRequestData: ((_ isCache: Bool, _ data: Any, _ cacheKey: String, _ req: BaseRequest)->Void)?
    
    /// isRead 接口数据是否读取过
    /// cacheKey 缓存的路径
    /// dataCallBack 获取缓存的数据 dataCallBack?(data)
    /// req 当前Request对象回调
    public final var readRequestCacheDataCloser: ((_ isRead: Bool, _ cacheKey: String, _ dataCallBack: @escaping (_ data: Any?)->Void, _ req: BaseRequest)->Void)?
    
}

// MARK: - 调用属性
extension Config {
    
    /// 单例方法
    public static func sharedConfig (closure: (Config) -> Void) {
        closure(sharedInstance)
    }
    
    /// 基准路径
    @discardableResult
    public final func baseUrl (_ url: String) -> Config {
        baseUrl = url
        return self
    }
    
    /// 是否log接口数据
    @discardableResult
    public final func isLog (_ log: Bool) -> Config {
        isLog = log
        return self
    }
    
    /// 版本号
    @discardableResult
    public final func version (_ ver: String) -> Config {
        version = ver
        return self
    }
    
    /// cdn
    @discardableResult
    public final func cdn (_ cdnPar: String) -> Config {
        cdn = cdnPar
        return self
    }
    
    /// 校验的host地址
    @discardableResult
    public final func signedHosts (_ host: [String]) -> Config {
        signedHosts = host
        return self
    }
    
    /// 服务器证书名字
    @discardableResult
    public final func serviceCertificateName (_ name: String) -> Config {
        serviceCertificateName = name
        return self
    }
    
    /// 客户端证书名字
    @discardableResult
    public final func clientCertificateName (_ name: String) -> Config {
        clientCertificateName = name
        return self
    }
    
    /// 客户端证书密码
    @discardableResult
    public final func clientCertificatePwd (_ pwd: String) -> Config {
        clientCertificatePwd = pwd
        return self
    }
    
    /// 整个框架的log release后建议设置成false
    @discardableResult
    public final func globalLogIsOpen (_ isOpen: Bool) -> Config {
        globalLogIsOpen = isOpen
        return self
    }
    
    /// 处理读取的plist的error
    @discardableResult
    public final func dealError (_ data: [Any], errorPlistName: String) -> NSError {
        return NSError()
    }
    
}

// MARK: - 内部函数
extension Config {
    
    /// 处理协议头的字符串跟包含的‘/’
    fileprivate func dealString (_ origin: String, _ patten: String) -> String {
        var temp = origin as NSString
        temp = temp.replacingOccurrences(of: patten, with: "") as NSString
        temp = temp.contains("/") ? temp.replacingOccurrences(of: "/", with: "") as NSString : temp
        return temp as String
    }
}

