//
//  AppWindowController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/22.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa
class AppWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let setUpController = SetUpViewController()
        setUpController.windowDelegate=self
        self.contentViewController = setUpController
        
        
        //标题
        window?.title="小飞侠"
        
        //设置窗口背景颜色
        self.window!.backgroundColor = NSColor.white
        //        self.window?.isMovableByWindowBackground=true //点击窗口背景可拖动窗口
        //        self.window?.titlebarAppearsTransparent=true //标题栏透明
    }
    
    /// 获取登录状态，如果已填写昵称，则进入登录页面，否则进入主页面
    func goPage(){
        let loginUser=AppUtil.getUser()
        if loginUser==nil||loginUser!==""{
            let loginViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "LoginViewController"))
            self.contentViewController = loginViewController as? NSViewController
        }else{
            let homeContainer =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HomeContainerViewController"))
            self.contentViewController = homeContainer as? NSViewController
        }
    }
}

extension AppWindowController:AppWindowControllerDelegate{
    func setUpCallbackSuccess() {
        goPage()
    }
}
protocol AppWindowControllerDelegate:AnyObject{
    
    func setUpCallbackSuccess()
}
