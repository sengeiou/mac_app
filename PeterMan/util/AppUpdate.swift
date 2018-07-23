//
//  AppUpdate.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/10.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AppUpdate: NSObject {
    
    static func checkUpdate()->Bool{
        AppUtil.update()
        let appConfig=AppUtil.getConfig()
        let newVersion=appConfig!.appVersion
        let infoDirectory=Bundle.main.infoDictionary
        let localVersion=infoDirectory!["CFBundleVersion"] as! Int
        let localVersionStr=infoDirectory!["CFBundleShortVersionString"] as! String
        
        return newVersion>localVersion
    }
    
    static func updateApp(){
        
        let contentDir=AppUtil.contentDir
        let manager = FileManager.default
        let files = try?manager.contentsOfDirectory(atPath: contentDir)
        var appName=""
        for item in files!{
            if item.hasSuffix(".app"){
                appName=item
                break
            }
        }
        
        let appFile=contentDir+"/"+appName
        
        let url=Bundle.main.path(forResource: "setup", ofType: "sh")
        let subCount="/Contents/Resources/setup.sh".count
        let offset=url!.count-subCount
        let index=url?.index(url!.startIndex, offsetBy: offset)
        let targetAppFile = url!.substring(to: index!)
        //
        let fileManager = FileManager.default
        try! fileManager.copyItem(atPath: appFile, toPath: targetAppFile)
        
        
    }
    
}
