//
//  Logger.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/19.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class Logger: NSObject {
   
    static func info(_ msg:String){
        AppUtil.saveToFile(str: msg, file: AppUtil.logFile, append: true)
    }
}
