//
//  Utils.swift
//  Networking
//
//  Created by George on 2018/5/11.
//  Copyright © 2018年 George. All rights reserved.
//

/******************
  工具类
 ******************/

import UIKit

final class Utils {

    public class func showError (_ content: String) {
        UIAlertView(title: "提示", message: content, delegate: nil, cancelButtonTitle: "取消").show()
    }
    
    public class func dateForString (_ time: String) -> Date {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-sss"
        return formatter.date(from: time)!
    }
    
    public class func getCurrentTime () -> Date {
        let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd HH-mm-sss"
        let dateTime = formatter.string(from: Date())
        let date = formatter.date(from: dateTime)
        return date!
    }

    
    public class func timeForDate (_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return formatter.string(from: Date())
    }
    
    public class func dateForSecond (_ second: TimeInterval) -> Date {
        let future = Date(timeIntervalSinceNow: second)//Date(timeInterval: TimeInterval(second), since: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let dateTime = formatter.string(from: future)
        return formatter.date(from: dateTime)!
    }

    public class func compareOneDayWithAnotherDay (_ oneDay: Date, anotherDay: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let oneDayStr = formatter.string(from: oneDay)
        let anotherDayStr = formatter.string(from: anotherDay)
        let dateA = formatter.date(from: oneDayStr)
        let dateB = formatter.date(from: anotherDayStr)
        let result = dateA!.compare(dateB!)
        if result == .orderedDescending {
            return -1
        } else if (result == .orderedAscending) {
            return 1
        }else{
            return 0
        }
    }
    
    /// 获取整个项目的错误码
    public static func errorPlist (_ name: String) -> [Any] {
        let plist = Bundle(for: self).path(forResource: name, ofType: "plist")
        let array = NSArray(contentsOfFile: plist ?? "") as? [Any]
        return array ?? ["empty"]
    }
    
    public static func appedUrlWithParamter(_ url:String ,_ paramter:Dictionary<String,Any>?) -> String {
        var wholeURL = ""
        if url.contains("?") {
            wholeURL = url + urlParametersStringFromParameters(paramter)
        }
        else {
            wholeURL = url + "?" + urlParametersStringFromParameters(paramter)
        }
        return urlEncode(str: wholeURL)!
    }
    
    /// 参数进行拼接
    fileprivate static func urlParametersStringFromParameters(_ param:Dictionary<String,Any>?) -> String {
        if param?.keys.count == 0 {
            return ""
        }
        var str = ""
        if let arr = param?.keys {
            for key in arr {
                if let value = param?[key] as? String {
                    if value.count == 0 {
                        continue
                    }
                    str.append("&" + key + "=" + urlEncode(str: value)!)
                }
            }
        }
        return str
    }
}

extension String
{
    public static func ty_base64 (_ string: String) -> String {
        let utf8EncodeData = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        // 将NSData进行Base64编码
        let base64String = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
        return base64String ?? "没成功"
    }
}


//url进行编码防止中文或者其他特殊字符出现
fileprivate func urlEncode(str:String) -> String? {
    let cfTempStr = str as CFString
    let escapeString = "!*'();:@&=+$,/?%#[]" as CFString
    if let encodedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                cfTempStr,
                                                                "" as CFString,
                                                                escapeString,
                                                                CFStringBuiltInEncodings.UTF8.rawValue)
    {
        return encodedStr as String
    }
    
    if #available(iOS 9.0, *){
        
    }else{

    }
    return nil
}




















