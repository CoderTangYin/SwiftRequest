//
//  JFSqlModel.swift
//  Networking
//
//  Created by George on 2018/6/7.
//  Copyright © 2018年 George. All rights reserved.
//

import UIKit

final class SqlModel {

    fileprivate var db: FMDBManager?
    private static var instance: SqlModel?
    
    public static var sharedInstance: SqlModel {
        if instance == nil {
            instance = SqlModel()
        }
        return instance!
    }
    private init() {
        setDB()
    }
}

// MARK: - 基本方法
extension SqlModel {
    
    public final func globalLogIsOpen ( _ isOpen: Bool) {
        db?.isLog = isOpen
    }
    
    /// cacheName 存储数据的字段名字 obj存储的json数据
    public final func cacheData (_ cacheName: String, obj: Any, time: String, version: String ,callBack: @escaping (_ result: Bool)->Void) {
        
        /// 每次缓存都要删除旧的数据
        let sqlDel = "DELETE FROM temp_table WHERE cache_name = '\(cacheName)'"
        db?.deleteValue(sqlDel, callBack: { (res) in
            
        })
        do {

            let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
//            let data = String.init(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            let sql = "CREATE TABLE IF NOT EXISTS temp_table (id integer PRIMARY KEY AUTOINCREMENT,cache_name text NOT NULL, cache_content blob NOT NULL, cache_time text NOT NULL, version text NOT NULL);"
            let sqlInsert = "INSERT INTO temp_table (cache_name,cache_content,cache_time, version) VALUES(?,?,?,?)"
            db?.createTable(sql).inserValue(sqlInsert, content: [cacheName, jsonData,time,version], callBack: { (res) in
                callBack(res)
            })
        }catch {
            
        }
    }
    
    /// 读取缓存
    public final func readCacheData (_ cacheName: String, callBack: @escaping (_ result: Bool, _ data: [Any])->Void) {
        
        let sqlSel = "SELECT * FROM temp_table WHERE cache_name = ?;"
        db?.queryValue(sqlSel, field: cacheName, time: "cache_time", callBack: { (objArray) in
            let array = (objArray as! NSArray)
            if array.count > 0 {
                callBack(true,objArray as! [Any])
            }else{
                callBack(false,[])
            }
        })
    }
    
    /// 删除删除数据
    public final func deleteCacheData (_ cacheName: String, callBack: @escaping (_ result: Bool)->Void) {
        let cacheName = String.ty_base64(cacheName)
        let sql = "DELETE FROM temp_table WHERE cache_name = '\(cacheName)'"
        db?.deleteValue(sql, callBack: { (res) in
            callBack(res)
        })
    }
}

extension SqlModel {
    fileprivate func setDB () {
        db = FMDBManager.sharedInstance
    }
}
