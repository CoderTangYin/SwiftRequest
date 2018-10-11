//
//  BaseRequest.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

/**************************************
 
    网络请求的直接使用类
    基本使用示例：
     一、 链式的使用
         BaseRequest.sharedConfig { (req) in
            req.baseUrl("")
            req.url("")
            req.parameters(["phoneNum, ":"13100000000","verifyCode":"1234"])
            req.requestCompletion(encodingType: { () -> EncodingType in
                return .URLEncoding
            }, filterCondition: { (obj) -> Bool in
                return true
            }, filterOk: { (obj) -> Any in
                return true
            }, filterFailure: { (obj) -> Any in
                return NSObject()
            }, professionsuccess: { (obj, req) in
 
            }, professionFailure: { (obj, req) in
 
            }, netErrorFailure: { (err) in
 
            })
         }
     二、 实例化调用
             ① sharedInstance 不需要全局保存生命周期
             let b = BaseRequest.sharedInstance
               b.url(URLPath.login.rawValue)
               .isLog(false)
               .requestCompletion({ (obj, req) in
 
                }, professionFailure: { (obj, req) in
 
                }) { (err) in
                 print(err)
                }
 
             ② init() 需要全局保存生命周期
             let b = BaseRequest()
             b.url(URLPath.login.rawValue)
             .isLog(false)
             .requestCompletion({ (obj, req) in
 
             }, professionFailure: { (obj, req) in
 
             }) { (err) in
             print(err)
             }
 
            ③
 
     三、 继承使用
         let b = TestRequest.sharedInstance
         b.url(URLPath.login.rawValue)
         .isLog(false)
         .requestCompletionCloser({ (obj) in
            print(obj)
         }, failure: { (err, obj) in
            print(obj)
         })
 
 ****************************************/

import UIKit

// MARK: - 类
open class BaseRequest: CoreRequest {
    
    fileprivate static var instance: BaseRequest?
    public static var sharedInstance: BaseRequest {
        if instance == nil {
            instance = BaseRequest()
        }
        return instance!
    }
    
    // MARK: - 系统init方法 这种方法需要保存实例变量来确保生命周期
    override init() {
        super.init()
    }
    
    // MARK: - 属性重新写
    /// 重写基准路径(不支持set赋值)
    open var baseUrl: String? {return baseUrlReq ?? nil}
    /// 重写拼接路径(不支持set赋值)
    open var url: String? {return urlReq ?? nil}
    /// 重写header(不支持set赋值)
    open var header: [String:Any]? {return headerReq ?? nil}
    /// 重写参数(不支持set赋值)
    open var parameters: [String:Any]? {return parametersReq ?? nil}
    /// 重写请求方式(不支持set赋值)
    open var methodType: RequestType {return methodTypeReq ?? .post}
    /// 重写版本号(不支持set赋值)
    open var version: String? {return versionReq ?? nil}
    /// 重写是否打印接口数据(不支持set赋值)
    open var isLog: Bool? {return isLogReq ?? false}
    /// 重写请求超时时间(不支持set赋值)
    open var overTime: TimeInterval? {return overTimeReq ?? 60}
    /// 重写是否可以重复请求(不支持set赋值)
    open var isRepeatRequest: Bool? {return isRepeatRequestReq ?? true}
    /// 重写(不支持set赋值)服务器类型不是在基准路径后边拼接URL的服务器接口类型
    /// 存储数据需要传对应的字段base64后返回作为键用于存储使用
    open var cacheDataKey: String? {return cacheDataKeyReq ?? nil}
    /// 重写(不支持set赋值)校验接口返回数据格式是正确
    /// 比如 服务器返回的是是数组格式 [""]
    /// 比如 服务器返回的是是字典格式 ["":""]
    open var jsonValidator: Any? {return jsonValidatorReq ?? nil}
    /// 重写cdn(不支持set赋值)
    open var cdn: String? {return cdnReq ?? nil}
    /// 重写是否使用cdn(不支持set赋值)
    open var isUseCdn: Bool? {return isUseCdnReq ?? false}
    /// 重写(不支持set赋值)服务器换取header参数 传入对应的键user值pwd
    /// 获取后作为新的header参数传入header作为下一个请求
    /// 字段
    /// 单一接口需要传递服务器的键
    open var user: String? {return userReq ?? nil}
    /// 重写单一接口需要传递服务器的值(不支持set赋值)
    open var pwd: String? {return pwdReq ?? nil}
    /// 重写上传图片用的模型数组(不支持set赋值)
    open var picArray: [PicModel]? {return nil}
    /// 重写编码类型(不支持set赋值)
    open var encodingType: EncodingType? {return encodingTypeReq ?? .URLEncoding}
    /// 重写(不支持set赋值)是否进缓存 设置这一属性后网络失败会去读取缓存 如果有
    /// 缓存把之前的缓存数据返回去 如果有网络每次回对缓存进行更新
    open var isCache: Bool? {return isCacheReq ?? false}
    /// 网络失败回调读取本地缓存超过多长时间没有返回数据就认定没有缓存 默认是7秒的时间
    open var netErrorOverTime: Double? {return netErrorOverTimeReq ?? 7.0 }
    
    // MARK: - 处理缓存  因为是open属性所以不能够在extension中去写
    
    /// 子类重写调用父类的方法获得
    /// 缓存的接口URLbase64后的值cahceName cacheTime缓存那一刻的时间 cacheVersion当前接口的版本号
    /// objc服务器返回的数据
    open func cacheData () -> (cahceName: String, cacheTime: String, cacheVersion: String, obj: Any) {
        // 校验单一接口路径是否为空
        var urlTemp = ""
        if let signalUrl = url {
            urlTemp = signalUrl
            if let par = parameters {
                if (!JSONSerialization.isValidJSONObject(par)) {
                    if self.config?.globalLogIsOpen == true {
                        print("无法解析出JSONString")
                    }
                }else{
                    let data = try! JSONSerialization.data(withJSONObject: par, options: []) as Data
                    let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
                    if let jsonStr = JSONString {
                        urlTemp = urlTemp + (jsonStr as String)
                    }
                }
            }
        }else{
            if let tempCache = cacheDataKey {
                urlTemp = tempCache
            }
        }
        let cacheDate = Utils.getCurrentTime()
        let time = Utils.timeForDate(cacheDate)
        return (String.ty_base64(urlTemp),time,version ?? "没设置版本号", obj ?? "")
    }
   
    /// 获取接口缓存的信息 cahceName接口URLbase64后的值
    /// cacheVersion缓存的版本号
    /// cacheIsRead当前的接口是否读取过缓存了 用于请求数据读取过之后进行第二次请求时候的逻辑处理
    /// 类似于新浪微博 首页默认去本地缓存之后点击tabbar之后请求信数据
    open func getCacheDataInfo () -> (cahceName: String, cacheVersion: String, cacheIsRead: Bool) {
        // 校验单一接口路径是否为空
        var urlTemp = ""
        if let signalUrl = url {
            urlTemp = signalUrl
        }else{
            if let tempCache = cacheDataKey {
                urlTemp = tempCache
            }
        }
        if isRead == 0 {
            isRead = 1
            return (String.ty_base64(urlTemp),version ?? "没设置版本号", false)
        }else{
            return (String.ty_base64(urlTemp),version ?? "没设置版本号", true)
        }
    }
    
    /// 子类可重写读取缓存的方法在内部可以调用getCacheDataInfo方法获取到缓存的信息 读取缓存再通过
    /// callBack回调出去 外边接口可以直接调用这个方法获取到数据
    open func readCacheData (_ callBack: @escaping (_ res: Any) -> Void) {}

}

// MARK: - 请求方法调用部分
extension BaseRequest {
    
    // MARK: - 请求接口
    
    /// 子类直接调用 返回服务器数据跟当前类实例对象 实例对象可以用于做扩展业务操作使用
    /// professionsuccess -> 业务成功
    /// professionFailure -> 业务失败
    /// netErrorFailure   -> 网络失败
    public final func requestCompletion (professionsuccess: @escaping (_ respondes: Any, _ req: BaseRequest)->Void, professionFailure: @escaping (_ respondes: Any, _ req: BaseRequest)->Void, netErrorFailure: @escaping (_ error: Error)->Void) {
        checkCer()
        successComGlobal = professionsuccess
        netFailureGlobal = netErrorFailure
        failureProfessionGlobal = professionFailure
        requestNetDatas()
    }
    
    /// encodingType      -> 编码的规格
    /// filterCondition   -> 过滤条件
    /// filterOk          -> 过滤成功
    /// filterFailure     -> 过滤失败
    /// professionsuccess -> 业务成功
    /// professionFailure -> 业务失败
    /// netErrorFailure   -> 网络失败
    public final func requestCompletion (encodingType:(()->EncodingType)?,
                                         filterCondition: ((_ con: Any)->Bool)?,
                                         filterOk: ((_ con: Any)->Any)?,
                                         filterFailure: ((_ con: Any)->Any)?,
                                         professionsuccess: @escaping (_ respondes: Any, _ req: BaseRequest)->Void,
                                         professionFailure: @escaping (_ respondes: Any, _ req: BaseRequest)->Void,
                                         netErrorFailure: @escaping (_ error: Error)->Void) {
        
        self.encodingTypeReq = encodingType?()
        self.filterCondition = filterCondition
        self.filterOk = filterOk
        self.filterFailure = filterFailure
        
        checkCer()
        successComGlobal = professionsuccess
        netFailureGlobal = netErrorFailure
        failureProfessionGlobal = professionFailure
        requestNetDatas()
    }
    
    /// 上传图片
    public final func requestCompletionUpLoadPic (_ progress: @escaping (_ prg: CGFloat)->Void ,success: @escaping (_ res: Any)->Void, failure: @escaping (_ err: Any)->Void) {
        
        checkCer()

        // 1.下载的方式跟参数
        let method = getHttpType(methodType)
        let parameters = self.parameters ?? nil
        
        // 验证基准路径 拼接路径 cdn
        guard let useUrl = dealUrlCdn(isUseCdn, cdn, url, baseUrl) else {return}
        guard let picArr = self.picArray else {Utils.showError("上传图片模型不能为空"); return}
        
        Agent.sharedInstance.urlUpLoadPic(useUrl, netType: NetType(rawValue: method) ?? NetType(rawValue: 1)!, parameters: parameters, picArray: picArr, progressCloser: { (prog) in
            progress(prog)
        }, success: { (obj) in
            success(obj)
        }) { (err) in
            failure(err)
        }
    }
    
    /// 下载
    public final func requestDownload (_ progressCloser: @escaping (_ prog: Double, _ total: Double)->Void, downloadResultHandle: @escaping (_ res: Bool, _ filePath: String)->Void) {
       
        checkCer()

        // 1.下载的方式跟参数
        let method = getHttpType(methodType)
        let parameters = self.parameters ?? nil
        // 验证基准路径 拼接路径 cdn
        guard let useUrl = dealUrlCdn(isUseCdn, cdn, url, baseUrl) else {return}
        
        Agent.sharedInstance.urlDownload(useUrl, method: NetType(rawValue: method)!, parameters: parameters, progressCloser: { (progrss, total) in
            progressCloser(progrss,total)
        }) { (res, path)  in
            downloadResultHandle(res,path)
        }
    }
    
    /// 开始下载
    public final func begingDowmload () {
        Agent.sharedInstance.beginDownload()
    }
    
    /// 暂停下载
    public final func pauseDownload () {
        Agent.sharedInstance.pauseDownload()
    }
    
    /// 销毁
    fileprivate final class func realease () {
        instance = nil
    }
}

// MARK: - 数据处理
extension BaseRequest {
    
    ///  直接发送网络请求的
    fileprivate func requestNetDatas () {
        
        // 验证基准路径 拼接路径 cdn
        guard let useUrl = dealUrlCdn(isUseCdn, cdn, url, baseUrl) else {return}

        // 设置header
        if let header = header {
            Agent.sharedInstance.header = header
        }
        // 设置请求超时
        if let time = overTime {
           Agent.sharedInstance.overTime = time
        }
        // 是否准许重复请求
        if let isRep = isRepeatRequest {
            Agent.sharedInstance.isRepeatRequest = isRep
        }
        
        if let encoding = encodingType {
            switch encoding {
            case .JSONEncoding:
                 Agent.sharedInstance.encodingTypeAgent = AgentEncodingType.JSONEncoding
            case .URLEncoding:
                Agent.sharedInstance.encodingTypeAgent = AgentEncodingType.URLEncoding
            case .DestinationMethodDependent:
                Agent.sharedInstance.encodingTypeAgent = AgentEncodingType.DestinationMethodDependent
            case .DestinationHttpbody:
                Agent.sharedInstance.encodingTypeAgent = AgentEncodingType.DestinationHttpbody
            }
        }
        // 拼接缓存的key
        cacheKey = Utils.appedUrlWithParamter(useUrl, parameters)
        // 发网络请求
        let method = getHttpType(methodType)
        Agent.sharedInstance.urlString(useUrl, type:NetType(rawValue: method)!,
                                       parameters: parameters,
                                       success: { [weak self] (obj,printData) in
            guard let strongSelf = self else { return }
            // 校验服务器返回格式
            if let validate = strongSelf.jsonValidator {
                let result =  strongSelf.validateJSON(obj, validData: validate)
                if !result {
                    Utils.showError("服务器返回类型与校验类型不匹配")
                    return
                }
            }
                                        
            if strongSelf.isLog == true {
                if let data = printData {
                    strongSelf.logSuccess(useUrl, obj: String(data: data , encoding: .utf8) ?? "",header: strongSelf.header ?? ["":""],parameters: strongSelf.parameters ?? ["":""])
                }else{
                    strongSelf.logSuccess(useUrl, obj: obj,header: strongSelf.header ?? ["":""],parameters: strongSelf.parameters ?? ["":""])
                }
            }else{
                
                if strongSelf.config?.isLog ?? false {
                    if let data = printData {
                        strongSelf.logSuccess(useUrl, obj: String(data: data , encoding: .utf8) ?? "",header: strongSelf.header ?? ["":""],parameters: strongSelf.parameters ?? ["":""])
                    }else{
                        strongSelf.logSuccess(useUrl, obj: obj,header: strongSelf.header ?? ["":""],parameters: strongSelf.parameters ?? ["":""])
                    }
                }
            }
                      
            /// 把数据传递进行条件过滤
            strongSelf.filtrResponde(obj, strongSelf.parameters, strongSelf, isCache: strongSelf.isCache, {
                BaseRequest.realease()
            })
            /// 请求成功后把自己传递出去
            strongSelf.chainRequestFinished?(strongSelf)
            /// 顺序执行成功
            strongSelf.batchSuccessData = (obj)
                                        
        }) { [weak self] (error) in
            guard let strongSelf = self else { return }
            if strongSelf.isLog == true {
                strongSelf.logFailure(useUrl, err: error, header: strongSelf.header ?? ["":""], parameters: strongSelf.parameters ?? ["":""])
            }else{
                if strongSelf.config?.isLog ?? false {
                    strongSelf.logFailure(useUrl, err: error, header: strongSelf.header ?? ["":""], parameters: strongSelf.parameters ?? ["":""])
                }
            }
            
            // 网络请求错误的缓存读取
            var isCallNext = true
            let err = error as NSError
            if err.code == -1009 {
                if let res = strongSelf.isCache {
                    if res {
                        // runlopp实现
                        #if false
                        let runlop = RunLoop.current
                        let port = NSMachPort.init()
                        runlop.add(port, forMode: .defaultRunLoopMode)
                        // 传递给外界回传缓存数据用的闭包
                        let callData: (_ dataTemp: Any?)->Void =  { (data) -> Void in
                            runlop.remove(port, forMode: .defaultRunLoopMode)
                            if let datas = (data as? Array<Any>)?.first as? [String:Any] {
                                strongSelf.successComGlobal?(datas["data"] ?? [], strongSelf)
                                isCallNext = false
                            }
                        }
                        strongSelf.config?.readRequestCacheDataCloser?(true,strongSelf.cacheKey ?? "",callData,strongSelf)
                        runlop.run(mode: .commonModes, before: Date.distantFuture)
                        
                        #else
                        
                        // 判断是否获取缓存数据超时了
                        var isCallBackData = true
                        // 创建信号量为0
                        let sema = DispatchSemaphore(value: 0)
                        // 传递给外界回传缓存数据用的闭包
                        let callData: ((_ dataTemp: Any?)->Void) =  { (data) -> Void in
                            if let datas = (data as? Array<Any>)?.first as? [String:Any] {
                                // 如果超时了已经执行了失败的回调 此时又突然接受到了外边的回调数据 就停止后边的行为
                                guard isCallBackData else {return}
                                strongSelf.successComGlobal?(datas["data"] ?? [], strongSelf)
                                isCallNext = false
                                // +1 为0时表示当前并没有线程等待其处理的信号量 不为0时，表示其当前有（一个或多个）线程等待其处理的信号量，并且该函数唤醒了一个等待的线程（当线程有优先级时，唤醒优先级最高的线程；否则随机唤醒）
                                sema.signal()
                            }
                        }
                        strongSelf.config?.readRequestCacheDataCloser?(true,strongSelf.cacheKey ?? "",callData,strongSelf)
                        // 上边的信号量为0 是如果超过默认秒数还没有拿到回调的数据就执行下边的代码操作
                        _ = sema.wait(timeout: DispatchTime.now() + (strongSelf.netErrorOverTime!))
                        isCallBackData = false
                        #endif
                    }
                }
            }
            
            /// 如果有缓存就不要执行后边的 [暂停网络服务器失败回调 批量请求失败回调]
            if !isCallNext {
                BaseRequest.realease()
                return
            }
            
            /// 把网络错误回调出去
            if let netFailure = strongSelf.netFailureGlobal {
                netFailure(error)
            }
            
            /// 把失败的原因抛给批量请求
            strongSelf.batchFailureData = (error)
            if let failureComRes = self?.failureComGlobal {
                failureComRes("服务器接口数据失败了:--\(error.localizedDescription)", strongSelf)
                BaseRequest.realease()
            }
            /// 顺序执行失败
            strongSelf.chainRequestFailure?()
            BaseRequest.realease()
        }
    }
}

// MARK: - 链式语法调用部分
extension BaseRequest {
    
    /// 链式初始化
    public static func sharedConfig (closure: (BaseRequest) -> Void) {
        closure(sharedInstance)
    }
    
    /// 链式过滤条件
    @discardableResult
    public final func filterCondition (_ parCon: @escaping (_ con: Any)->Bool) -> BaseRequest {
        filterCondition = parCon
        return self
    }
    
    /// 链式过滤成功
    @discardableResult
    public final func filterOk (_ parOk: @escaping (_ con: Any)->Any) -> BaseRequest {
        filterOk = parOk
        return self
    }
    
    /// 链式过滤失败
    @discardableResult
    public final func filterFailure (_ parFailed: @escaping (_ con: Any)->Any) -> BaseRequest {
        filterFailure = parFailed
        return self
    }
    
    /// 链式基准路径
    @discardableResult
    public final func baseUrl (_ url: String) -> BaseRequest {
        baseUrlReq = url
        return self
    }
    
    /// 链式拼接路径
    @discardableResult
    public final func url (_ url: String) -> BaseRequest {
        urlReq = url
        return self
    }
    
    /// 链式参数
    @discardableResult
    public final func parameters (_ parameters: [String:Any]) -> BaseRequest {
        parametersReq = parameters
        return self
    }
    
    /// 链式请求方式
    @discardableResult
    public final func methodType (_ methodType: RequestType) -> BaseRequest {
        methodTypeReq = methodType
        return self
    }
    
    /// 链式版本号
    @discardableResult
    public final func version (_ version: String) -> BaseRequest {
        versionReq = version
        return self
    }
    
    /// 链式接口数据是否打印
    @discardableResult
    public final func isLog (_ isLog: Bool) -> BaseRequest {
        isLogReq = isLog
        return self
    }
    
    /// 链式请求超时
    @discardableResult
    public final func overTime (_ overTime: TimeInterval) -> BaseRequest {
        overTimeReq = overTime
        return self
    }
    
    /// 链式缓存key
    @discardableResult
    public final func cacheDataKey (_ key: String) -> BaseRequest {
        cacheDataKeyReq = key
        return self
    }
    
    /// 链式传递服务器的键
    @discardableResult
    public final func user (_ user: String) -> BaseRequest {
        userReq = user
        return self
    }
    
    /// 链式传递服务器的值
    @discardableResult
    public final func pwd (_ pwd: String) -> BaseRequest {
        pwdReq = pwd
        return self
    }
    
    /// 链式返回数据格式校验
    @discardableResult
    public final func jsonValidator (_ validator: Any) -> BaseRequest {
        jsonValidatorReq = validator
        return self
    }
    
    /// 链式cdn
    @discardableResult
    public final func cdn (_ cdnPar: String) -> BaseRequest {
        cdnReq = cdnPar
        return self
    }
    
    /// 链式是否使用cdn
    @discardableResult
    public final func isUseCdn (_ useCdn: Bool) -> BaseRequest {
        isUseCdnReq = useCdn
        return self
    }
    
    /// 链式上传图片模型
    @discardableResult
    public final func picUpload (_ picArray: [PicModel]) -> BaseRequest {
        picArrayReq = picArray
        return self
    }
    
    /// 链式encoding格式
    @discardableResult
    public final func encodingType (_ type: EncodingType) -> BaseRequest {
        encodingTypeReq = type
        return self
    }
    
    /// 链式是否缓存
    @discardableResult
    public final func isCache (_ isC: Bool) -> BaseRequest {
        isCacheReq = isC
        return self
    }
    
    /// 链式是否缓存
    @discardableResult
    public final func netErrorOverTime (_ isOverTime: Double) -> BaseRequest {
        netErrorOverTimeReq = isOverTime
        return self
    }
}




