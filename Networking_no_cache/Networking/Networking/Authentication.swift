//
//  Authentication.swift
//  Networking
//
//  Created by George on 2018/6/20.
//  Copyright © 2018年 George. All rights reserved.
//

/******************
   客户端与服务器验证
 ******************/

import UIKit
import Alamofire

final class Authentication {

    private static var instance: Authentication?
    
    public static var sharedInstance: Authentication {
        if instance == nil {
            instance = Authentication()
        }
        return instance!
    }
    
    fileprivate var signedHosts: [String]?
    fileprivate var config: Config?
    fileprivate var manager: SessionManager = Alamofire.SessionManager.default

    private init() {}
    
}

// MARK: - 证书校验

/// 存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}


extension Authentication {
    
    /// 服务器 客户端双向验证
    public final func customerServiceInterSecurity (_ serviceCertificateName: String,
                                                    clientCertificateName: String,
                                                    clientCertificatePwd: String,
                                                    serviceResult: @escaping (_ res: Bool)->Void,
                                                    clientResult: @escaping(_ res: Bool)->Void,
                                                    noTrust: @escaping ()->Void) {
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            //认证服务器证书
            if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust {
                let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let remoteCertificateData
                    = CFBridgingRetain(SecCertificateCopyData(certificate))!
                
                let cerPath = Bundle(for: Authentication.self).path(forResource: serviceCertificateName, ofType: nil)
                
                let cerUrl = URL(fileURLWithPath:cerPath ?? "")
                let localCertificateData = try? Data(contentsOf: cerUrl)
                
                if (remoteCertificateData.isEqual(localCertificateData) == true) {
                    let credential = URLCredential(trust: serverTrust)
                    challenge.sender?.use(credential, for: challenge)
                    serviceResult(true)
                    return (URLSession.AuthChallengeDisposition.useCredential,
                            URLCredential(trust: challenge.protectionSpace.serverTrust!))
                } else {
                    serviceResult(false)
                    return (.cancelAuthenticationChallenge, nil)
                }
            }
                //认证客户端证书
            else if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodClientCertificate {
                //获取客户端证书相关信息
                let identityAndTrust:IdentityAndTrust = self.extractIdentity(clientCertificateName, pwd: clientCertificatePwd)
                
                let urlCredential: URLCredential = URLCredential (
                    identity: identityAndTrust.identityRef,
                    certificates: identityAndTrust.certArray as? [AnyObject],
                    persistence: URLCredential.Persistence.forSession
                )
                clientResult(true)
                return (.useCredential, urlCredential)
            }
                // 其它情况（不接受认证）
            else {
                noTrust()
                return (.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    //获取客户端证书相关信息
    func extractIdentity(_ clientCertificateName: String, pwd: String) -> IdentityAndTrust {
        var identityAndTrust: IdentityAndTrust!
        var securityError: OSStatus = errSecSuccess
        
        let path = Bundle(for: Authentication.self).path(forResource: clientCertificateName, ofType: nil) ?? ""
        
        let PKCS12Data = NSData(contentsOfFile:path) ?? NSData.init()
        let key: NSString = kSecImportExportPassphrase as NSString
        let options: NSDictionary = [key : pwd] //客户端证书密码
        
        var items: CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = (items as CFArray?)!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = (identityPointer as! SecIdentity?)!
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!)
            }
        }
        return identityAndTrust;
    }
    
    
    /// 客户端认证r服务器
    public final func customerAuthenticationService (_ signedHost: [String],  result: @escaping (_ res: Bool)->Void) {
        signedHosts = signedHost
        if let signedHost = signedHosts {
            manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                //认证服务器（这里不使用服务器证书认证，只需地址是我们定义的几个地址即可信任）
                if challenge.protectionSpace.authenticationMethod
                    == NSURLAuthenticationMethodServerTrust
                    && signedHost.contains(challenge.protectionSpace.host) {
                    let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    result(true)
                    return (.useCredential, credential)
                }else{
                    result(false)
                    return (.cancelAuthenticationChallenge, nil)
                }
            }
        }
    }
}
