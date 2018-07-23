//
//  HomeViewController.swift
//  PeterMan
//
//
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

let RuleCellKey="ruleCellView"
class HomeViewController: NSViewController {
    var appList:[String]=[]
    @IBOutlet weak var ruleTableView: NSTableView! //规则列表
    @IBOutlet weak var logTypeView: NSComboBox! //规则类型
    @IBOutlet weak var indicatorView: NSTableView! //指标
    @IBOutlet weak var labelView: NSTextField! //标签
    @IBOutlet weak var expressView: NSTextField! //表达式
    @IBOutlet weak var tipScrollView: NSScrollView!
    @IBOutlet var tipView: NSTextView!
    
    @IBOutlet weak var supportView: NSImageView! //点赞
    @IBOutlet weak var supportProgressView: NSProgressIndicator!
    @IBOutlet weak var ruleInfoContainer: NSView!
    @IBOutlet weak var supportCountView: NSTextField! //点赞数
    @IBOutlet weak var btnCopy: NSButton! // 拷贝
    @IBOutlet weak var btn_execute: NSButton! // 分析日志
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var btn_filter_all: NSButton!
    @IBOutlet weak var btn_filter_history: NSButton!
    @IBOutlet weak var addRuleBtn: NSImageView!
    @IBOutlet weak var addRuleText: NSTextField!
    @IBOutlet weak var addLogZipBtn: NSImageView!
    @IBOutlet weak var logZipTextView: NSTextField!
    @IBOutlet weak var dragDropView: DragDropView!
    @IBOutlet weak var refreshView: NSImageView!
    @IBOutlet weak var usernameView: NSTextField!
    @IBOutlet weak var explainTableView: NSTableView!
    
    @IBOutlet weak var refreshProgressView: NSProgressIndicator!
    @IBOutlet weak var execLogProgressView: NSProgressIndicator!
    
    var categoryList:[RuleCategory]=[]
    var curRuleCategory:RuleCategory?
    var ruleMap:[Int:[RuleInfo]]?
    var ruleList:[RuleInfo]?  //当前分类的所有列表
    var curRuleList:[RuleInfo]? //当前绑定到tableview上的列表
    var ruleInfo:RuleInfo?
    var ruleSupport:RuleSupport?
    var curSupportInfo:RuleSupportInfo?
    var filterType=0 // 0:全部，1历史
    var searchKeyword="" //搜索关键词
    var logZip=""  //日志包路径
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载数据
        categoryList=AppUtil.getRuleCategorys()
        for ruleCategory in categoryList{
            appList.append(ruleCategory.name)
        }
        ruleMap=AppUtil.getLocalRules()
        
        curRuleCategory=categoryList[0]
        ruleList=getRuleList(cid: curRuleCategory!.id)
        curRuleList=ruleList
        
        //点赞
        ruleSupport=AppUtil.getSupports()
        
        usernameView.stringValue=AppUtil.getUser()!
        // 下拉列表
        logTypeView.addItems(withObjectValues: appList)
        logTypeView.selectItem(at: 0)
        //添加事件
        logTypeView.target=self
        logTypeView.action = #selector( onLogTypeSelected(_:))
        
        
        //自定义view，需要先注册后使用
        let ruleCellNib=NSNib(nibNamed:NSNib.Name(rawValue: "RuleItemCellView"), bundle: nil) //RuleItemCellView.xlb的名字
        ruleTableView.register(ruleCellNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: RuleCellKey))
        ruleTableView.rowHeight=44
        
        let ruleInfoCellNib=NSNib(nibNamed:NSNib.Name(rawValue: "AddRuleCellView"), bundle: nil) //AddRuleCellView.xlb的名字
        indicatorView.register(ruleInfoCellNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey))
        indicatorView.rowHeight=20
        
        let explainInfoCellNib=NSNib(nibNamed:NSNib.Name(rawValue: "AddRuleCellView"), bundle: nil) //AddRuleCellView.xlb的名字
        explainTableView.register(explainInfoCellNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey))
        explainTableView.rowHeight=20
        
        //点赞按钮添加点击事件
        let clickGes=NSClickGestureRecognizer(target: self, action: #selector(doSupport))
        supportView.addGestureRecognizer(clickGes)
        ruleInfoContainer.isHidden=true  //隐藏详情面板
        
        btnCopy.target=self
        btnCopy.action = #selector(copyRuleInfo(_:))
        
        btn_execute.target=self
        btn_execute.action = #selector(execLogTask(_:))
        
        searchField.delegate=self
        
        btn_filter_all.target=self
        btn_filter_all.action = #selector(filterAll(_:))
        
        btn_filter_history.target=self
        btn_filter_history.action = #selector(filterHistory(_:))
        
        let addRuleGes=NSClickGestureRecognizer(target: self, action: #selector(goAddRulepage(_:)))
        addRuleBtn.addGestureRecognizer(addRuleGes)
        let addRuleGes2=NSClickGestureRecognizer(target: self, action: #selector(goAddRulepage(_:)))
        addRuleText.addGestureRecognizer(addRuleGes2)
        
        
        let refreshGes=NSClickGestureRecognizer(target: self, action: #selector(refreshData(_:)))
        refreshView.addGestureRecognizer(refreshGes)
        
        //        let selColor = NSColor(red: 123.0 / 255.0, green: 140.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0).cgColor
        
        dragDropView.dragDelegate=self
        
        if curRuleList!.count > 0{
            ruleInfo = curRuleList![0]
            selectRuleListRow(0)
            updateRuleInfo()
        }
    }
    
    @objc func filterAll(_ sender:NSButton){
        if filterType==0{
            return
        }
        filterType=0
        btn_filter_all.state = .on
        btn_filter_history.state = .off
        refreshRuleListView()
    }
    
    @objc func filterHistory(_ sender:NSButton){
        if filterType==1{
            return
        }
        filterType=1
        btn_filter_all.state = .off
        btn_filter_history.state = .on
        refreshRuleListView()
    }
    
    @objc func refreshData(_ sender:NSImageView){
        refreshProgressView.isHidden=false
        refreshView.isHidden=true
        refreshProgressView.startAnimation(sender)
        
        Thread.detachNewThreadSelector(#selector(doRefreshOnSubThread(_:)), toTarget: self, with: self)
    }
    @objc func doRefreshOnSubThread(_ sender:Any){
        ruleMap=AppUtil.getRules()
        ruleSupport=AppUtil.getSupports()
        ruleList=getRuleList(cid: curRuleCategory!.id)
        self.performSelector(onMainThread: #selector(doRefreshOnMainThread(_:)), with: self, waitUntilDone: false)
    }
    @objc func doRefreshOnMainThread(_ sender:Any){
        refreshRuleListView()
        if curRuleList!.count>0 && ruleInfo != nil{
            for (index,item) in curRuleList!.enumerated(){
                if item.id==ruleInfo!.id{
                    self.ruleInfo=item
                    updateRuleInfo()
                    selectRuleListRow(index)
                    break
                }
            }
        }
        refreshProgressView.stopAnimation(refreshProgressView)
        refreshProgressView.isHidden=true
        refreshView.isHidden=false
    }
    
    @objc func doSupport(){
        if curSupportInfo!.isUserHasSupport(ruleInfo: ruleInfo!){ //如果用户已经点赞 则返回
            return
        }
        supportProgressView.startAnimation(supportProgressView)
        supportProgressView.isHidden=false
        supportView.isHidden=true
        Thread.detachNewThreadSelector(#selector(doSupportOnSubThread(_:)), toTarget: self, with: self)
    }
    
    @objc func doSupportOnSubThread(_ sender:Any){
        //保存
        ruleSupport=AppUtil.saveSupport(ruleInfo: ruleInfo!)
        curSupportInfo=ruleSupport?.getSupport(cid: ruleInfo!.cid, id: ruleInfo!.id)
        self.performSelector(onMainThread: #selector(doSupportOnMainThread(_:)), with: self, waitUntilDone: false)
    }
    @objc func doSupportOnMainThread(_ sender:Any){
        supportProgressView.stopAnimation(supportProgressView)
        supportProgressView.isHidden=true
        supportView.isHidden=false
        //更新UI
        let count = curSupportInfo!.users.count
        supportCountView.stringValue=String(count)
        supportView.image=NSImage(named: NSImage.Name("home_fabulous_sel"))
        supportView.isEnabled = false
        refreshRuleListView()
        
        //选中指定行
        for (index,item) in curRuleList!.enumerated(){
            if item.id == ruleInfo!.id{
                selectRuleListRow(index)
                break
            }
        }
    }
    
    /// 拷贝规则
    @objc func copyRuleInfo(_ sender:NSButton){
        let homeContainerViewController = self.parent;
        (homeContainerViewController as! HomeContainerViewController).copyRule(ruleInfo: ruleInfo!)
    }
    
    @objc func execLogTask(_ sender:NSButton){
        //        logZip="/Users/zhangquan/Workspace/others/logtools/test/test.zip"
        if ruleInfo != nil && logZip != ""{
            btn_execute.isEnabled = false
            btn_execute.title=""
            execLogProgressView.isHidden=false
            execLogProgressView.startAnimation(execLogProgressView)
            Thread.detachNewThreadSelector(#selector(execLogOnSubThread(_:)), toTarget: self, with: self)
        }else{
            AlertViewController.showAlertTop(msg: "请拖入日志包或日志文件夹", sender: sender)
        }
    }
    
    @objc func execLogOnSubThread(_ sender:Any){
        AppUtil.execLogTask(ruleInfo: ruleInfo!, path: logZip)
        self.performSelector(onMainThread: #selector(finishExecLogTask(_:)), with: self, waitUntilDone: false)
    }
    
    @objc func finishExecLogTask(_ sender:Any){
        btn_execute.isEnabled = true
        btn_execute.title="开始分析日志"
        execLogProgressView.isHidden=true
        execLogProgressView.stopAnimation(execLogProgressView)
    }
    
    @objc func onLogTypeSelected(_ sender:NSComboBox){
        //获取选中的item值
        //        let value:Any?=logTypeView.objectValueOfSelectedItem
        //        let curType = value! as! String
        
        let selIndex=logTypeView.indexOfSelectedItem
        if selIndex == -1{
            return
        }
        curRuleCategory=categoryList[selIndex]
        ruleList=getRuleList(cid: curRuleCategory!.id)
        
        refreshRuleListView()
        ruleInfoContainer.isHidden=true  //隐藏详情面板
        
        
        if curRuleList!.count > 0{
            ruleInfo = curRuleList![0]
            selectRuleListRow(0)
            updateRuleInfo()
        }
        
    }
    
    /// 添加规则
    @IBAction func goAddRulepage(_ sender: Any) {
        let homeContainerViewController = self.parent;
        (homeContainerViewController as! HomeContainerViewController).goAddRulePage();
        
    }
    
    func refreshRuleListView(){
        let dataList=ruleList
        if dataList!.isEmpty{
            curRuleList=[]
            ruleTableView.reloadData()
            return
        }
        
        //全部0 or 历史1
        if filterType==1{
            let history=AppUtil.getSettingInfo()?.history
            if history!.isEmpty{ //无历史记录
                curRuleList=[]
                ruleTableView.reloadData()
                return
            }
            curRuleList=[]
            for his in history!{
                for item in dataList!{
                    if item.id == his.id&&item.cid == his.cid{
                        curRuleList!.append(item)
                        break
                    }
                }
            }
            
        }else{
            curRuleList=dataList
        }
        
        if curRuleList!.isEmpty{
            ruleTableView.reloadData()
            return
        }
        
        var searchList:[RuleInfo]=[]
        //搜索关键词
        if searchKeyword.count>0{
            for item in curRuleList!{ //优先按名称搜索
                if item.name.contains(searchKeyword)||item.label.contains(searchKeyword){
                    searchList.append(item)
                }else if item.label.contains(searchKeyword){ //按标签搜索
                    searchList.append(item)
                }else if item.creator.contains(searchKeyword){ //按创建人搜索
                    searchList.append(item)
                }
            }
            
            curRuleList=searchList
        }
        
        ruleTableView.reloadData()
    }
    
    func getRuleList(cid:Int)->[RuleInfo]{
        var ruleList = ruleMap![cid]
        if ruleList==nil{
            ruleList=[]
            ruleMap![cid]=ruleList
        }
        return ruleList!
    }
    
    @objc private func refreshRuleInfoOnSubThread(_ sender:[Any]){
        let ruleInfo=sender[0] as! RuleInfo
        ruleMap = AppUtil.getRules()
        if ruleInfo.cid != curRuleCategory?.id{ //不在当前类型下
            return
        }
        ruleList=getRuleList(cid:ruleInfo.cid)
        self.performSelector(onMainThread: #selector(refreshRuleInfoOnMainThread(_:)), with: sender, waitUntilDone: false)
    }
    
    @objc private func refreshRuleInfoOnMainThread(_ sender:[Any]){
        let ruleInfo=sender[0] as! RuleInfo
        let action=sender[1] as! String
        if action == "del"{
            //            var delIndex = -1
            //            for (index,item) in ruleList!.enumerated(){
            //                if item.id==ruleInfo.id{
            //                    delIndex=index
            //                    break
            //                }
            //            }
            if self.ruleInfo!.id == ruleInfo.id{
                self.ruleInfo = nil
                ruleInfoContainer.isHidden = true  //隐藏详情面板
            }
            //            ruleList!.remove(at: delIndex)
            refreshRuleListView() //刷新列表
            
        }else if action == "update"{
            let id=self.ruleInfo!.id
            refreshRuleListView() //刷新列表
            if id == ruleInfo.id{ //刷新当前规则详情
                self.ruleInfo=ruleInfo
                updateRuleInfo()
                //选中指定行
                for (index,item) in ruleList!.enumerated(){
                    if item.id==ruleInfo.id{
                        selectRuleListRow(index)
                        break
                    }
                }
            }
        }else if action == "add"{
            refreshRuleListView()
            //选中最后一行
            selectRuleListRow(ruleList!.count-1)
            self.ruleInfo=ruleInfo
            updateRuleInfo()
        }
    }
    func  refreshRuleInfo(ruleInfo:RuleInfo,action:String){
        let data:[Any]=[ruleInfo,action]
        Thread.detachNewThreadSelector(#selector(refreshRuleInfoOnSubThread(_:)), toTarget: self, with: data)
    }
    
    func selectRuleListRow(_ rowIndex:Int){
        var indexSet=IndexSet()
        indexSet.insert(rowIndex)
        ruleTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
}
//数据源方法（返回NSTableView有多少行）
extension HomeViewController:NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == ruleTableView{
            return curRuleList!.count
        }else if tableView == indicatorView{
            return ruleInfo==nil ? 0: ruleInfo!.getIndicators().count
        }else if tableView == explainTableView{
            return ruleInfo==nil ? 0: ruleInfo!.explains.count
        }
        return 0
    }
    
}
//代理方法（返回NSTableView每行的view，以及交互）
extension HomeViewController:NSTableViewDelegate{
    //返回每行的view（之前注册的view）
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier=tableColumn?.identifier.rawValue
        if tableView == ruleTableView{
            let cellView=tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: RuleCellKey), owner: nil) as! RuleItemCellView
            let ruleInfo=curRuleList![row]
            if identifier=="name"{
                tableColumn?.title="名称"
                cellView.textView.stringValue=ruleInfo.name
            }else if identifier == "creator"{
                tableColumn?.title="创建人"
                cellView.textView.stringValue=ruleInfo.creator
            }else if identifier == "support"{
                tableColumn?.title="点赞数"
                cellView.textView.stringValue=String(ruleSupport!.getSupport(cid: ruleInfo.cid, id: ruleInfo.id).users.count)
            }
            return cellView
        }else if tableView==indicatorView{
            let  cellView=tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey), owner: nil) as! AddRuleCellView
            let indicatorInfo=ruleInfo?.getIndicators()[row]
            
            if identifier=="name"{
                tableColumn?.title="名称"
                cellView.textView.stringValue=indicatorInfo!.name
            }else if identifier == "express"{
                tableColumn?.title="表达式"
                cellView.textView.stringValue=indicatorInfo!.express
            }
            return cellView
        }else if tableView==explainTableView{
            let  cellView=tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: AddRuleCellKey), owner: nil) as! AddRuleCellView
            let explainInfo=ruleInfo?.explains[row]
            
            if identifier=="name"{
                tableColumn?.title="名称"
                cellView.textView.stringValue=explainInfo!.name
            }else if identifier == "express"{
                tableColumn?.title="表达式"
                cellView.textView.stringValue=explainInfo!.pattern
            }
            return cellView
        }
        return nil
        
    }
    
    
    //item点击事件 获取选中的view
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow=ruleTableView.selectedRow
        if selectedRow<0{
            return 
        }
        //        let selectedColumn=ruleTableView.selectedColumn
        //        //获取指定cell的view
        //        let selectedView=ruleTableView.view(atColumn: selectedColumn, row: selectedRow, makeIfNecessary: true) as! RuleItemCellView
        //        let value=selectedView.textView.stringValue
        
        ruleInfo=ruleList?[selectedRow]
        updateRuleInfo();
    }
    
    
    /// 更新详情
    func updateRuleInfo(){
        indicatorView.reloadData()
        explainTableView.reloadData()
        labelView.stringValue=ruleInfo!.getLabels()
        expressView.stringValue=ruleInfo!.express
        tipView.string=ruleInfo!.getTipInfo()
        ruleInfoContainer.isHidden=false
        if ruleInfo!.creator == AppUtil.getUser()!{
            btnCopy.title="编辑"
        }else{
            btnCopy.title="拷贝"
        }
        
        curSupportInfo = ruleSupport!.getSupport(cid: ruleInfo!.cid, id: ruleInfo!.id)
        supportCountView.stringValue=String(curSupportInfo!.users.count)
        let isSupport=curSupportInfo!.isUserHasSupport(ruleInfo:ruleInfo!)
        if isSupport{
            supportView.image=NSImage(named: NSImage.Name("home_fabulous_sel"))
            supportView.isEnabled = false
            
        }else{
            supportView.image=NSImage(named: NSImage.Name("home_fabulous"))
            supportView.isEnabled = true
        }
    }
}

extension HomeViewController:NSSearchFieldDelegate{
    /// 搜索框中开始有内容
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        //        print("searchFieldDidStartSearching")
    }
    /// 点击x 清空搜索框中的内容
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        //         print("searchFieldDidEndSearching \(sender.stringValue)")
        
    }
    /// 开始编辑
    override func controlTextDidBeginEditing(_ obj: Notification) {
        //        print("开始编辑")
    }
    /// 文本改变回调  当内容被清空时 也会回调
    override func controlTextDidChange(_ obj: Notification) {
        //         print("文本改变 \(searchField.stringValue)")
        searchKeyword=searchField.stringValue
        refreshRuleListView()
        
    }
    /// 结束编辑
    override func controlTextDidEndEditing(_ obj: Notification) {
        //         print("结束编辑")
    }
}


var logZipText=""
extension HomeViewController:DragDropViewDelegate{
    func dragEnter() {
        print("dragEnter")
        logZipText=logZipTextView.stringValue
        logZipTextView.stringValue="松开手"
    }
    func dragExit() {
        print("dragExit")
        logZipTextView.stringValue=logZipText
    }
    func dragFinished(filePath: String) {
        //校验必须是文件夹或zip文件
        logZipTextView.stringValue=filePath
        logZip=filePath
    }
}
