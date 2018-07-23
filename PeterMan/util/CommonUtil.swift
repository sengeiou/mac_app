//
//  CommonUtil.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/25.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class CommonUtil: NSObject {

    static func base64Encoding(_ plainString:String)->String{
        if plainString.isEmpty{
            return ""
        }
        let plainData = plainString.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    
    static func base64Decoding(_ encodedString:String)->String{
        if encodedString.isEmpty{
            return ""
        }
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
}
