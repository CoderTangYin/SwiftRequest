//
//  FMDBManager.swift
//  Networking
//
//  Created by George on 2018/5/11.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit
import FMDB

final class FMDBManager {

    private static var instance: FMDBManager?
    public static var sharedInstance: FMDBManager {
        if instance == nil {
            instance = FMDBManager()
        }
        return instance!
    }
    private init() {}
    lazy var dbQueue = FMDatabaseQueue(path: (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last)! + "/mobile.sqlite")
    
    public final var isLog = true
    
}

// MARK: - 基本方法
extension FMDBManager {
    
    public static func sharedDB (closure: (FMDBManager) -> Void) {
        closure(sharedInstance)
    }
    
    /// 建表
    @discardableResult
    public func createTable (_ sql: String) -> FMDBManager {
        orderSql(sql, values: nil) { (res) in
            if isLog {
                if res {print("建表成功")} else{print("建表失败")}
            }
        }
        return self
    }
    
    /// 添加数据
    @discardableResult
    public func inserValue (_ sql: String, content:[Any], callBack: @escaping (_ result: Bool)->Void) -> FMDBManager {
        orderSql(sql, values: content) { (res) in
            if res {
                if isLog {
                    print("添加成功")
                }
                callBack(true)
            } else{
                if isLog {
                    print("添加失败")
                }
                callBack(false)
            }
        }
        return self
    }
    
    /// 删除数据
    @discardableResult
    public func deleteValue (_ sql: String, callBack: @escaping (_ result: Bool)->Void) -> FMDBManager {
        orderSql(sql, values: nil) { (res) in
            if res {
                if isLog {
                    print("删除成功")
                }
                callBack(true)
            } else{
                if isLog {
                    print("删除失败")}
                }
                callBack(false)
        }
        return self
    }
    
    /// 修改数据
    @discardableResult
    public func modifyValue (_ sql: String) -> FMDBManager {
        orderSql(sql, values: nil) { (res) in
            if isLog {
                if res {print("修改成功")} else{print("修改失败")}
            }
        }
        return self
    }
    
    /// 查询数据
    @discardableResult
    public func queryValue (_ sqlQuery: String, field: String, time: String, callBack: (_ res: Any) ->Void) -> FMDBManager {
        
        dbQueue.inDatabase { (db) in
            if db.open() {
                let tempArray = NSMutableArray()
                do {
                    let rs = try db.executeQuery(sqlQuery, values: [field])
                    while rs.next() {
                        let statusData = rs.data(forColumn: "cache_content")
                        let timeDate = rs.string(forColumn: time)
                        if let data = statusData {
                            let dic = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            let resDic = NSMutableDictionary.init()
                            resDic["data"] = dic
                            resDic["cache_time"] = timeDate
                            tempArray.add(resDic)
                        }
                    }
                    db.close()
                } catch {}
                if isLog {
                    print(tempArray)
                }
                callBack(tempArray)
            }
        }
        return self
    }
    
    /// 所有方法调用
    fileprivate func orderSql (_ sql: String, values: [Any]?,  resultCallBack: (_ res: Bool)->Void) {
        dbQueue.inDatabase { (db) in
            db.open()
            if db.open() {
                do {
                    if let val = values {
                        try db.executeUpdate(sql, values: val)
                    }else{
                        try db.executeUpdate(sql, values: nil)
                    }
                    db.close()
                    resultCallBack(true)
                }catch {
                    resultCallBack(false)
                }
            }
        }
    }
}






