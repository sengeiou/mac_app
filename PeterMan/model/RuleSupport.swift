//
//  RuleSupport.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/9.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class RuleSupport: Codable {
    var list:[RuleSupportInfo]=[]
    func getSupport(cid:Int,id:Int)->RuleSupportInfo{
        if list.count==0{
            return RuleSupportInfo()
        }
        for item in list{
            if item.cid == cid&&item.id == id{
                return item
            }
        }
        return RuleSupportInfo()
    }
}

class RuleSupportInfo:Codable{
    var cid:Int=0
    var id:Int=0
    var users:[String]=[]
    
    func isUserHasSupport(ruleInfo:RuleInfo)->Bool{
        let user=AppUtil.getUser()
        if user==nil{
            return false
        }
        if ruleInfo.creator == user! { //自己创建的规则不能点赞
            return true
        }
        return users.contains(user!)
    }
}
