//
//  AppDelegate.swift
//  PeterMan
//
//  Created by zhangquan on 2018/4/26.
//  Copyright © 2018年 socialteam. All rights reserved.
//
import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowNum=0
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        guard let win=NSApp.mainWindow else { //如果mainWindow为空 就返回
            return
        }
        windowNum = win.windowNumber
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    //        NSApp.terminate(nil) //关闭应用
    //点击dock 需要显示的窗口
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag{ //窗口已经可见 直接返回
            return false
        }
        //获取到app的窗口
        let win = NSApp.window(withWindowNumber: windowNum)
        //显示窗口
        win?.makeKeyAndOrderFront(nil)
        return true
    }
}

