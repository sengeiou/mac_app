//
//  ExplainViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/14.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class ExplainViewController: NSViewController {
    @IBOutlet var textView: CustomTextView!
    @IBOutlet weak var patternView: CustomTextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var btnContainer_del: NSButton!
    @IBOutlet weak var btnContainer_save: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var helpView: NSButton!
    
    @IBOutlet weak var btnTest: NSButton!
    weak var explainDelegate:AddRuleViewControllerDelegate?
    var explainInfo:ExplainInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        title="日志解释"
//        self.view.wantsLayer=true
//        self.view.layer!.backgroundColor = NSColor.white.cgColor
        
        textView.dragDelegate=self
        btnSave.target=self
        btnSave.action=#selector( update(_:))

        btnContainer_save.target=self
        btnContainer_save.action=#selector( update(_:))

        btnContainer_del.target=self
        btnContainer_del.action=#selector( delete(_:))
        
        btnTest.target=self
        btnTest.action=#selector( goTestPage(_:))
        
        helpView.target=self
        helpView.action=#selector(showHelpPage(_:))
        
        
//        nameView.stringValue="社交sdk加载状态"
//        patternView.stringValue="社交sdk加载状态变更(\\d\\d\\d\\d\\d)"
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        if explainInfo != nil{ //更新
            btnContainer_save.isHidden=false
            btnContainer_del.isHidden=false
            nameView.stringValue=explainInfo!.name
            patternView.stringValue=explainInfo!.pattern
            textView.string=CommonUtil.base64Decoding(explainInfo!.script)
        }else{ //新增
            btnSave.isHidden=false
        }

    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        reset()
    }

    func initData(_ explainInfo:ExplainInfo){
        self.explainInfo=explainInfo
    }

    func createExplainInfo(_ sender:NSButton)->ExplainInfo?{
        if AppUtil.trimStr(nameView.stringValue).isEmpty{
            AlertViewController.showAlertTop(msg: "名称不能为空", sender: sender)
            return nil
        }
        if AppUtil.trimStr(patternView.stringValue).isEmpty{
            AlertViewController.showAlertTop(msg: "pattern不能为空", sender: sender)
            return nil
        }
        
        if AppUtil.trimStr(textView.string).isEmpty{
            AlertViewController.showAlertTop(msg: "解析脚本不能为空", sender: sender)
            return nil
        }
        
        let explainInfo=ExplainInfo()
        explainInfo.name=nameView.stringValue
        explainInfo.pattern=patternView.stringValue
        
        let script = textView.string
        var scriptInfo=""
        let splitedArray=script.split(separator: "\n")
        for item in splitedArray{
            let line = item.trimmingCharacters(in: .whitespaces) //去掉前后的空格
            scriptInfo+=line+"\n"
        }
        explainInfo.script=CommonUtil.base64Encoding(scriptInfo)
        return explainInfo
        
    }
    @objc func update(_ sender:NSButton){
   
        let info = createExplainInfo(sender)
        if info == nil{
            return
        }
        var action="update"
        if explainInfo == nil{
            action="add"
            explainInfo=info
        }else{
            explainInfo!.name=info!.name
            explainInfo!.pattern=info!.pattern
            explainInfo!.script=info!.script
        }
        self.explainDelegate?.addExplainCallback(explainInfo:explainInfo!, action: action)
        dismiss(self)
    }

    @objc func delete(_ sender:NSButton){
        self.explainDelegate?.addExplainCallback(explainInfo: explainInfo!, action: "del")
        dismiss(self)
    }
    
    
    @objc func goTestPage(_ sender:NSButton){
        let info = createExplainInfo(sender)
        if info == nil{
            return
        }
        let explainTestVC = ExplainTestViewController()
        explainTestVC.setData(info!)
        presentViewControllerAsModalWindow(explainTestVC)
    }
    
    @objc func showHelpPage(_ sender:NSButton){
        let popver = NSPopover()
        let contentController = ExplainHelpViewController()
        popver.contentViewController=contentController
        
        popver.behavior = .transient //点击其他区域 关闭popwindow
        popver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxX)
    }
    
    func reset(){
       
        self.explainDelegate=nil
        self.explainInfo=nil

        nameView.stringValue = ""
        patternView.stringValue = ""
        textView.string=""
        btnContainer_save.isHidden=true
        btnContainer_del.isHidden=true
        btnSave.isHidden=true

    }
}

extension ExplainViewController:DragDropViewDelegate{
    func dragEnter() {

    }
    func dragExit() {

    }
    func dragFinished(filePath: String) {
        //校验必须是文件夹或zip文件
        print("dragFinished")
        if !filePath.isEmpty && filePath.hasSuffix(".py"){
            let contet=AppUtil.readFileContent(filePath)
            if contet != nil && !contet!.isEmpty{
                textView.string=contet!
            }
        }else{

            AlertViewController.showAlertTop(msg: "请拖入python脚本文件", sender: btnSave)
        }
    }
}
