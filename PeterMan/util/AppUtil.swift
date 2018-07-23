//
//  AppUtil.swift
//  PeterMan
//
//  Created by zhangquan on 2018/5/23.
//  Copyright © 2018年 socialteam. All rights reserved.
//

import Cocoa

class AppUtil: NSObject {
    static var pythonBin:String=""
    static var loginedUser:String?
    static let rootDir = NSHomeDirectory() + "/.peterman"
    static let testDir = rootDir+"/test"
    static let settingFile=rootDir+"/setting.json"
    static let contentDir=rootDir+"/contents"
    static let dataDir=contentDir+"/data"
    static let scriptDir=contentDir+"/scripts"
    static let explainDir=contentDir+"/explain"
    static let configFile=contentDir+"/config.json"
    static let supportFile=contentDir+"/support.json"
    static let logFile=rootDir+"/log.txt"
    
    /// 保存内容到文件中
    /// - parameter str: 文件内容
    /// - parameter filename: 文件名
    /// - parameter append: 是否追加内容到文件末尾
    static func saveToFile(str:String,file:String,append:Bool){
        // 参考：http://www.hangge.com/blog/cache/detail_527.html
        makeRootDir()
        let fileManager=FileManager.default
        let fileUrl = NSURL(fileURLWithPath: file)
        let fileExist = fileManager.fileExists(atPath: fileUrl.path!)
        
        let appendAction=(append && fileExist) ? true : false
        
        if appendAction{
            let fileHandle=FileHandle(forWritingAtPath: file)
            fileHandle!.seekToEndOfFile()
            let content="\n"+str
            fileHandle?.write(content.data(using: String.Encoding.utf8)!)
            
        }else{
            saveFile(content: str, fileName: file)
        }
    }
    
    static func delFile(_ file:String){
        do {
            let fileManager = FileManager.default
            let fileUrl = NSURL(fileURLWithPath: file)
            let fileExist = fileManager.fileExists(atPath: fileUrl.path!)
            if fileExist{
                try fileManager.removeItem(atPath: file)
            }
        } catch {
            print(error)
        }
        
    }
    
    /// 读取文件
    ///
    /// - Parameter filename: 文件名，相对于.peterman目录
    /// - Returns: 文件内容
    static func readFile(filename:String)->String?{
        makeRootDir()
        return AppUtil.readFileContent(filename)
    }
    
    static func saveFile(content:String,fileName:String){
        do {
            let url=URL(fileURLWithPath: fileName)
            try content.write(to:  url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
    }
    
    static func readFileContent(_ file:String)->String?{
        do{
            let fileManager = FileManager.default
            let fileUrl = NSURL(fileURLWithPath: file)
            let fileExist = fileManager.fileExists(atPath: fileUrl.path!)
            if !fileExist{
                return nil
            }
            return try String.init(contentsOfFile: file) //将文件中的内容直接读成字符串
            //        return try! NSString(contentsOfFile: fileUrl.path!, encoding: UInt((String.Encoding.utf8).rawValue)) as String?
            
            //        //通过FileHandle只读
            //        let  readHandle = FileHandle.init(forReadingAtPath: file)
            //        let content=readHandle?.readDataToEndOfFile()
            //        return String.init(data: content!, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
        return nil
    }
    
    /// 执行python脚本命令
    ///
    /// - Parameter args: 命令参数
    /// - Returns: 命令行执行结果
    static func execPythonCmd(_ args:String...)->String{
        if pythonBin==""{
            pythonBin = getCmdBin("python")
        }
        var arguments:[String]=[contentDir+"/scripts/logprocess.py"]
        for arg in args{
            arguments.append(arg)
        }
        return AppUtil.runCommand(launchPath:pythonBin, arguments: arguments)
    }
    static func getCmdBin(_ cmd:String)->String{
        var cmdBin = AppUtil.runCommand(launchPath:"/usr/bin/which", arguments: [cmd])
        cmdBin = cmdBin.replacingOccurrences(of: "\n", with: "")
        return cmdBin
    }
    
    static func isSetup()->Bool{
        //检查content文件夹是否存在
        let fileManager = FileManager.default
        let fileUrl = NSURL(fileURLWithPath: contentDir)
        if fileManager.fileExists(atPath: fileUrl.path!){
            return true
        }
        return false
    }
    
    static func setUp() ->Bool{
        makeRootDir()
        if isSetup(){
            return true
        }
        
        //创建.peterman目录
        makeRootDir()
        let gitBin=getCmdBin("git")
        //git clone git@gitlab.alipay-inc.com:mianli.zq/peterman_test.git contents
        let result=runCommand(launchPath: gitBin, arguments: ["clone","git@gitlab.alipay-inc.com:apsocialandroid/peterman_data.git",contentDir])
        print("result=\(result)")
        Logger.info("setup:\n"+result)
        
        return true
    }
    static func makeRootDir(){
        makeDir(dir: rootDir)
        makeDir(dir: testDir)
    }
    
    static func makeDir(dir:String){
        let fileManager = FileManager.default
        let url=URL(fileURLWithPath: dir)
        let urlExist = fileManager.fileExists(atPath: url.path)
        do{
            if !urlExist{
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print(error)
        }
    }
    
    /// 执行命令行
    /// - parameter launchPath: 命令行启动路径
    /// - parameter arguments: 命令行参数
    /// returns: 命令行执行结果
    static func runCommand(launchPath: String, arguments: [String]) -> String {
        let pipe = Pipe()
        let file = pipe.fileHandleForReading
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = pipe
        task.launch()
        
        let data = file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8)!
    }
    
    static  func update(){
        // chmod +x .peterman/contents/bin/update.sh
        // sh .peterman/contents/bin/update.sh
        let chmodBin = getCmdBin("chmod")
        let chBin=getCmdBin("sh")
        let updateUrl=contentDir+"/bin/update.sh"
        
        runCommand(launchPath: chmodBin, arguments: ["+x",updateUrl]) //chmod +x update.sh
        runCommand(launchPath: chBin, arguments: [updateUrl]) //sh update.sh
    }
    
    static  func commit()->String{
        let chmodBin = getCmdBin("chmod")
        let chBin=getCmdBin("sh")
        let commitUrl=contentDir+"/bin/commit.sh"
        
        runCommand(launchPath: chmodBin, arguments: ["+x",commitUrl]) //chmod +x commit.sh
        let result=runCommand(launchPath: chBin, arguments: [commitUrl]) //sh commit.sh
        return result
    }
    
    static func getConfig()->AppConfig?{
        let filePath = configFile
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: filePath)
        if !exist{
            return nil;
        }
        do{
            let jsonString=AppUtil.readFileContent(filePath)
            let jsonData = jsonString!.data(using: String.Encoding.utf8)
            let data=Data(jsonData!)
            let decoder = JSONDecoder()
            return try decoder.decode(AppConfig.self, from: data)
        } catch {
            print(error)
        }
        return nil
    }
    
    static func getRuleCategorys()->[RuleCategory]{
        let appConfig=getConfig()
        if appConfig == nil{
            return []
        }
        return appConfig!.categorys
    }
    
    static func getAppList()->[String]{
        let appConfig=getConfig()
        if appConfig == nil{
            return []
        }
        return appConfig!.appList;
    }
    static func getOperations()->[String]{
        let appConfig=getConfig()
        if appConfig == nil{
            return []
        }
        return appConfig!.operations;
    }
    static func getAppVersion()->Int{
        let appConfig=getConfig()
        if appConfig == nil{
            return 1
        }
        return appConfig!.appVersion;
    }
    
    static func getRules()->[Int:[RuleInfo]]?{
        let dirPath = dataDir
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: dirPath)
        if !exist{
            setUp()
        }
        //先更新
        update()
        return getLocalRules()
    }
    
    static func getLocalRules()->[Int:[RuleInfo]]?{
        var ruleMap:[Int:[RuleInfo]]=[:]
        do{
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: dataDir)
            for file in files{ //遍历文件
                if !file.hasSuffix(".json"){ //必须是.json文件
                    continue
                }
                let filePath=dataDir+"/"+file
                let jsonString=AppUtil.readFileContent(filePath)
                let jsonData = jsonString!.data(using: String.Encoding.utf8)
                let data=Data(jsonData!)
                let decoder = JSONDecoder()
                let ruleInfo=try decoder.decode(RuleInfo.self, from: data)
                let cid=ruleInfo.cid
                if ruleMap[cid]==nil{
                    ruleMap[cid]=[]
                }
                ruleMap[cid]!.append(ruleInfo)
            }
            //按点赞数降序排序
            for key in ruleMap.keys{
                ruleMap[key]=orderListBySupport(ruleList: &ruleMap[key]!)
            }
        } catch {
            print(error)
        }
        return ruleMap
    }
    
    /// 按照点赞数降序排序
    ///
    /// - Parameter rule: 规则
    /// - Returns: 排序后的规则
    static func orderListBySupport(ruleList: inout [RuleInfo])->[RuleInfo]{
        if ruleList.count<=1{
            return ruleList
        }
        let ruleSupport=getSupports()
        //按点赞数降序排序
        let sortedRuleList = ruleList.sorted { (ruleInfo1, ruleInfo2) -> Bool in
            let count1=ruleSupport.getSupport(cid: ruleInfo1.cid, id: ruleInfo1.id).users.count
            let count2=ruleSupport.getSupport(cid: ruleInfo2.cid, id: ruleInfo2.id).users.count
            if count1==0 && count2==0{ //如果点赞数为0 则按创建时间先后排序
                return ruleInfo1.id<ruleInfo2.id
            }
            return count1>=count2
        }
        
        return sortedRuleList
    }
    
    /// 获取个人配置
    ///
    /// - Returns: 个人配置
    static func getSettingInfo()->SettingInfo?{
        let settingValues=readFile(filename: settingFile)
        if settingValues==nil||settingValues==""{
            let settingInfo=SettingInfo()
            settingInfo.tool="TextWrangler"
            settingInfo.history=[]
            saveSettingInfo(settingInfo) //保存到文件中
            return settingInfo
        }
        let jsonData = settingValues!.data(using: String.Encoding.utf8)
        let data=Data(jsonData!)
        let decoder = JSONDecoder()
        let settingInfo=try!decoder.decode(SettingInfo.self, from: data)
        return settingInfo
    }
    
    /// 保存个人配置
    ///
    /// - Parameter info: 个人配置
    static func saveSettingInfo(_ info:SettingInfo){
        let encoder=JSONEncoder()
        let jsonData=try!encoder.encode(info)
        let jsonStr=String(data: jsonData, encoding: .utf8)!
        saveFile(content: jsonStr, fileName: settingFile)
    }
    
    /// 获取登录用户
    ///
    /// - Returns: 登录用户名
    static func getUser()->String?{
        if loginedUser==nil||loginedUser==""{
            let settingInfo=getSettingInfo()
            loginedUser = settingInfo!.loginUser
        }
        return loginedUser
        
    }
    static func saveUser(_ user:String){
        let settingInfo=AppUtil.getSettingInfo()
        settingInfo?.loginUser=user
        saveSettingInfo(settingInfo!)
    }
    
    static func getSupports()->RuleSupport{
        let supportUserValues=readFile(filename: supportFile)
        if supportUserValues==nil||supportUserValues==""{
            return RuleSupport()
        }
        let jsonData = supportUserValues!.data(using: String.Encoding.utf8)
        let data=Data(jsonData!)
        let decoder = JSONDecoder()
        let ruleSupport=try!decoder.decode(RuleSupport.self, from: data)
        
        return ruleSupport
    }
    
    static func saveSupport(ruleInfo:RuleInfo)->RuleSupport?{
        update()
        let ruleSupport=getSupports()
        let list = ruleSupport.list
        var append=true
        if list.count>0{
            for item in list{
                if item.cid==ruleInfo.cid&&item.id==ruleInfo.id{
                    append=false
                    item.users.append(getUser()!)
                    break
                }
            }
        }
        if append{
            let item=RuleSupportInfo()
            item.cid=ruleInfo.cid
            item.id=ruleInfo.id
            item.users.append(getUser()!)
            ruleSupport.list.append(item)
        }
        let encoder=JSONEncoder()
        let jsonData=try!encoder.encode(ruleSupport)
        let jsonStr=String(data: jsonData, encoding: .utf8)!
        saveFile(content: jsonStr, fileName: supportFile)
        commit()
        return ruleSupport;
    }
    
    static func trimStr(_ str:String)->String{
        return str.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    static func execLogTask(ruleInfo:RuleInfo?,path:String){
        
        //保存历史
        let settingInfo =  getSettingInfo()
        var targetIndex = -1
        for (index,item) in settingInfo!.history.enumerated(){
            if item.cid == ruleInfo!.cid && item.id==ruleInfo!.id{
                targetIndex=index
                break
            }
        }
        let historyItem=ViewHistory()
        historyItem.cid=ruleInfo!.cid
        historyItem.id=ruleInfo!.id
        if targetIndex>0{ //已经存在，先移除，然后放在第1位
            settingInfo?.history.remove(at: targetIndex)
        }
        settingInfo?.history.insert(historyItem, at: 0)
        saveSettingInfo(settingInfo!)
        
        //日志解释脚本
        let explains=ruleInfo?.explains
        if explains != nil && !explains!.isEmpty{
            for item in explains!{
                let script=CommonUtil.base64Decoding(item.script)
                createTestPyFile(name: item.name, pattern: item.pattern, script: script)
            }
        }
        
        
        let cid=String(ruleInfo!.cid)
        let id=String(ruleInfo!.id)
        let result = AppUtil.execPythonCmd("-x",cid+"_"+id,"-path",path)
        print(result)
    }
    
    static  func doSaveRuleInfo(_ ruleInfo:RuleInfo){
        let fileName=String(ruleInfo.cid)+"_"+String(ruleInfo.id)+".json"
        let jsonFile=dataDir+"/"+fileName
        
        let encoder=JSONEncoder()
        let jsonData=try!encoder.encode(ruleInfo)
        let jsonStr=String(data: jsonData, encoding: .utf8)!
        
        saveFile(content: jsonStr, fileName: jsonFile)
        
        //检查是否删除解释脚本
        //        if ruleInfo.explain.isEmpty{
        //            let file = explainDir+"/"+String(ruleInfo.cid)+"_"+String(ruleInfo.id)+".py"
        //            delFile(file)
        //        }
        
        commit()
    }
    
    static func copyRuleInfo(_ ruleInfo:RuleInfo)->RuleInfo{
        let encoder=JSONEncoder()
        let jsonByte=try!encoder.encode(ruleInfo)
        let jsonStr=String(data: jsonByte, encoding: .utf8)
        
        
        let jsonData = jsonStr!.data(using: String.Encoding.utf8)
        let data=Data(jsonData!)
        let decoder = JSONDecoder()
        let newRuleInfo=try!decoder.decode(RuleInfo.self, from: data)
        return newRuleInfo
    }
    
    //-----------日志解释----start
    static func createTestPyFile(name:String,pattern:String,script:String)->String{
        makeDir(dir: testDir)
        let file=contentDir+"/scripts/template.py"
        var fileContent=readFileContent(file)!        
        let tabs="\t"
        fileContent+=tabs+"pattern = '\(pattern)'"+"\n"
        fileContent+=tabs+"regexResult = compileExpress(pattern, logLine)  # 解析正则表达式"+"\n"
        fileContent+=tabs+"result = ''"+"\n"
        fileContent+=tabs+"if regexResult.strip():  # 匹配成功，解析相应注释"+"\n"
        let splitedArray=script.split(separator: "\n")
        for item in splitedArray{
            let line = item.trimmingCharacters(in: .whitespaces) //去掉前后的空格
            fileContent+=tabs+tabs+"\(line)"+"\n"
        }
        fileContent+=tabs+"return result"
        
        let targetFile=getTestPyFile(name)
        saveFile(content: fileContent, fileName: targetFile)
        return fileContent
    }
    
    static func getTestPyFileContent(_ explainInfoName:String)->String{
        let file=getTestPyFile(explainInfoName)
        return readFileContent(file)!
    }
    
    static func getTestPyFile(_ name:String)->String{
        return testDir+"/"+name+".py"
    }
    
//    static func runTestPyFile(logLine:String,name:String,pattern:String,script:String)->String{
//         createTestPyFile(name:name,pattern:pattern , script: script)
//        return runTestPyFile(logLine:logLine,name:name)
//    }
//
    static func runTestPyFile(logLine:String,name:String)->String?{
        if pythonBin==""{
            pythonBin = getCmdBin("python")
        }
        //删除结果文件
        let resultFile=testDir+"/result.txt"
        delFile(resultFile)
        //保存日志行
        let logLineFile=testDir+"/logLine.txt"
        saveFile(content: logLine, fileName: logLineFile)
        //执行测试
        let pythonFile=scriptDir+"/runtest.py"
         AppUtil.runCommand(launchPath:pythonBin, arguments: [pythonFile,name])
        //读取结果
        return readFileContent(resultFile)
    }
    //-----------日志解释----end
    
    static func doTest(){
        
    }
}

extension Date {
    /// 获取当前系统时间戳(单位：秒)
    var currentSeconds : Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }
    
    /// 获取当前系统时间戳(单位：毫秒)
    var currentTimeMillis : CLongLong {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return millisecond
    }
}
