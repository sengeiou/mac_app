//
//  HomeContainerViewController.swift
//  PeterMan
//
//  Created by zhangquan on 2018/4/27.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class HomeContainerViewController: NSViewController {
    
    @IBOutlet var leftBarView : NSView?
    
    @IBOutlet weak var homeItemButton: NSButton!
    @IBOutlet weak var settingItemButton: NSButton!
    @IBOutlet weak var helpItemButton: NSButton!
    
    var _homePageShowed : Bool?
    var _settingPageShowed : Bool?
    var _helpPageShowed : Bool?
    var _addRuleShowed : Bool?
    
    var homeViewController:HomeViewController?
    var settingViewController:NSViewController?
    var helpViewController:NSViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.frame = NSMakeRect(0, 0, 1140, 700)
        self.initShowHomePage()
        
        //设置导航栏背景
        leftBarView?.wantsLayer = true;
        leftBarView?.layer?.backgroundColor = NSColor(red: 68.0 / 255.0, green: 144.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0).cgColor;
        
    }
    
    func initShowHomePage (){
        self.removeAllChildViewController();
        if(homeViewController==nil){
            homeViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HomeViewController")) as! HomeViewController
        }
        self.showChildViewController(child: homeViewController!)
        _homePageShowed = true;
        _helpPageShowed = false;
        _settingPageShowed = false;
        _addRuleShowed=false;
    }
    
    
    @IBAction func showHomePage(_ sender: Any) {
        if(_addRuleShowed!){
            goAddRulePage()
        }else if (!_homePageShowed!) {
            initShowHomePage()
        }
        let button = sender as! NSButton;
        self.addjustLeftItemButtonStyle(item: button);
    }
    
    @IBAction func showSettingPage(_ sender: Any) {
        if (!_settingPageShowed!) {
            self.removeAllChildViewController();
            if(settingViewController==nil){
                settingViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SettingViewController")) as! NSViewController
            }
            self.showChildViewController(child: settingViewController!)
            
            let button = sender as! NSButton;
            self.addjustLeftItemButtonStyle(item: button);
            _settingPageShowed = true;
            _homePageShowed = false;
            _helpPageShowed = false;
        }
    }
    
    @IBAction func showHelpPage(_ sender: Any) {
        if (!_helpPageShowed!) {
            self.removeAllChildViewController();
            if(helpViewController==nil){
                helpViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HelpViewController")) as! NSViewController
            }
            self.showChildViewController(child: helpViewController!)
            
            let button = sender as! NSButton;
            self.addjustLeftItemButtonStyle(item: button);
            _settingPageShowed = false;
            _homePageShowed = false;
            _helpPageShowed = true;
        }
    }
    /// 添加规则
    public func goAddRulePage (){
        self.removeAllChildViewController();
        //        if(addRuleViewController == nil){
        let addRuleViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddRuleViewController")) as! AddRuleViewController
        //        }
        showChildViewController(child: addRuleViewController)
        _helpPageShowed = false;
        _addRuleShowed=true;
    }
    
    /// 拷贝规则
    public func copyRule(ruleInfo:RuleInfo){
        self.removeAllChildViewController();
        let addRuleViewController =  NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddRuleViewController")) as! AddRuleViewController
        addRuleViewController.setRuleInfo(ruleInfo: ruleInfo)
        showChildViewController(child: addRuleViewController)
        _helpPageShowed = false;
        _addRuleShowed=true;
    }
    
    
    public func backFromRulePage(){
        _helpPageShowed = false;
        _addRuleShowed=false;
        initShowHomePage()
    }
    
    public func updateRuleInfo(ruleInfo:RuleInfo,action:String){
        homeViewController!.refreshRuleInfo(ruleInfo: ruleInfo, action: action)
        backFromRulePage()
    }
    
    func showChildViewController (child : NSViewController){
        child.view.frame = NSMakeRect(70, 0, 1140-70, 700)
        self.addChildViewController(child);
        
        self.view.addSubview(child.view)
        
    }
    
    func removeAllChildViewController (){
        for childs in self.childViewControllers {
            childs.removeFromParentViewController();
            childs.view.removeFromSuperview();
        }
    }
    
    
    func addjustLeftItemButtonStyle (item : NSButton){
        if (item == self.homeItemButton) {
            self.homeItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_homepage_s"))
        } else {
            self.homeItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_homepage_n"))
            
        }
        
        if (item == self.settingItemButton) {
            self.settingItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_setting_s"))
            
        } else {
            self.settingItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_setting_n"))
            
        }
        
        if (item == self.helpItemButton) {
            self.helpItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_help_s"))
            
        } else {
            self.helpItemButton?.image = NSImage.init(named: NSImage.Name(rawValue: "tab_help_n"))
            
        }
    }
    
    
    
}

extension  HomeContainerViewController : NSViewControllerPresentationAnimator  {
    
    public func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        topVC.view.alphaValue = 0
        bottomVC.view.addSubview(topVC.view)
        topVC.view.frame = bottomVC.view.frame
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.35
            topVC.view.animator().alphaValue = 1
            
        }, completionHandler: nil)
    }
    public func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.35
            topVC.view.animator().alphaValue = 0
        }, completionHandler: {
            topVC.view.removeFromSuperview()
        })
    }
}
