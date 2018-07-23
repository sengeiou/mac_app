//
//  AlertViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/10.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AlertViewController: NSViewController {
    @IBOutlet weak var alertMsgView: NSTextField!
    
    var alertMsg:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertMsgView.stringValue=alertMsg
    }
    
    func setAlertMsg(_ msg:String){
        self.alertMsg=msg
    }
    
    class func showAlertTop(msg:String,sender:NSView){
        let popver = NSPopover()
        let contentController = AlertViewController()
        contentController.setAlertMsg(msg)
        popver.contentViewController=contentController
        
        popver.behavior = .transient //点击其他区域 关闭popwindow
        popver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
    class func showAlertRight(msg:String,sender:NSView){
        let popver = NSPopover()
        let contentController = AlertViewController()
        contentController.setAlertMsg(msg)
        popver.contentViewController=contentController
        popver.behavior = .transient //点击其他区域 关闭popwindow
        popver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxX)
    }
    class func showAlertBottom(msg:String,sender:NSView){
        let popver = NSPopover()
        let contentController = AlertViewController()
        contentController.setAlertMsg(msg)
        popver.contentViewController=contentController
        popver.behavior = .transient //点击其他区域 关闭popwindow
        popver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
    }
    
}
