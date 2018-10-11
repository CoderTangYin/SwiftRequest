//
//  PicModel.swift
//  Networking
//
//  Created by George on 2018/5/14.
//  Copyright © 2018年 George. All rights reserved.
//

/******************
  上传图片的模型类
 ******************/

import UIKit

open class PicModel {

    /// 存储后的名字
    open var name: String?
    /// 当前图片的名字
    open var fileName: String?
    /// 图片
    open var image: UIImage?
    /// 图片质量
    open var quality: CGFloat{return 0.2}
    
}
