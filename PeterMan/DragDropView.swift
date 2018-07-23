//
//  DragDropView.swift
//  PeterMan
//
//  Created by zhangquan on 2018/6/5.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class DragDropView: NSView {
    var dragDelegate:DragDropViewDelegate?
    var targetType:NSPasteboard.PasteboardType=NSPasteboard.PasteboardType.backwardsCompatibleFileURL
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //        NSColor.blue.set()
        //        NSBezierPath.fill(dirtyRect)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
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
}

/// 参考 https://www.colabug.com/2147788.html
extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        return NSPasteboard.PasteboardType("NSFilenamesPboardType")
    }()
}

protocol DragDropViewDelegate:AnyObject{
    func dragEnter()
    func dragExit()
    func dragFinished(filePath:String)
}
