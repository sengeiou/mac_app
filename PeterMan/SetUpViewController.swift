//
//  SetUpViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/20.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class SetUpViewController: NSViewController {
    @IBOutlet weak var btn_setup: NSButton!
    @IBOutlet weak var loadingTextView: NSTextField!
    @IBOutlet weak var progressView: NSProgressIndicator!
    
    weak var windowDelegate:AppWindowControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_setup.target=self
        btn_setup.action=#selector(setup(_:))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        progressView.startAnimation(progressView)
        Thread.detachNewThreadSelector(#selector(doRefreshOnSubThread(_:)), toTarget: self, with: self)
    }
    @objc func setup(_ sender:NSButton){
        loadingTextView.stringValue="加载数据中，请稍等..."
        progressView.isHidden=false
        progressView.startAnimation(progressView)
//        sender.isHidden=true
        sender.isEnabled=false
        Thread.detachNewThreadSelector(#selector(doRefreshOnSubThread(_:)), toTarget: self, with: self)
    }
    
    @objc func doRefreshOnSubThread(_ sender:Any){
        let isSuccessful = AppUtil.isSetup()
        if isSuccessful{ //安装成功则更新数据
            AppUtil.update()
        }else{  //安装
            AppUtil.setUp()
        }
//        let pattern="社交sdk加载状态变更(\\d\\d\\d\\d\\d)"
//        let script="sdk加载状态："
//        AppUtil.createTestPyFile(name:"测试",pattern: pattern, script: script)
          self.performSelector(onMainThread: #selector(doRefreshOnMainThread(_:)), with: self, waitUntilDone: false)
    }
    @objc func doRefreshOnMainThread(_ sender:Any){
        let isSuccessful = AppUtil.isSetup()
        if isSuccessful{
            windowDelegate!.setUpCallbackSuccess()
        }else{
            loadingTextView.stringValue="数据加载失败，请检查网络"
            btn_setup.isHidden=false
            btn_setup.isEnabled=true
            progressView.isHidden=true
            progressView.stopAnimation(progressView)
        }
    }
    
}
