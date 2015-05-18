//
//  favoriteBookView.swift
//  SCUEC_info
//
//  Created by  Lrcray on 15/5/1.
//  Copyright (c) 2015年  Lrcray. All rights reserved.
//
/*———————————————————————————————————————
被收藏到书架的书籍展示，点击cell进入详细信息
———————————————————————————————————————*/
import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import MBProgressHUD
class favoriteBookView: UITableViewController
{
    var favbooks: [Favorites]!
    var book: [Book]!
    
    var refresh: Bool!
  
       
 
    //coreDataStack实例
    var coreDataStack: CoreDataStack = CoreDataStack()
    //NSManagedObjectContext实例赋值在了savecoredata方法中
    var managedObjectContext: NSManagedObjectContext!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh = false
        
        // coredata
        managedObjectContext = coreDataStack.context
        favbooks = fetchfavbookData("favor_FetchRequest") as! [Favorites]
        book = fetchCoreData("book_FetchRequest") as! [Book]
        
              

    
    
    }
        
  

// MARK: - Table view data source

// MARK: -  删除cell操作
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath:NSIndexPath) -> [AnyObject] {
        

        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
            title: "删除",handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            //fav标记取消
            self.book[indexPath.row].isfav = 0
                
            //coredata操作
            let dataToRemove = self.favbooks[indexPath.row]
            self.managedObjectContext.deleteObject(dataToRemove)
            //数据操作
            self.favbooks.removeAtIndex(indexPath.row)
                
            var e: NSError?
            if self.managedObjectContext.save(&e) != true {
                println("favbook中存储coredata出错 error: \(e!.localizedDescription)")}
            //cell的删除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
               
            tableView.editing = false
        })
        
       
        deleteAction.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 64/255, alpha: 1)
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return favbooks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! bookInfoCell
        
        if var bookrequestname = self.favbooks[indexPath.row].name{
        
       
        //网络请求
            Alamofire.request(doubanRouter.searchBook(["q":"\(bookrequestname)", "apikey":"021ee6fe92aee6a4065cb4fbb80cb3ec"])).responseJSON { (_, _, json, _)  in
                
               
                //返回数据不为nil则解析，coredata操作
                    if json != nil {
                    var jsondata = JSON(json!)
                        if var imgM = jsondata["books"][0]["images"]["medium"].string{
                            var imgurl = NSURL(string: imgM)
                            // 存入coredata
                           
                            self.favbooks[indexPath.row].imgurlM = imgM
                            var e: NSError?
                                if self.managedObjectContext.save(&e) != true {
                                    println("favbook中存储coredata出错 error: \(e!.localizedDescription)")}
                            //cell config
                            cell.bookimg.sd_setImageWithURL(imgurl)
                        }
                    }else{
                        if var imgurl = self.favbooks[indexPath.row].imgurlM{
                            cell.bookimg.sd_setImageWithURL(NSURL(string:imgurl))}}
            }
        
    
        cell.bookname.text = self.favbooks[indexPath.row].name
        cell.author.text = self.favbooks[indexPath.row].author
        }
        return cell
    }
    
// MARK: - Navigation
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showbookInfo" {
            if let row = tableView.indexPathForSelectedRow()?.row {
                let destinationController = segue.destinationViewController as! bookInfo
                destinationController.booksname = self.favbooks[row].name

            }
        }
    }
   
//MARK:获取
    func fetchfavbookData(TemplateForName: String) -> [NSManagedObject]?{
        //获取方法初始化
        var fetchRequest: NSFetchRequest!
        fetchRequest = coreDataStack.model.fetchRequestTemplateForName(TemplateForName)
        var error: NSError?
        let results = coreDataStack.context.executeFetchRequest(fetchRequest,error: &error) as? [Favorites]
        if let fetchedResults = results {
            // books = fetchedResults
            return fetchedResults
            //store the fetched results in the venues property you defined earlier
        } else {
            println("favbook数据获取失败：Could not fetch \(error), \(error!.userInfo)")
            
            //错误提示
            var errorHUD = MBProgressHUD()
            errorHUD.color = UIColor(red: 62/255, green: 165/255, blue: 64/255, alpha: 1)
            errorHUD.labelText = "数据获取失败"
            self.tableView.addSubview(errorHUD)
            errorHUD.customView = UIImageView(image: UIImage(named: "errormark"))
            errorHUD.mode = MBProgressHUDMode.CustomView
            errorHUD.show(true)
            errorHUD.hide(true, afterDelay: 2)
            
            return nil
        }
        
    }

    
    

}
