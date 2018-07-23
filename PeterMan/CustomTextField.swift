//
//  CustomTextField.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/13.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class CustomTextField: NSTextField {
    var isCurTextField=false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//         delegate=self
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let action=event.modifierFlags.rawValue&NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
        if action == NSEvent.ModifierFlags.command.rawValue{
            let key=event.charactersIgnoringModifiers
            if key == "c"{ //command+c
                print("key  command+c")
                let pasterboard=NSPasteboard.general
                let types=pasterboard.types;
                let targetType=NSPasteboard.PasteboardType.string
                if (types!.contains(targetType)) {
                    // s 就是剪切板里的字符串, 如果你拷贝的是一个或多个的文件,文件夹, 这里就是文件或文件夹的名称
                    let selRange=self.currentEditor()?.selectedRange
                    if selRange != nil{
                        let pos=selRange!.location
                        let len=selRange!.length
                        if len>0{ //有选中的文字
                            let fullValue=self.stringValue
                            let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                            let endIndex=fullValue.index(startIndex, offsetBy: len)
                            let selData=fullValue.substring(with: startIndex..<endIndex)
        
                            pasterboard.clearContents() //在复制前必须
                            pasterboard.setString(selData, forType: targetType)
                        }
                    }
                    
          
                }
                
            } else if key == "v"{ //command+v
                print("key  command+v")
                let pasterboard=NSPasteboard.general
                let types=pasterboard.types;
                let targetType=NSPasteboard.PasteboardType.string
                if (types!.contains(targetType)) {
                    let pasteData=pasterboard.string(forType: targetType)!
                    if isCurTextField && !(pasteData.isEmpty) && self.currentEditor()!.isEditable{
                        let selRange=self.currentEditor()?.selectedRange
                        if selRange != nil{
                            let pos=selRange!.location
                            let len=selRange!.length
                               let fullValue=self.stringValue
                            if len>0{ //替换选中范围的文字
                                let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                                let endIndex=fullValue.index(startIndex, offsetBy: len)
                                self.stringValue.replaceSubrange(startIndex..<endIndex, with: pasteData)
                            }else{ //在光标初插入文案
                                let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                                self.stringValue.insert(contentsOf: pasteData, at: startIndex)
                            }
                        }else{
                          self.stringValue=pasteData
                        }
                    }
                }
            } else if key == "a"{ //command +a  当前输入框中的文字全选
                print("key  command+a")
                let selRange=self.currentEditor()?.selectedRange
                if isCurTextField || selRange != nil{
                    self.selectText(nil)
                    isCurTextField=true
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    
    override func becomeFirstResponder() -> Bool {
        let status=super.becomeFirstResponder()
        isCurTextField=true
        return status
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        isCurTextField=false
    }
}

//extension CustomTextField:NSTextFieldDelegate{
//    //    override func textDidBeginEditing(_ notification: Notification) {
//    //        isCurTextField=true
//    //    }
//    //    override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
//    //        isCurTextField=true
//    //        return true
//    //    }
//    override func textDidEndEditing(_ notification: Notification) {
//        super.textDidEndEditing(notification)
//        isCurTextField=false
//    }
//
//
//}


