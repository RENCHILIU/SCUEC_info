//
//  LibraryView.swift
//  SCUEC_info
//
//  Created by  Lrcray on 15/4/19.
//  Copyright (c) 2015年  Lrcray. All rights reserved.
//
/*———————————————————————————————————————
Lib的主界面，界面ui在storyboard中实现
———————————————————————————————————————*/
import UIKit
import Alamofire
class LibraryView: UITableViewController {
    var UserName: String! //用户名
    var PassWord: String! //密码
    var UserNameType: String! //用户名类型
    //初始化 NSUserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    var autologinnumeber: Bool = true //自动登录
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var loginButton: UIBarButtonItem!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 62/255, green: 165/255, blue: 64/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 240
        
        
        //自动登录
        
        if autologinnumeber {
            var logintype = defaults.stringForKey("auto_login")
            
            if logintype == "auto_login"{
                var nametype = defaults.stringForKey("UsernameType")
                getUserData() //数据处理
                userLogin(UserName,password: PassWord,type: UserNameType) //网络请求
                autologinnumeber = false
            }
        }
    }

    
    func getUserData() {

            UserName = defaults.stringForKey("Username")
            PassWord = defaults.stringForKey("Password")
            UserNameType =  defaults.stringForKey("UsernameType")

            // 清空之前的cookies，马上保存
            defaults.setObject(nil, forKey: "Cookie_name")
            defaults.setObject(nil, forKey: "Cookie_value")
            defaults.synchronize()

        
        
        
    }

   
    func userLogin(username:String, password:String, type:String) {
        Alamofire.request(Router.LoginUser(["number":"\(username)", "passwd":"\(password)", "select":"\(type)"])).responseString(encoding: NSUTF8StringEncoding, completionHandler:{ (_, _, string, _) in
            // 测试
            //println(string)
        }).response { (_, _, _, error) -> Void in
            var mycookie = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
            var cookie:NSHTTPCookie!
            if error != nil {
                println("登录请求错误")
                }else{
                //储存cookies
                var mycookie = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
                var cookie:NSHTTPCookie!
                for cookie in mycookie as! [NSHTTPCookie]{
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(cookie.name, forKey: "Cookie_name")
                    defaults.setObject(cookie.value, forKey: "Cookie_value")
                    defaults.synchronize()
                    //println(cookie.value)
                    println("cookie存储成功")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    
                }
            }
        }
        
    }

    



}
