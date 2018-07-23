//
//  AddIndicatorsViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/27.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AddIndicatorsViewController: NSViewController {
    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var operatorView: NSComboBox!
    @IBOutlet weak var expressView: NSTextField!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnContainer_save: NSButton!
    @IBOutlet weak var btnContainer_del: NSButton!
    @IBOutlet weak var btnContainer: NSView!
    
    weak var delegate:AddRuleViewControllerDelegate?
    
    var operationList:[String]=[]
    var indicatorInfo:IndicatorInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operationList=AppUtil.getOperations()
        operatorView.addItems(withObjectValues: operationList)
        operatorView.selectItem(at: 0)
        //添加事件
        operatorView.target=self
        operatorView.action = #selector( onOperationSelected(_:))
        
        btnSave.target=self
        btnSave.action=#selector( update(_:))
        
        btnContainer_save.target=self
        btnContainer_save.action=#selector( update(_:))
        
        btnContainer_del.target=self
        btnContainer_del.action=#selector( delete(_:))
        
        btnContainer_del.target=self
        btnContainer_del.action=#selector( delete(_:))
        
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if indicatorInfo != nil{ //更新
            btnContainer_save.isHidden=false
            btnContainer_del.isHidden=false
            
            nameView.stringValue=indicatorInfo!.name
            operatorView.stringValue=indicatorInfo!.operation
            expressView.stringValue=indicatorInfo!.express
        }else{  //新增
            btnSave.isHidden=false
            operatorView.selectItem(at: 0)
        }
        
    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        reset()
    }
    
    @objc func onOperationSelected(_ sender:AnyObject){
        //        let value:Any?=operatorView.objectValueOfSelectedItem
        //        let selIndex=optionView.indexOfSelectedItem
        //        indicatorInfo!.operation=value! as! String
    }
    
    func initData(indicatorInfo:IndicatorInfo){
        self.indicatorInfo=indicatorInfo
    }
    
    @objc func update(_ sender:NSButton){
        
        let name = AppUtil.trimStr(nameView.stringValue)
        if name==""{
            return
        }
        let operation = AppUtil.trimStr(operatorView.stringValue)
        if operation == ""{
            return
        }
        if AppUtil.trimStr(expressView.stringValue) == ""{
            return
        }
        
        var action="update"
        if indicatorInfo == nil{
            indicatorInfo = IndicatorInfo()
            action="add"
        }
        indicatorInfo!.name=name
        indicatorInfo!.operation=operation
        indicatorInfo!.express=expressView.stringValue
        self.delegate!.addIndicatorCallback(indicatiorInfo: indicatorInfo!, action:action)
        dismiss(self)
    }
    
    @objc func delete(_ sender:NSButton){
        self.delegate!.addIndicatorCallback(indicatiorInfo: indicatorInfo!, action:"del")
        dismiss(self)
    }
    
    func reset(){
        self.delegate=nil
        self.indicatorInfo=nil
        
        nameView.stringValue=""
        operatorView.stringValue=""
        expressView.stringValue=""
        btnSave.isHidden=true
        btnContainer_save.isHidden=true
        btnContainer_del.isHidden=true
        
    }
}
