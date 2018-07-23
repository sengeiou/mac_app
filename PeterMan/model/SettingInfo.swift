//
//  SettingInfo.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/24.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class SettingInfo: Codable {
    var loginUser:String=""
    var tool:String=""
    var history:[ViewHistory]=[]
}

class ViewHistory:Codable{
    var cid:Int=0
    var id:Int=0
}
