# LMHSwiftRequest

> 在AppDelegate中配置Config

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

	_ = Config.sharedConfig(closure: { (cf) in
	   
	        // 具体根据你的项目需求来设置 这里只是简单的举例说明
	        
	        // 设置基准路径
	        cf.baseUrl("你的基准路径")
	        // 接口数据返回是否打印
	        .isLog(true)
	
	        // 设置过滤条件
	        cf.filterCondition = { con in
	            let dic = con as! [String:Any]
	            return dic["status"] as! String == "0000" ? true : false
	        }
	
	        // 业务成功使用
	        cf.filterOk = { con in
	            let dic = con as! [String:Any]
	            return dic["data"] ?? "empty"
	        }
	
	        // 业务失败使用
	        cf.filterFailure = { (error, con) in
	            return ["err":NSError(domain: "没找到", code: 250, userInfo: nil),"con":con]
	
	    })
}

```

> BasaeRequest的使用

```
基本使用示例：
一、 链式的使用
     BaseRequest.sharedConfig { (base) in
         base.url(URLPath.login.rawValue).isLog(false)
         base.requestCompletionCloser({ (obj) in
         print(obj)
     }, failure: { (err, obj) in
         print(obj)
         })
     }
二、 实例化调用
    ① sharedInstance 不需要全局保存生命周期
     let b = BaseRequest.sharedInstance
       b.url(URLPath.login.rawValue)
       .isLog(false)
       .requestCompletionCloser({ (obj) in
          print(obj)
        }, failure: { (err, obj) in
         print(obj)
        })
 
     ② init() 需要全局保存生命周期
     let b = BaseRequest()
     b.url(URLPath.login.rawValue)
     .isLog(false)
     .requestCompletionCloser({ (obj) in
        print(obj)
     }, failure: { (err, obj) in
        print(obj)
     })
 
    ③ 代理的使用
     let i = BaseRequest.sharedInstance
     i.url(URLPath.login.rawValue)
     i.delegate = self
     i.startRequest()
 
     extension TestViewController: BaseRequestDelegate {
 
         func requestFinished(_ obj: Any, _ req: BaseRequest) {
            print(obj)
         }
 
         func requestFailed(_ err: NSError, _ obj: Any, _ req: BaseRequest) {
            print("--")
         }
     }
 
三、 继承使用
     let b = TestRequest.sharedInstance
     b.url(URLPath.login.rawValue)
     .isLog(false)
     .requestCompletionCloser({ (obj) in
     print(obj)
     }, failure: { (err, obj) in
     print(obj)
     })
```

> BarchRequest 批量请求的使用

```
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
```
> ChainRequest 按顺序执行请求

```
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
         
```
