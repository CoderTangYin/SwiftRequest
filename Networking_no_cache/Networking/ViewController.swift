//
//  ViewController.swift
//  Networking
//
//  Created by George on 2018/5/10.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

//    let disbag = DisposeBag()
//    let t = TestRequest()
//    let t1 = TestRequest()
//    
//    let test = TestRequest()
//    
//    
//    var subject = PublishSubject<[String:Any]>()
//    var subject1 = PublishSubject<[String:Any]>()
//    
//    // MARK: - 普通的传参数发送请求然后出来服务器返回的数据
//    let justRequest = { (ele: [String:String]?) -> Observable<Any> in
//        return Observable.create { observer in
//            let t = BaseRequest()
//            t.parameters(ele ?? ["":""])
//            t.url("/Public/login")
//            .isLog(true)
//            .requestCompletion({ (obj, req) in
//                observer.onNext(obj as! [String : String])
//                observer.onCompleted()
//            }, professionFailure: { (obj, req) in
//                observer.onNext(obj)
//                observer.onCompleted()
//            }, netErrorFailure: { (err) in
//                observer.onNext(err)
//                observer.onCompleted()
//            })
//            }
//        return Disposables.create() as! Observable<Any>
//        }
//    }
//        
//    let justRequest1 = { () -> Observable<[String:Any]> in
//        
//        return Observable.create { observer in
//            let t = BaseRequest()
//            t.url("/Public/login")
//                .isLog(true)
////                .requestCompletionCloser({ (obj) in
////                    observer.onNext(obj as! [String : String])
////                    observer.onCompleted()
////                }) { (error, obj) in
////                    observer.onNext(["err":error,"obj":obj])
////                    observer.onCompleted()
////            }
//            return Disposables.create()
//        }
//    }
//    
//    // MARK: - 执行完接口1拿到数据后再执行接口2
//    @IBAction func order(_ sender: Any) {
//        
//        var par = ""
//        
//        let variable = Variable(subject)
//        
//        variable.asObservable().concat().subscribe(onNext: { (value) in
//            
//            let t1 = BaseRequest.sharedInstance
//            t1.url("/Public/login")
//                .parameters(value as! [String : String])
//                .isLog(false)
////                .requestCompletionCloser({ (obj) in
////                   print("order 结束")
////                }) { (error, obj) in
////                   print("order 结束")
////                }
//            
//        }).disposed(by: disbag)
//        
//        variable.value = subject1
//        
//        let t = BaseRequest.sharedInstance
//        t.url("/Public/login")
//            .isLog(false)
////            .requestCompletionCloser({ (obj) in
////                self.subject.onNext(obj as! [String : Any])
////            }) { (error, obj) in
////                self.subject.onNext(["err":error,"obj":obj])
////        }
//    }
//    
//    // MARK: - 一个界面要请求多个接口后返回数据才能更新
//    @IBAction func merageAction(_ sender: Any) {
//        
//        Observable.zip(subject,subject1).subscribe(onNext: { (req1,req2) in
//            print("\(req1) \n \n ","\(req2)")
//        }).disposed(by: disbag)
//        
//        
//        let t = BaseRequest()
//        t.url("/Public/login")
//            .isLog(false)
//        
//        
//        let t1 = BaseRequest()
//        t1.url("/Public/login")
//            .isLog(false)
//        
//        
//    }
//   
//    let batch = BatchRequest()
//    
//    @IBAction func batch(_ sender: Any) {
//    
//        let b1 = BaseRequest()
//        b1.url(URLPath.login.rawValue)
//        let b2 = BaseRequest()
//        b2.url(URLPath.login.rawValue)
//        let b3 = BaseRequest()
//        b3.url(URLPath.login.rawValue)
//
//
//        batch.requestArray = [b1,b2,b3]
//        batch.startWithCompletion(.normal, { (bat) in
//            print(bat.requestArray.count)
//        }) { (bat) in
//            
//        }
//
//    }
//    
//    @IBAction func downAct(_ sender: Any) {
//        
////       let url = "http://p3.wmpic.me/article/2016/01/02/1451705414_FCsmpfEP.jpg"
////
////        let url1 = "http://172.21.0.40/dashboard/Upload/wenjia.php"
////
////        let b = BaseRequest()
////        b.baseUrl(url1)
////
////
////        let pic = PicModel()
////        pic.fileName = "123"
////        let imag = UIImage(contentsOfFile: Bundle.main.path(forResource: "1451705414_FCsmpfEP", ofType: "jpg")!)
////        pic.image = imag
//
//    
//        
//        
//    }
//    
//    @IBAction func inhert(_ sender: Any) {
//        
////        self.test.readCacheData { (obj) in
////            print(obj)
////        }
////        
////        self.test .requestCompletionCloser({ (obj) in
////            _ = self.test.cacheData()
////        }) { (err, obj) in
////            _ = self.test.cacheData()
////        }
////        
//        
//    }
//    
//    /// 通过信号来订阅
//    @IBAction func rxAction(_ sender: Any) {
//        
////        justRequest(["":""]).subscribe(onNext: { (objc) in
////            print(objc)
////        }).disposed(by: disbag)
////
////        justRequest(nil).subscribe(onNext: { (value) in
////            print(value)
////        }).disposed(by: disbag)
////
//        
////        let t = BaseRequest()
////        t.url("/Public/login")
////        .isLog(true)
////            .requestCompletionCloser({ (obj) in
////                self.subject.onNext(obj as! [String : Any])
////            }) { (error, obj) in
////                self.subject.onNext(["err":error,"obj":obj])
////        }
//        
//        
////        let t1 = BaseRequest()
////        t1.url("/Public/login")
////            .isLog(true)
////            .requestCompletionCloser({ (obj) in
////                self.subject.onNext(obj as! [String : Any])
////            }) { (error, obj) in
////                self.subject.onNext(["err":error,"obj":obj])
////        }
//        
//    }
//    
//    @IBAction func act(_ sender: Any) {
//
//        
//        let chain = ChainRequest()
//        
//        let testChain = ChainTestRequest()
//        testChain.login()
//        
//        
//        chain.addRequest(testChain) { (chainReq, baseReq) in
//            
//            let a = BaseRequest()
//            a.url(URLPath.login.rawValue)
//
//            
//            chainReq.addRequest(a, callBack: { (chainReq, baseReq) in
//                
//                let b = BaseRequest()
//                b.url(URLPath.login.rawValue)
//
//                chainReq.addRequest(b, callBack: { (chainReq, baseReq) in
//                    
//                    let c = BaseRequest()
//                    c.url(URLPath.login.rawValue)
//
//                    chainReq.addRequest(c, callBack: { (chainReq, baseReq) in
//                       // print("------")
//                        chainReq.onComplete()
//                    })
//                    
//                })
//                
//            })
//            
//        }
//        
//        chain.startRequest()
//
//        
//        
//        chain.allRequestFinished = { c in
//            print(c)
//        }
//        
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//}
//
//extension ViewController {
//    
//    func subcribe () {
//        
//        /// 把两个消息合并在一起
//        Observable.of(subject,subject1)
//        .merge()
//        .subscribe(onNext: { (obj) in
//                print(obj)
//        }).disposed(by: disbag)
//        
//    }
//    
//    // MARK: - RX写法
//    func localTest () -> Single<[String:Any]> {
//        return Single<[String:Any]>.create { sing in
//            BaseRequest().url("/Public/login")
//                .isLog(true)
//                .filterCondition({ obj in
//                    return true
//                })
//                .filterOk({ obj in
//                    return obj
//                })
//                .filterFailure({ (error, obj) in
//                    return ["err":NSError(domain: "123", code: 250, userInfo: nil),"con":obj]
//                })
//                .requestCompletionCloser({ (obj) in
//                    sing(.success(obj as! [String:Any]))
//                }) { (error, obj) in
//                    sing(.error(NSError(domain: "名字", code: 99999, userInfo: obj as? [String : Any])))
//            }
//            return Disposables.create()
//        }
//    }
}
