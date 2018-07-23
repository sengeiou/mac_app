//
//  AddLabelViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/27.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AddLabelViewController: NSViewController {
    @IBOutlet weak var btnContainer_del: NSButton!
    @IBOutlet weak var btnContainer_save: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    
    
    @IBOutlet weak var labelView: NSTextField!
    weak var delegate:AddRuleViewControllerDelegate?
    var label:String=""
    var action="add"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.target=self
        btnSave.action=#selector( update(_:))
        
        btnContainer_save.target=self
        btnContainer_save.action=#selector( update(_:))
        
        btnContainer_del.target=self
        btnContainer_del.action=#selector( delete(_:))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if !label.isEmpty{
            btnContainer_save.isHidden=false
            btnContainer_del.isHidden=false
            labelView!.stringValue=label
        }else{
            btnSave.isHidden=false
        }
        
    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        reset()
    }
    
    func initData(_ label:String){
        self.label=label
        action="update"
    }
    
    @objc func update(_ sender:NSButton){
        let labelContent=AppUtil.trimStr(labelView.stringValue)
        if labelContent == ""{
            AlertViewController.showAlertTop(msg: "标签为空", sender: sender)
            return
        }
        
        if labelContent.count<2{
            AlertViewController.showAlertTop(msg: "标签文字必须2个字符以上", sender: sender)
            return
        }
        self.delegate?.addLabelCallback(old:label,label:labelContent, action: action)
        dismiss(self)
    }
    
    @objc func delete(_ sender:NSButton){
        self.delegate?.addLabelCallback(old:label,label:label, action: "del")
        dismiss(self)
    }
    
    func reset(){
        self.action="add"
        self.delegate=nil
        self.label=""
        
        labelView.stringValue=""
        btnContainer_save.isHidden=true
        btnContainer_del.isHidden=true
        btnSave.isHidden=true
        
    }
}
