//
//  TaskPool.swift
//  Networking
//
//  Created by George on 2018/5/25.
//  Copyright © 2018年 George. All rights reserved.
//

/******************
   网络缓存池
 ******************/

import UIKit
import Foundation

final class TaskPool {

    private static var instance: TaskPool?
    public static var sharedInstance: TaskPool {
        if instance == nil {
            instance = TaskPool()
        }
        return instance!
    }
    private init() {}
    /// 缓存的数组
    var taskPool = [URLSessionDataTask]()
}

extension TaskPool {
    /// 添加任务
    func addTask (_ task: URLSessionDataTask) {
        taskPool.append(task)
    }
    
    /// 移除任务
    func removeTask (_ task: URLSessionDataTask) {
        if taskPool.contains(task) {
            taskPool.remove(at: taskPool.index(of: task)!)
        }
    }
    
    /// 取消全部请求
    func cancelAllTaskPool () {
        _ = taskPool.map({
            if $0.isKind(of: URLSessionDataTask.self) {
                $0.cancel()
            }
        })
        taskPool.removeAll()
    }
    
    /// 取消对应的请求
    func cancellTask (_ task: URLSessionDataTask) {
        if taskPool.contains(task) {
            task.cancel()
            taskPool.remove(at: taskPool.index(of: task)!)
        }
    }
    
    /// 获取当前的任务
    func currentRunningTasks () -> [URLSessionDataTask] {
        return taskPool
    }
    
    /// 取消相同接口的请求
    func cancleSameRequestInTasksPool (_ task: URLSessionDataTask) -> URLSessionDataTask? {
        var oldTask: URLSessionDataTask?
        _ = taskPool.map({
            if isSameRequest(task.originalRequest!, urlOld: $0.originalRequest!) {
                if $0.state == .running {
                    $0.cancel()
                    oldTask = $0
                }
            }
        })
        return oldTask
    }
    
    /// 判断是否为同一接口
    func isSameRequest (_ urlNew: URLRequest, urlOld: URLRequest) -> Bool {
        
        guard let urlNMethod = urlNew.httpMethod else { return false  }
        guard let urlOMethod = urlOld.httpMethod else { return false  }
        guard let urlNStr = urlNew.url?.absoluteString else { return false  }
        guard let urlOStr = urlOld.url?.absoluteString else { return false  }
        
        if urlNMethod == urlOMethod {
            if urlNStr == urlOStr {
                if urlNMethod == "GET" || urlNew.httpBody == urlOld.httpBody {
                    return true
                }
            }
        }
        return false
    }
}


