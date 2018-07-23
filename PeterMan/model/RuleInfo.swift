//
//  RuleCategory.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/23.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class RuleInfo: Codable {
    var id:Int=0
    var cid:Int=0
    var name:String="" //名称
    var creator:String="" //创建人
    var createTime:CLongLong=0 //创建时间 (单位：毫秒)
    var label:[String]=[] //标签
    var express:String="" //表达式
    var indicators:Indicator=Indicator() //指标
    var explains:[ExplainInfo]=[] //日志解释

    func getIndicators()->[IndicatorInfo]{
        return indicators.list
    }
    
    func getLabels()->String{
        if label.count==0{
            return ""
        }
        var labelStr=""
        for item in label{
            labelStr.append(item)
            labelStr.append("、")
        }
        labelStr.remove(at: labelStr.index(before: labelStr.endIndex))
        return labelStr
    }
    
    func getTipInfo()->String{
        return indicators.tip
    }
}

class ExplainInfo:Codable{
    var name:String=""
    var pattern:String=""
    var script:String="" //日志解释脚本
}
class Indicator: Codable{
    var tip:String=""
    var list:[IndicatorInfo]=[]
}

class IndicatorInfo: Codable{
    var name:String=""
    var operation:String=""
    var express:String=""
}
