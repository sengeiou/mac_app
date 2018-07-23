//
//  CustomTextView.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/14.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class CustomTextView: NSTextView {
    var dragDelegate:DragDropViewDelegate?
    var targetType:NSPasteboard.PasteboardType=NSPasteboard.PasteboardType.backwardsCompatibleFileURL
    var isCurTextField=false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
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
                    
                    let selRange=self.selectedRange
                    let pos=selRange.location
                    let len=selRange.length
                    if  len>0{ //有选中的文字
                        let fullValue=self.string
                        let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                        let endIndex=fullValue.index(startIndex, offsetBy: len)
                        let selData=fullValue.substring(with: startIndex..<endIndex)
                  
                        pasterboard.clearContents() //在复制前必须
                        pasterboard.setString(selData, forType: targetType)
                    }
                }
                
            } else if key == "v"{ //command+v
                print("key  command+v")
                let pasterboard=NSPasteboard.general
                let types=pasterboard.types;
                let targetType=NSPasteboard.PasteboardType.string
                if (types!.contains(targetType)) {
                    let pasteData=pasterboard.string(forType: targetType)!
                     print("key  isCurTextField=\(isCurTextField)")
                    if isCurTextField && !(pasteData.isEmpty) && self.isEditable{
                        let selRange=self.selectedRange
                        let pos=selRange.location
                        let len=selRange.length
                        let fullValue=self.string
                        if len>0{ //替换选中范围的文字
                            let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                            let endIndex=fullValue.index(startIndex, offsetBy: len)
                            self.string.replaceSubrange(startIndex..<endIndex, with: pasteData)
                        }else{ //在光标初插入文案
                            let startIndex=fullValue.index(fullValue.startIndex, offsetBy: pos)
                            self.string.insert(contentsOf: pasteData, at: startIndex)
                        }
                    }
                }
            } else if key == "a"{ //command +a  当前输入框中的文字全选
                print("key  command+a")
                if isCurTextField{
                    self.selectAll(self) //全选
                    isCurTextField=true
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
//        delegate=self
        //设置padding
        self.textContainerInset=NSSize(width: 2, height: 3)
        
        let types:[NSPasteboard.PasteboardType]=[targetType]
        registerForDraggedTypes(types)
    }
    
    /// 当拖动数据进入view时会触发这个函数
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let board=sender.draggingPasteboard()
        let types=board.types
        if types!.contains(targetType){
            dragDelegate?.dragEnter()
            return NSDragOperation.copy
        }
        return NSDragOperation.every
    }
    override func draggingExited(_ sender: NSDraggingInfo?) {
        dragDelegate?.dragExit()
    }
    /// 当在view中松开鼠标键时会触发
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let board=sender.draggingPasteboard()
        let urlClass = type(of: NSURL());
        let optionsMap:[NSPasteboard.ReadingOptionKey:Bool]=[NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]
        let urlList:[NSURL]=board.readObjects(forClasses: [urlClass], options: optionsMap) as! [NSURL]
        for item in urlList{
            dragDelegate?.dragFinished(filePath: item.path!)
        }
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        let status=super.becomeFirstResponder()
        print("key becomeFirstResponder")
        isCurTextField=true
        return status
    }
    override func controlTextDidEndEditing(_ obj: Notification) {
        print("key controlTextDidEndEditing")
        super.controlTextDidEndEditing(obj)
        isCurTextField=false
    }
}

//extension CustomTextView:NSTextViewDelegate{
//    override func controlTextDidEndEditing(_ obj: Notification) {
//        super.controlTextDidEndEditing(obj)
//         print(" controlTextDidEndEditing")
//        isCurTextField=false
//    }
//}

