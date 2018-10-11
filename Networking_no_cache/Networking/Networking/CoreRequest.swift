//
//  CoreRequest.swift
//  Networking
//
//  Created by George on 2018/7/12.
//  Copyright © 2018年 George. All rights reserved.
//

/**************************************
  核心的请求类 主要处理逻辑跟定义属性及属性
  操作
 **************************************/

import UIKit

// MARK: - 请求类型
public enum RequestType: Int {
    case get
    case post
    /// 允许客户端查看服务器的性能
    case options
    /// 只请求页面的首部
    case head
    /// 从客户端向服务器传送的数据取代指定的文档的内容
    case put
    /// 实体中包含一个表，表中说明与该URI所表示的原内容的区别
    case patch
    ///  请求服务器在响应中的实体主体部分返回所得到的内容
    case trace
    /// HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器
    case connect
    /// 请求服务器删除指定的页面
    case delete
}

// MARK: - 编码规格
public enum EncodingType: Int {
    /// JSONEncoding.default 是放在HttpBody内的， 比如post请求
    case JSONEncoding
    /// URLEncoding.default 在GET中是拼接地址的， 比如get请求
    case URLEncoding
    /// URLEncoding(destination: .methodDependent) 是自定义的URLEncoding，methodDependent的值如果是在GET 、HEAD 、DELETE中就是拼接地址的。其他方法方式是放在httpBody内的
    case DestinationMethodDependent
    /// URLEncoding(destination: .httpbody)是放在httpbody内的
    case DestinationHttpbody
}

// MARK: - 主体类
open class CoreRequest {

    var config: Config?
    var authen: Authentication?

    init() {
        setConfig()
        setAuthentication()
    }
    
    /// 两个泛型参数的
    internal typealias TwoGenericsParameterTypealias<L, Y> = (L, Y)->Void
    /// 一个泛型参数的
    internal typealias OneGenericsParameterTypealias<J> = (J)->Void
    
    // MARK: - 回调的处理
    /// 成功回调 【业务成功跟没有设置过滤条件后的成功】
    final var successComGlobal: TwoGenericsParameterTypealias<Any, BaseRequest>?
    /// 失败回调
    final var failureComGlobal: TwoGenericsParameterTypealias<Any, BaseRequest>?
    /// 网络失败回调
    final var netFailureGlobal: OneGenericsParameterTypealias<Error>?
    /// 业务失败的回调
    final var failureProfessionGlobal: TwoGenericsParameterTypealias<Any, BaseRequest>?
    
    
    // MARK: - 过滤条件
    public final var filterCondition: ((_ con: Any)->Bool)?
    public final var filterOk: ((_ con: Any)->Any)?
    public final var filterFailure: ((_ con: Any)->Any)?
    
    
    // MARK: - 顺序请求完毕回调
    public final var chainRequestFinished: ((_ baseReq: BaseRequest)->Void)?
    public final var chainRequestFailure: (()->Void)?
    
    /// 批量请求成功保存的数据
    public final var batchSuccessData: (Any)?
    /// 批量请求失败保存的error值
    public final var batchFailureData: (Error)?
    
    /// 保存的服务器返回数据
    final var obj: Any?
    /// 标记是否已经读取过该接口的缓存
    final var isRead: Int = 0
    
    /// 存储的键
    final var cacheKey: String?
    
    
    // MARK: -  链式属性的值
    /// 链式基准路径
    final public var baseUrlReq: String?
    /// 链式接口拼接路径
    final public var urlReq: String?
    /// 链式header
    final public var headerReq: [String:Any]?
    /// 链式参数
    final public var parametersReq: [String:Any]?
    /// 链式请求方式
    final public var methodTypeReq: RequestType?
    /// 链式接口版本号
    final public var versionReq: String?
    /// 链式是否打印接口数据
    final public var isLogReq: Bool?
    /// 链式接口请求超时时间
    final public var overTimeReq: TimeInterval?
    /// 链式接口是否可以重复请求
    final public var isRepeatRequestReq: Bool?
    /// 链式服务器类型不是在基准路径后边拼接URL的服务器接口类型
    /// 存储数据需要传对应的字段base64后返回作为键用于存储使用
    final public var cacheDataKeyReq: String?
    /// 链式服务器换取header参数 传入对应的键user值pwd
    /// 获取后作为新的header参数传入header作为下一个请求
    /// 字段
    /// 单一接口需要传递服务器的键
    final public var userReq: String?
    /// 链式单一接口需要传递服务器的值
    final public var pwdReq: String?
    /// 链式校验接口返回数据格式是正确
    /// 比如 服务器返回的是是数组格式 [""]
    /// 比如 服务器返回的是是字典格式 ["":""]
    final public var jsonValidatorReq: Any?
    /// 链式cdn
    final public var cdnReq: String?
    /// 链式是否使用cdn
    final public var isUseCdnReq: Bool?
    /// 链式上传图片用的模型数组
    final public var picArrayReq: [PicModel]?
    /// 链式编码类型
    final public var encodingTypeReq: EncodingType?
    /// 链式是否缓存接口数据
    final public var isCacheReq: Bool?
    /// 链式网络失败回调读取本地缓存超过多长时间没有返回数据就认定没有缓存
    final public var netErrorOverTimeReq: Double? 
    

}

// MARK: - 请求类型
extension CoreRequest {
    
    /// 获取请求类型
    final func getHttpType (_ type: RequestType) -> Int {
        var t = RequestType.post
        switch type {
        case .get:
            t = RequestType.get
        case .post:
            t = RequestType.post
        case .put:
            t = RequestType.put
        case .delete:
            t = RequestType.delete
        case .trace:
            t = RequestType.trace
        case .connect:
            t = RequestType.connect
        case .options:
            t = RequestType.options
        case .head:
            t = RequestType.head
        case .patch:
            t = RequestType.patch
        }
        return t.rawValue
    }
}

/// 过滤检索
extension CoreRequest {
    func filtrResponde (_ datas: Any, _ parameters: [String:Any]?, _ target: BaseRequest, isCache: Bool?, _ callBacl: ()->Void) {
        // 本地是否有过滤条件
        if let filter = filterCondition {
            let res = filter(datas)
            if res {
                if let resOK = filterOk {
                    if let successComRes = successComGlobal {
                        obj = datas
                        if let isC = isCache {
                            if isC {
                                if let saveData = config?.saveRequestData {
                                    saveData(true,datas,cacheKey ?? "",target)
                                }
                            }
                        }
                        successComRes(resOK(datas),target)
                       // BaseRequest.realease()
                        callBacl()
                    }
                }
            }else{
                if let resFailure = filterFailure {
                    let resData = resFailure(datas)
                    
                    if let failureComRes = failureComGlobal {
                        obj = resData
                        failureComRes(resData, target)
                        callBacl()
                       // BaseRequest.realease()
                    }
                    
                    /// 只回调业务失败
                    if let professionFailure = failureProfessionGlobal {
                        professionFailure(resData, target)
                    }
                }
            }
            return
        }
        
        // config过滤条件
        if let configFilter = config?.filterCondition {
            let res = configFilter(datas)
            if res {
                if let configResSuccess = config?.filterOk {
                    if let successComRes = successComGlobal {
                        obj = datas
                        if let isC = isCache {
                            if isC {
                                if let saveData = config?.saveRequestData {
                                    saveData(true,datas,cacheKey ?? "",target)
                                }
                            }
                        }
                        successComRes(configResSuccess(datas),target)
                        callBacl()
                       // BaseRequest.realease()
                    }
                }
            }else{
                if let resFailure = config?.filterFailure {
                    let resData = resFailure(datas)
                    if let failureComRes = failureComGlobal {
                        obj = resData
                        failureComRes(resData, target)
                        callBacl()
                      //  BaseRequest.realease()
                    }
                    /// 只回调业务失败
                    if let professionFailure = failureProfessionGlobal {
                        professionFailure(resData, target)
                    }
                }
            }
        }else{
            /// 没有设置过滤条件默认都走请求成功
            if let successComRes = successComGlobal {
                obj = datas
                if isCache != nil {
                    if let saveData = config?.saveRequestData {
                        saveData(true,datas,cacheKey ?? "",target)
                    }
                }
                successComRes(datas,target)
                callBacl()
               // BaseRequest.realease()
            }
        }
    }
}

/// 处理URL跟CDN
extension CoreRequest {
    final func dealUrlCdn (_ isUseCdn: Bool?, _ cdn: String?, _ url: String?, _ baseUrl: String?)->String? {
        
        /// 校验基准接口路径是否为空
        guard let urlBaseTemp = config?.baseUrl,
            urlBaseTemp.count > 0
            else { Utils.showError("基准路径不能为空"); return nil}
        
        // 是否使用cdn
        var useCdnTemp = ""
        var isUseCdnTemp: Bool?
        
        if isUseCdn != nil && cdn != nil {
            isUseCdnTemp = isUseCdn
            if let localCdn = cdn { // 单一接口设置cdn了
                useCdnTemp = localCdn.hasSuffix("/") ? localCdn : localCdn + "/"
            }else{
                if let configCdn = config?.cdn {
                    useCdnTemp = configCdn.hasSuffix("/") ? configCdn : configCdn + "/"
                }
            }
        }
        
        var useUrl = ""
        
        // 子类拼接URL的接口请求类型
        if let tempUrl = url {
            // 子类重写了基准路径跟拼接路径
            if let baseUrlTemp = baseUrl {
                
                if isUseCdnTemp == true  {
                    useUrl = useCdnTemp + ((tempUrl.first == "/") ? tempUrl : ("/" + tempUrl))
                }else{
                    useUrl = baseUrlTemp + ((tempUrl.first == "/") ? tempUrl : ("/" + tempUrl))
                }
                
            }else{
                if isUseCdnTemp == true  {
                    useUrl = useCdnTemp + ((tempUrl.first == "/") ? tempUrl : ("/" + tempUrl))
                }else{
                    useUrl = urlBaseTemp + ((tempUrl.first == "/") ? tempUrl : ("/" + tempUrl))
                }
            }
        }else{
            if let baseUrlTemp = baseUrl {
                if isUseCdnTemp == true  {
                    useUrl = useCdnTemp
                }else{
                    useUrl = baseUrlTemp
                }
            }else{
                if isUseCdnTemp == true  {
                    useUrl = useCdnTemp
                }else{
                    useUrl = urlBaseTemp
                }
            }
        }
        return useUrl
    }
}

// MARK: - log部分
extension CoreRequest {
        final func logSuccess (_ url: String, obj: Any, header:[String:Any], parameters:[String:Any]) {
            if self.config?.globalLogIsOpen == true {
                print("-------------请求的Header----------------------------------------")
                print("\(String(describing: header))")
                print("-------------请求的Parameters----------------------------------------")
                print("\(String(describing: parameters))")
                print("-------------请求的URL----------------------------------------")
                print("\(url)")
                print("-------------服务器返回数据------------------------------------")
                print("\(obj)")
                print("-------------------------------------------------------------")
            }
        }
        
        final func logFailure (_ url: String, err: Error, header:[String:Any], parameters:[String:Any]) {
            if self.config?.globalLogIsOpen == true {
                print("-------------请求的Header----------------------------------------")
                print("\(String(describing: header))")
                print("-------------请求的Parameters----------------------------------------")
                print("\(String(describing: parameters))")
                print("-------------请求的URL----------------------------------------")
                print("\(url)")
                print("-------------服务器返回数据------------------------------------")
                print("\(err)")
                print("-------------------------------------------------------------")
            }
        }
}

// MARK: - 返回接口数据格式校验
extension CoreRequest {
    
    final func validateJSON (_ serviceData: Any, validData: Any) -> Bool {
        
        // 判断是否是字典
        if serviceData is Dictionary<String, Any> && validData is Dictionary<String, Any> {
            // print(serviceData, validData)
            
            let dict = serviceData as! NSDictionary
            let validator = validData as! NSDictionary
            //            let enumerator = validator.keyEnumerator()
            //            var key = ""
            var result = true
            
            
            for (key, _ ) in validator {
                
                let value = dict[key]
                let format = validator[key]
                
                if value == nil {
                    result = false
                    return result
                }
                
                if (value is Dictionary<String, Any>) || (value is Array<Any>) {
                    result = validateJSON(value ?? "", validData: format ?? "")
                    if !result {
                        break
                    }
                }else{
                    
                    if (value is String) && (format is Dictionary<String, Any>) {
                        result = false
                        break
                    }else if (value is String) && format is Array<Any> {
                        result = false
                        break
                    }
                    
                    //                    let res = (value as AnyObject).isKind(of: (format as AnyObject))
                    
                    //                    if ((false) && ((value is NSNull) == false) {
                    //                        result = false
                    //                        break
                    //                    }
                }
            }
            return result
        }
            
        // 判断是否是数组
        else if serviceData is Array<Any> && validData is Array<Any> {
            
            let validatorArray = validData as! NSArray
            if validatorArray.count > 0 {
                let array = serviceData as! NSArray
                let validator = validatorArray[0]
                for item in array {
                    let result = validateJSON(item, validData: validator)
                    if !result {
                        return false
                    }
                }
                
            }
            return true
        }
        else if ((serviceData is Dictionary<String, Any> && validData is Dictionary<String, Any>) ||
            serviceData is Array<Any> && validData is Array<Any>
            ) {
            return true
        }else{
            return false
        }
    }
}
// MARK: - 创建config
extension CoreRequest {
    fileprivate func setConfig () {
        config = Config.sharedInstance
    }
}

// MARK: - 证书授权
extension CoreRequest {
    fileprivate final func setAuthentication () {
        authen = Authentication.sharedInstance
    }
    
    final func checkCer () {
        /// 客户端根据自签名网站地址y验证服务器
        if let host = config?.signedHosts {
            authen?.customerAuthenticationService(host, result: { (res) in
                if self.config?.globalLogIsOpen == true {
                    res ? print("自签名认证成功") : print("自签名认证失败")
                }
            })
        }
        
        /// 客户端跟服务器根据证书进行双向验证
        if let serName = config?.serviceCertificateName,
            let clientName = config?.clientCertificateName,
            let clientPwd = config?.clientCertificatePwd {
            
            authen?.customerServiceInterSecurity(serName, clientCertificateName: clientName, clientCertificatePwd: clientPwd, serviceResult: { (res) in
                if self.config?.globalLogIsOpen == true {
                    res ? print("服务器认证成功") : print("服务器认证失败")
                }
            }, clientResult: { (res) in
                if self.config?.globalLogIsOpen == true {
                    res ? print("客户端认证成功") : print("客户端认证失败")
                }
            }, noTrust: {
                if self.config?.globalLogIsOpen == true {
                    print("双向认证失败")
                }
            })
        }
    }
}

// MARK: - 扩展方法
extension CoreRequest {
    
    /// 取消本次请求
    public final func cancelThisRequest () {
        Agent.sharedInstance.cancelTask()
    }
    
    /// 取消全部的请求
    public final func cancelAllTask () {
        Agent.sharedInstance.cancelAllTask()
    }

}
