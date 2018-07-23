//
//  AppConfig.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/2.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AppConfig: Codable {
    var categorys:[RuleCategory]=[]
    var operations:[String]=[]
    var appList:[String]=[]
    var appVersion=1
}
class RuleCategory: Codable {
    var id:Int=0
    var name:String=""
}

