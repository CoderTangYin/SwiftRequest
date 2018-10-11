//
//  Agent.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

/******************
  衔接Alamofire处理业务
 ******************/

import UIKit
import Alamofire

///// 允许客户端查看服务器的性能
//case options
///// 只请求页面的首部
//case head
///// 从客户端向服务器传送的数据取代指定的文档的内容
//case put
///// 实体中包含一个表，表中说明与该URI所表示的原内容的区别
//case patch
/////  请求服务器在响应中的实体主体部分返回所得到的内容
//case trace
///// HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器
//case connect
///// 请求服务器删除指定的页面
//case delete

enum NetType: Int {
    case Get
    case Post
    case Options
    case Head
    case Put
    case Patch
    case Trace
    case Connetct
    case Deltet
}

// MARK: - 编码规格
public enum AgentEncodingType: Int {
    case JSONEncoding
    case URLEncoding
    case DestinationMethodDependent
    case DestinationHttpbody
}

final class Agent {

    private static var instance: Agent?
    public static var sharedInstance: Agent {
        if instance == nil {
            instance = Agent()
        }
        return instance!
    }
    private init() {
        setConfig()
        setTaskPool()
    }
    
    // MARK: - 内部生命周期全局属性
    fileprivate var config: Config?
    fileprivate var dataRequest: DataRequest?
    fileprivate var manager: SessionManager = Alamofire.SessionManager.default
    fileprivate var taskPool: TaskPool?
    fileprivate var downloadRequest: DownloadRequest?
    fileprivate var cancelledData: Data?
    fileprivate var progressCloser: ((_ prog: Double, _ total: Double)->Void)?
    fileprivate var downloadResultHandle: ((_ res: Bool, _ filePath: String)->Void)?
    fileprivate var downloadUrl: String?
    fileprivate var downloadMethod: NetType?
    fileprivate var downloadParameters: [String:Any]?
    fileprivate var downloadPathString: String?

    // MARK: - 外部可以赋值的属性
    /// 保存全局用的header
    var header: [String:Any]?
    /// 超时时间
    var overTime: TimeInterval?
    var isRepeatRequest: Bool?
    /// 授权的用户名
    var user: String?
    /// 授权的密码
    var pwd: String?
    /// 是否使用cdn
    var isUseCdn: Bool?
    /// cdn名字
    var cdn: String?
    /// 选择的编码类型
    var encodingTypeAgent: AgentEncodingType?
    
}

// MARK: - 网络请求部分
extension Agent {
    /// 请求方法
    public func urlString(_ url: String, type: NetType, parameters: [String: Any]?, success:@escaping (_ resultCallBack: Any, _ printData: Data?)->Void, failure:@escaping (_ error: Error)->Void) {
        
        var header = getHeader()
        
        if let user = user, let pwd = pwd {
            header = getHttpHeader(&header, user, pwd:pwd )
        }
        
        if let timeCon = config?.overTime {
            if let timeReq = overTime {
                manager.session.configuration.timeoutIntervalForRequest = timeReq
            }else{
                manager.session.configuration.timeoutIntervalForRequest = timeCon
            }
        }else{
            manager.session.configuration.timeoutIntervalForRequest = 60
        }
        
        var encodingType: ParameterEncoding?
        
        if let encodeing = encodingTypeAgent {
            switch encodeing {
            case .JSONEncoding:
                encodingType = JSONEncoding.default
            case .URLEncoding:
                encodingType = URLEncoding.default
            case .DestinationMethodDependent:
                encodingType = URLEncoding(destination: .methodDependent)
            case .DestinationHttpbody:
                encodingType = URLEncoding(destination: .httpBody)
            }
        }
        
        dataRequest = manager.request(url, method: getHttpType(type), parameters: parameters, encoding: encodingType ?? URLEncoding.default , headers: header).responseJSON { [weak self] (response) in
            
            guard let strongSelf = self else {return}
          
            switch response.result {
            case .success:
                if let JSON = response.result.value {
                    let task = strongSelf.dataRequest?.task as! URLSessionDataTask
                    if (strongSelf.taskPool?.currentRunningTasks().contains(task))! {
                        strongSelf.taskPool?.removeTask(task)
                    }
                    success(JSON,response.data)
                }
            case .failure(let error):
                let task = strongSelf.dataRequest?.task as! URLSessionDataTask
                if (strongSelf.taskPool?.currentRunningTasks().contains(task))! {
                    strongSelf.taskPool?.removeTask(task)
                }
                failure(error)
            }
        }
        
        // 单一接口不准许重复请求
        if  isRepeatRequest == false {
            let task = self.dataRequest?.task as! URLSessionDataTask
            if let oldTask = taskPool?.cancleSameRequestInTasksPool(task) {
                taskPool?.removeTask(oldTask)
            }
        }else{
            if let result = config?.isSupportRepetRequest {
                if result == false {
                    let task = self.dataRequest?.task as! URLSessionDataTask
                    if let oldTask = taskPool?.cancleSameRequestInTasksPool(task) {
                        taskPool?.removeTask(oldTask)
                    }
                }
            }
        }
        taskPool?.addTask(self.dataRequest?.task as! URLSessionDataTask)
    }
}

// MARK: - 上传图片
extension Agent {
    /// 上传图片
    public func urlUpLoadPic (_ urlUpLoad: String, netType: NetType ,parameters: [String:Any]?, picArray:[PicModel], progressCloser: @escaping (_ prg: CGFloat)->Void ,success: @escaping (_ res: Any)->Void, failure: @escaping (_ err: Any)->Void) {
        
        
        let header = getHeader()
        
        manager.upload(multipartFormData: { (formdata) in
            for pic in picArray {
                let data = UIImageJPEGRepresentation(pic.image!, pic.quality)
                formdata.append(data!, withName: pic.name!, fileName: pic.fileName!, mimeType: "image/jpeg")
            }
            
            //拼接参数
            if let param = parameters {
                for (key, value) in param {
                    formdata.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: urlUpLoad, method: getHttpType(netType), headers: header) { (encodingResult) in
            
            switch encodingResult{
            case .success(let uploadFile, _, _):
                //上传进度回调
                uploadFile.uploadProgress(closure: { (progress) in
                    let value = CGFloat(100.0) * CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
                    progressCloser(value)
                })
                
                //上传结果回调
                uploadFile.responseJSON(completionHandler: { (response) in
                    success(response.result.value as Any)
                })
                break
            case .failure( let error):
                failure(error)
                break
            }
        }
    }

}

// MARK: - 下载
extension Agent {
    
    /// 下载的方法
    public func urlDownload (_ url: String?, method: NetType, parameters: [String:Any]?, progressCloser: @escaping (_ prog: Double, _ total: Double)->Void, downloadResultHandle: @escaping (_ res: Bool, _ filePath: String)->Void) {
        
        self.progressCloser = progressCloser
        self.downloadResultHandle = downloadResultHandle
        
        downloadUrl = url
        downloadMethod = method
        downloadParameters = parameters
        
    }
    
    /// 开始下载
    public func beginDownload () {
        
        guard let url = downloadUrl, url.count > 0 else {return}
        let method = downloadMethod ?? .Post
        let parameters = downloadParameters ?? nil
        
        // 续下
        if let cancelledData = cancelledData {
            downloadRequest = manager.download(resumingWith: cancelledData, to: downloadPath())
            downloadRequest?.downloadProgress(closure: { [weak self] (progress) in
                self?.progressCloser?(progress.fractionCompleted, Double(progress.totalUnitCount))
            })
            
        
            
            downloadRequest?.responseData(completionHandler: { [weak self] (res) in
                self?.downloadResponse(response: res)
            })
        }else{ // 开始下
            let t = (method == .Get ? HTTPMethod.get : HTTPMethod.post)
            let path = downloadPath()
            
            if downloadParameters != nil {
                downloadRequest = manager.download(url, method: t, parameters: parameters, encoding: URLEncoding.default, headers: getHeader(), to: downloadPath())
            }else{
                downloadRequest = manager.download(url, to: path)
            }
            
            downloadRequest?.downloadProgress(closure: { [weak self] (progress) in
                self?.progressCloser?(progress.fractionCompleted, Double(progress.totalUnitCount))
            })
            downloadRequest?.responseData(completionHandler: { [weak self] (res) in
                self?.downloadResponse(response: res)
            })
        }
    }
    
    /// 暂停下载
    public func pauseDownload () {
        downloadRequest?.cancel()
    }
    
    /// 下载结果处理
    func downloadResponse(response:DownloadResponse<Data>){
        switch response.result {
        case .success( _):
            //下载完成
            downloadResultHandle?(true, self.downloadPathString ?? "")
        case .failure(error:):
            self.cancelledData = response.resumeData //意外中止的话把已下载的数据存起来
            downloadResultHandle?(false, self.downloadPathString ?? "")
            break
        }
    }
    
    /// 下载路径
    fileprivate func downloadPath () -> DownloadRequest.DownloadFileDestination {
        //设置下载路径。保存到用户文档目录，文件名不变，如果有同名文件则会覆盖
        //指定下载路径
        let destination:DownloadRequest.DownloadFileDestination = { _, response in
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentURL.appendingPathComponent(response.suggestedFilename!)
            self.downloadPathString = fileURL.absoluteString
            return (fileURL,[.removePreviousFile,.createIntermediateDirectories])
        }
        return destination
    }
}

// MARK: - 内部函数
extension Agent {
    
   fileprivate func setConfig () {
        config = Config.sharedInstance
    }
    
   fileprivate func setTaskPool () {
        taskPool = TaskPool.sharedInstance
   }
    
    public func cancelTask () {
        taskPool?.cancellTask(self.dataRequest?.task as! URLSessionDataTask)
    }
    
    public func cancelAllTask () {
        taskPool?.cancelAllTaskPool()
    }
    
    /// 普通的header
    fileprivate func getHeader () -> HTTPHeaders {
        var header: HTTPHeaders = [:]
        
        /// 全局的header
        if let headerTemp = config?.header?() {
            for (key, value) in headerTemp {
                header[key] = value as? String
            }
        }
        
        /// 单一接口的header
        if let headerTempBase = self.header {
            header.removeAll()
            for (key, value) in headerTempBase {
                header[key] = value as? String
            }
        }
        return header
    }
    
    /// http的header 需要服务器授权的
    fileprivate func getHttpHeader (_ header: inout HTTPHeaders, _ user: String, pwd: String) -> HTTPHeaders {
        if let authorizationHeader = Request.authorizationHeader(user: "xxxx", password: "xxxxxx") {
            header[authorizationHeader.key] = authorizationHeader.value
        }
        return header
    }
    
    /// 获取请求类型
    fileprivate func getHttpType (_ type: NetType) -> HTTPMethod {
        var t = HTTPMethod.post
        switch type {
        case .Get:
            t = HTTPMethod.get
        case .Post:
            t = HTTPMethod.post
        case .Put:
            t = HTTPMethod.put
        case .Deltet:
            t = HTTPMethod.delete
        case .Trace:
            t = HTTPMethod.trace
        case .Connetct:
            t = HTTPMethod.connect
        case .Options:
            t = HTTPMethod.options
        case .Head:
            t = HTTPMethod.head
        case .Patch:
            t = HTTPMethod.patch
        }
        return t
    }
}











