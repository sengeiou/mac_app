//
//  SettingViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/4/27.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {
    var appList:[String]=[]
    @IBOutlet weak var optionView: NSComboBox!
    var settingInfo:SettingInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingInfo=AppUtil.getSettingInfo()
        appList = AppUtil.getAppList()
        var sel=appList.index(of:settingInfo!.tool)
        sel = sel!<0 ? 0:sel
        optionView.addItems(withObjectValues: appList)
        optionView.selectItem(at: sel!)
    }
    
    @IBAction func onItemSelected(_ sender: Any) {
        let value:Any?=optionView.objectValueOfSelectedItem
        //        let selIndex=optionView.indexOfSelectedItem
        let curApp = value! as! String
        settingInfo?.tool=curApp
        AppUtil.saveSettingInfo(settingInfo!)
    }
    
}
