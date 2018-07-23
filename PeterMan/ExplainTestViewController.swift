//
//  ExplainTestViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/24.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class ExplainTestViewController: NSViewController {
    @IBOutlet var explainView: CustomTextView!
    @IBOutlet weak var logLineView: CustomTextField!
    @IBOutlet weak var btnRun: NSButton!
    @IBOutlet weak var resultView: CustomTextField!
    var explainInfo:ExplainInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        title="脚本测试"
        btnRun.target=self
        btnRun.action=#selector(doTest(_:))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        let script = CommonUtil.base64Decoding(explainInfo!.script)
        let fileContent=AppUtil.createTestPyFile(name:explainInfo!.name,pattern: explainInfo!.pattern, script: script)
        explainView.string=fileContent
    }
    
    func setData(_ explainInfo:ExplainInfo){
        self.explainInfo=explainInfo
    }
    
    @objc func doTest(_ sender:Any){
        let logLine=logLineView.stringValue
        if AppUtil.trimStr(logLine).isEmpty{
            AlertViewController.showAlertTop(msg: "请输入日志行", sender: sender as! NSView)
            return
        }
        let result = AppUtil.runTestPyFile(logLine:logLine,name:explainInfo!.name)
        var resultStr=""
        if result == nil{
            resultStr="执行失败"
        }else if result!.isEmpty{
            resultStr="无匹配内容"
        }else{
            resultStr=result!
        }
        resultView.stringValue=resultStr
    }
    
}
