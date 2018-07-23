//
//  ViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/4/26.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    
    @IBOutlet weak var nicknameView: NSTextField!
    @IBOutlet weak var loginBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doLogin(_ sender: Any) {
        
        let nickname=AppUtil.trimStr(nicknameView.stringValue)
        if nickname.count<=1{
            AlertViewController.showAlertTop(msg: "请输入花名", sender: loginBtn)
            return
        }
        
        //保存用户
        AppUtil.saveUser(nickname)
        //进入主页面
        let homeContainer =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HomeContainerViewController"))
        NSApp.keyWindow?.contentViewController = (homeContainer as! NSViewController)
    }
}

