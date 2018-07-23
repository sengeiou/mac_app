//
//  AddRuleViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/4/27.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa
let AddRuleCellKey="addRuleCellView"
class AddRuleViewController: NSViewController {
    var appList:[String]=[]
    @IBOutlet weak var logTypeView: NSComboBox!
    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var labelContainerView: NSView!
    @IBOutlet weak var expressView: NSTextField!
    @IBOutlet weak var indicatorView: NSTableView!
    @IBOutlet var tipView: CustomTextView!
    @IBOutlet weak var btn_save: NSButton!
    @IBOutlet weak var btn_del: NSButton!
    @IBOutlet weak var btn_explain: NSButton!
    @IBOutlet weak var addLabelView: NSButton!
    @IBOutlet weak var explainTableView: NSTableView!
    
    var labelViews:[NSView]=[]
    
    var addLabelVC:AddLabelViewController?
    var indicatorVC:AddIndicatorsViewController?
    var explainVC:ExplainViewController?
    @IBOutlet weak var progressView: NSProgressIndicator!
    
    var catetoryList:[RuleCategory]=[]
    var curRuleCategory:RuleCategory?
    var ruleInfo:RuleInfo?
    var indicator:Indicator = Indicator()
    var explains:[ExplainInfo]=[]
    var explainInfo:String?
    var lables:[String] = []
    var updateInfo:Bool=false
    var labelStyle:NSButton.BezelStyle?
    var labelHeight:CGFloat?
    var action:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载数据
        catetoryList=AppUtil.getRuleCategorys()
        for ruleCategory in catetoryList{
            appList.append(ruleCategory.name)
        }
        curRuleCategory=catetoryList[0]
        
        // 下拉列表
        logTypeView.addItems(withObjectValues: appList)
        logTypeView.selectItem(at: 0)
        //添加事件
        logTypeView.target=self
        logTypeView.action = #selector( onLogTypeSelected(_:))
        
        labelViews.append(addLabelView)
        labelStyle=addLabelView.bezelStyle
        labelHeight=addLabelView.frame.height
        
        if ruleInfo == nil{ //新建规则
            ruleInfo=RuleInfo()
        }else{ //拷贝规则
            if ruleInfo!.creator==AppUtil.getUser()!{ //编辑自己的规则
                updateInfo=true
            }else{ //其他用户拷贝的规则
                ruleInfo=AppUtil.copyRuleInfo(ruleInfo!)
                ruleInfo!.name=ruleInfo!.name+"(拷贝)"
                
            }
            nameView.stringValue=ruleInfo!.name
            expressView.stringValue=ruleInfo!.express
            indicator = ruleInfo!.indicators
            tipView.string = indicator.tip
            
            //日志解释
            explains=ruleInfo!.explains
         
            //标签
            lables=ruleInfo!.label
            if lables.count>0{
                addLabels()
            }
            //            if ruleInfo!.creator == AppUtil.getUser()! { //如果当前规则是用户自己创建的
            //                btn_del.isHidden=false
            //            }
        }
        
        //自定义view，需要先注册后使用
        let ruleCellNib=NSNib(nibNamed:NSNib.Name(rawValue: "AddRuleCellView"), bundle: nil) //AddRuleCellView.xlb的名字
        indicatorView.register(ruleCellNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey))
        indicatorView.rowHeight=20
        
        let explainCellNib=NSNib(nibNamed:NSNib.Name(rawValue: "AddRuleCellView"), bundle: nil) //AddRuleCellView.xlb的名字
        explainTableView.register(explainCellNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey))
        explainTableView.rowHeight=20
        
        btn_save.target=self
        btn_save.action = #selector( doSaveRule(_:))
        
        btn_del.target=self
        btn_del.action = #selector( doDeleteRule(_:))
        
        btn_explain.target=self
        btn_explain.action = #selector(addExplain(_:))
        
        addLabelView.target = self
        addLabelView.action =  #selector( addLabelView(_:))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    func  setRuleInfo(ruleInfo:RuleInfo){
        //setRuleInfo - viewDidLoad - viewWillAppear
        self.ruleInfo=ruleInfo
    }
    
    /// 选择类型
    @objc func onLogTypeSelected(_ sender:NSComboBox){
        let selIndex=logTypeView.indexOfSelectedItem
        curRuleCategory=catetoryList[selIndex]
    }
    /// 返回
    @IBAction func goBack(_ sender: Any) {
        let homeContainerViewController = self.parent;
        (homeContainerViewController as! HomeContainerViewController).backFromRulePage();
    }
    
    
    /// 添加标签
    @IBAction func addLabelView(_ sender: NSButton) {
        if addLabelVC == nil{
            addLabelVC=AddLabelViewController()
        }
        addLabelVC?.delegate=self
        presentViewController(addLabelVC!, asPopoverRelativeTo: sender.bounds, of: sender, preferredEdge: .maxX, behavior: .semitransient)
        
    }
    
    @objc func updateLabelView(_ sender: NSButton){
        if addLabelVC == nil{
            addLabelVC=AddLabelViewController()
        }
        addLabelVC?.delegate=self
        addLabelVC?.initData(sender.title)
        presentViewController(addLabelVC!, asPopoverRelativeTo: sender.bounds, of: sender, preferredEdge: .maxX, behavior: .semitransient)
    }
    
    
    /// 添加规则
    @objc func doSaveRule(_ sender:NSButton){
        
        action = updateInfo ? "update":"add"
        
        //名称
        if AppUtil.trimStr(nameView.stringValue) == ""{
            AlertViewController.showAlertRight(msg: "名称不能为空", sender: nameView)
            return;
        }
        
        //表达式
        if  AppUtil.trimStr(expressView.stringValue) == ""{
            AlertViewController.showAlertRight(msg: "表达式不能为空", sender: expressView)
            return
        }
        
        
        //标签
        if lables.count==0{
            AlertViewController.showAlertRight(msg: "请添加标签", sender: labelViews[labelViews.count-1])
            return
        }
        
        
        //自定义文案
        if indicator.list.count > 0{
            if AppUtil.trimStr(tipView.string) == ""{
                AlertViewController.showAlertRight(msg: "自定义文案不能为空", sender: tipView)
                return
            }
            indicator.tip=tipView.string
            ruleInfo!.indicators=indicator
        }
        
        //日志解释
        ruleInfo!.explains=explains
        
        ruleInfo!.express=expressView.stringValue
        ruleInfo!.name=nameView.stringValue
        ruleInfo!.label=lables
        
        //保存文件
        progressView.isHidden=false
        progressView.startAnimation(progressView)
        btn_save.title=""
        btn_save.isEnabled=false
        Thread.detachNewThreadSelector(#selector(saveRule(_:)), toTarget: self, with: ruleInfo)
    }
    
    /// 在子线程中保存
    @objc func saveRule(_ sender:Any){
        //分类id
        let categoryId = curRuleCategory!.id
        ruleInfo!.cid=categoryId
        
        let ruleMap:[Int:[RuleInfo]]=AppUtil.getRules()!
        var ruleList=ruleMap[categoryId]
        if ruleList == nil{
            ruleList=[]
        }
        if action=="add"{
            //生成id
            if ruleList!.count==0{
                ruleInfo!.id=1
            }else{
                var id=0
                for item in ruleList!{
                    id=id < item.id ? item.id:id
                }
                ruleInfo!.id=id+1
            }
            //创建人
            ruleInfo!.creator=AppUtil.getUser()!
            //创建时间
            ruleInfo!.createTime=Date().currentTimeMillis
        }
        
        AppUtil.doSaveRuleInfo(ruleInfo!)
        self.performSelector(onMainThread: #selector(goBackWithUpdateInfo(_:)), with: ruleInfo, waitUntilDone: false)
    }
    /// 在主线程跳转
    @objc func goBackWithUpdateInfo(_ sender:Any){
        progressView.isHidden=true
        progressView.stopAnimation(progressView)
        btn_save.title="保存"
        btn_save.isEnabled=true
        (self.parent as! HomeContainerViewController).updateRuleInfo(ruleInfo: ruleInfo!, action: action)
    }
    
    /// 删除规则
    @objc func doDeleteRule(_ sender:NSButton){
        let action = "del"
        let homeContainerViewController = self.parent;
        (homeContainerViewController as! HomeContainerViewController).updateRuleInfo(ruleInfo: ruleInfo!, action: action)
    }
    
    /// 添加指标
    @IBAction func addIndicator(_ sender: NSButton) {
        openIndicatorVC(indicatorInfo: nil, isEdit: false, target: sender)
    }
    
    func openIndicatorVC(indicatorInfo:IndicatorInfo?,isEdit:Bool,target:NSView){
        if indicatorVC == nil{
            indicatorVC=AddIndicatorsViewController()
        }
        indicatorVC!.delegate=self
        if indicatorInfo != nil{
            indicatorVC!.initData(indicatorInfo: indicatorInfo!)
        }
        presentViewController(indicatorVC!, asPopoverRelativeTo: target.bounds, of: target, preferredEdge: .maxX, behavior: .semitransient)
    }
    
    /// 添加解释
    @objc @IBAction func addExplain(_ sender: NSButton) {
        openExplainVC(explainInfo: nil, isEdit: false, target: sender)
    }
    
    func openExplainVC(explainInfo:ExplainInfo?,isEdit:Bool,target:NSView){
        if explainVC == nil{
            explainVC = ExplainViewController()
        }
        
        explainVC!.explainDelegate=self
        if explainInfo != nil{
            explainVC?.initData(explainInfo!)
        }
        presentViewControllerAsModalWindow(explainVC!)
    }
    
    
    /// 添加标签
    func addLabels(){
        for childView in labelViews{
            childView.removeFromSuperview()
        }
        labelViews=[]
        
        let count = lables.count-1
        let height=labelHeight
        var x:CGFloat = -5;
        let y:CGFloat=0
        let padding:CGFloat=30
        let marginLeft:CGFloat=0
        let addLabelViewWidth:CGFloat=65
        for index in 0...count{
            let label=lables[index]
            let width: CGFloat = label.ga_widthForComment(fontSize: 14) + padding
            if index>0{
                x+=marginLeft
            }
            let textField=NSButton()
            textField.bezelStyle = labelStyle!
            textField.setButtonType(.momentaryPushIn)
            textField.bezelStyle = .rounded
            textField.frame=NSMakeRect(x, y, width, height!)
            textField.title=label
            //                textField.isBordered=false
            //                textField.isEditable=false
            //                textField.isSelectable=false
            textField.alignment = .center
            labelContainerView.addSubview(textField)
            textField.target=self
            textField.action = #selector(updateLabelView(_:))
            labelViews.append(textField)
            x+=width
        }
        
        if lables.count<5{ //最多5个标签
            let textField=NSButton()
            textField.bezelStyle = labelStyle!
            textField.setButtonType(.momentaryPushIn)
            textField.bezelStyle = .rounded
            textField.frame=NSMakeRect(x, y, addLabelViewWidth, height!)
            textField.title="+"
            textField.alignment = .center
            labelContainerView.addSubview(textField)
            labelViews.append(textField)
            
            textField.target=self
            textField.action = #selector(addLabelView(_:))
        }
    }
}


//数据源方法（返回NSTableView有多少行）
extension AddRuleViewController:NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == indicatorView{
            return indicator.list.count
        }else if tableView == explainTableView{
            return explains.count
        }
        return 0
    }
}

//代理方法（返回NSTableView每行的view，以及交互）
extension AddRuleViewController:NSTableViewDelegate{
    //返回每行的view（之前注册的view）
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView=tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey), owner: nil) as! AddRuleCellView
        let identifier=tableColumn?.identifier.rawValue
        if tableView==indicatorView{
            let indicatorInfo=indicator.list[row]
            if identifier=="name"{
                tableColumn?.title="名称"
                cellView.textView.stringValue=indicatorInfo.name
            }else if identifier == "operator"{
                tableColumn?.title="操作符"
                cellView.textView.stringValue=indicatorInfo.operation
            }else if identifier == "express"{
                tableColumn?.title="表达式"
                cellView.textView.stringValue=indicatorInfo.express
            }
            
        } else if tableView==explainTableView{
            let explainInfo=explains[row]
            if identifier=="name"{
                tableColumn?.title="名称"
                cellView.textView.stringValue=explainInfo.name
            }else if identifier == "express"{
                tableColumn?.title="表达式"
                cellView.textView.stringValue=explainInfo.pattern
            }
            
        }
        return cellView
    }
    
    
    //item点击事件 获取选中的view
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        //                let selectedColumn=ruleTableView.selectedColumn
        //                //获取指定cell的view
        //                let selectedView=ruleTableView.view(atColumn: selectedColumn, row: selectedRow, makeIfNecessary: true) as! RuleItemCellView
        //                let value=selectedView.textView.stringValue
        
        let tableView=notification.object as! NSTableView
        let selectedRow=tableView.selectedRow
        let selectedColumn=tableView.selectedColumn
        if selectedRow<0{
            return
        }
        
        let selectedView=tableView.view(atColumn: selectedColumn, row: selectedRow, makeIfNecessary: true) as! AddRuleCellView
        if tableView == indicatorView{
            let indicatorInfo=ruleInfo!.indicators.list[selectedRow]
            openIndicatorVC(indicatorInfo: indicatorInfo, isEdit: true, target: selectedView)
        }else if tableView == explainTableView{
            let explainInfo=explains[selectedRow]
            openExplainVC(explainInfo:explainInfo, isEdit: true, target: selectedView)
        }
    }
    
}

extension AddRuleViewController:AddRuleViewControllerDelegate{
    /// 添加标签回调
    func addLabelCallback(old:String,label:String,action:String){
        if action == "del"{ //删除指标
            let itemIndex = lables.index(of: old)
            lables.remove(at: itemIndex!)
        }else if action == "update"{
            let itemIndex = lables.index(of: old)
            lables[itemIndex!]=label
        }else{
            lables.append(label)
        }
        
        addLabels()
    }
    
    
    /// 添加指标
    func addIndicatorCallback(indicatiorInfo:IndicatorInfo,action:String){
        var indicatorArray=indicator.list
        if action == "del"{ //删除指标
            var itemIndex = -1
            for (index,item) in indicatorArray.enumerated() {
                if item.name==indicatiorInfo.name&&item.express==indicatiorInfo.express{
                    itemIndex=index
                    break
                }
            }
            indicatorArray.remove(at: itemIndex)
        }else if action == "add"{
            //新增
            indicatorArray.append(indicatiorInfo)
            
        }
        indicator.list=indicatorArray
        indicatorView.reloadData()
    }
    
    func addExplainCallback(explainInfo: ExplainInfo, action: String) {
        
        var explainArray=explains
        if action == "del"{ //删除指标
            var itemIndex = -1
            for (index,item) in explainArray.enumerated() {
                if item.name==explainInfo.name&&item.pattern==explainInfo.pattern{
                    itemIndex=index
                    break
                }
            }
            explainArray.remove(at: itemIndex)
        }else if action == "add"{
            //新增
            explainArray.append(explainInfo)
            
        }
        self.explains=explainArray
        explainTableView.reloadData()
    }
}

/// 添加规则页面代理 其他页面回调
protocol AddRuleViewControllerDelegate:AnyObject{
    
    /// 添加指标回调
    ///
    /// - Parameters:
    ///   - indicatiorInfo: 指标
    ///   - action: add 添加；update：更新；del：删除
    func addIndicatorCallback(indicatiorInfo:IndicatorInfo,action:String)
    
    /// 添加注释回调
    ///
    /// - Parameters:
    ///   - explainInfo: 日志解释
    ///   - action: add 添加；update：更新；del：删除
    func addExplainCallback(explainInfo:ExplainInfo,action:String)
    
    /// 添加标签回调
    ///
    /// - Parameter label: 标签
    func addLabelCallback(old:String,label:String,action:String)
}

extension String {
    func ga_widthForComment(fontSize: CGFloat, height: CGFloat = 32) -> CGFloat {
        let font = NSFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedStringKey: font], context: nil)
        return ceil(rect.width)
    }
}
