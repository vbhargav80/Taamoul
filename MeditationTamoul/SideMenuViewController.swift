//
//  DLDemoMenuViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import MessageUI

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var userImageView : UIImageView?
    @IBOutlet var userName : UILabel?

    private var playlistViewController: MeditationsViewController!
    let defaults = NSUserDefaults.standardUserDefaults()
    var selectedMenuItem : Int = 0
    var arrMenuItems : NSArray = [
        ["image" : "About", "English" : "About","Title":"عن التأمل"],
        ["image" : "MeditationIcon", "English" : "Meditations","Title" : "التأملات"],
        ["image" : "mytrack", "English" : "Playlist","Title" : "قائمة التشغيل"],
        ["image" : "Courses", "English" : "Courses","Title":"التدريب" ],
        ["image" : "Settings", "Title" :"إعدادات","English" : "Settings"],
        ["image" : "ContactUs", "Title" : "إتصل بنا","English" : "اتصل بنا"],
        ["image" : "privacy", "Title" : "خصوصية","English" : "Privacy"]]
    //var arrMenuItems : NSArray = [["image" : "About", "Title" : "About"],["image" : "MeditationIcon", "Title" : "Meditations"],["image" : "Settings", "Title" : "Settings"],["image" : "ContactUs", "Title" : "Contact Us"]]

    let segues = ["BuildersListSegue", "HotDealsSegue", "BuilderListSegue", "PreferencesSegue"]
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    var navController : UINavigationController!
    var destViewController : UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        //tableView.contentInset = UIEdgeInsetsMake(20.0, 0, 0, 0) //
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = true
        tableView.autoresizesSubviews = true
        //tableView.autoresizingMask = .FlexibleWidth
        self.reloadMenuTableView()
        playlistViewController = mainStoryboard.instantiateViewControllerWithIdentifier("meditationViewController") as! MeditationsViewController
        playlistViewController.isPlaylist = true
    }
    
    func reloadMenuTableView(){

        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return arrMenuItems.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        let imgBuilder : UIImageView = cell!.viewWithTag(100) as! UIImageView
        let lblBuilderName : UILabel = cell!.viewWithTag(101) as! UILabel
        //let dictionary : NSDictionary = arrMenuItems.objectAtIndex(indexPath.row) as! NSDictionary
        //let Title : NSString=builderMenuItems[indexPath.row] .valueForKey("Title") as! NSString
        //let image : NSString=builderMenuItems[indexPath.row] .valueForKey("image") as! NSString
        
        let builderDictionary : NSDictionary = arrMenuItems.objectAtIndex(indexPath.row) as! NSDictionary
        imgBuilder.image = UIImage(named: (builderDictionary.valueForKey("image") as? String)!)
        lblBuilderName.text = builderDictionary.valueForKey("Title") as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //print("did select row: \(indexPath.row)")
        
        selectedMenuItem = indexPath.row
        if let hamburguerViewController = self.findHamburguerViewController()?.contentViewController {
            self.navController = hamburguerViewController as? UINavigationController
        }
        else{
            navController = self.storyboard?.instantiateViewControllerWithIdentifier("navController") as! ReFrostedNavigationController
        }
        let currentViewController = self.navController.visibleViewController
        //Present new view controller

        switch (indexPath.row) {
            
        case 0:
            if currentViewController is AboutViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("aboutViewController")
            }

            break
        case 1:
            
            if currentViewController is MeditationsViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("meditationViewController")
            }
            break
        case 2:
            
            if currentViewController == playlistViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = playlistViewController
            }
            break
        case 3:
            if currentViewController is HomeViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("homeViewController")
            }
            break

        case 4:

            if currentViewController is NotificationsViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("notificationsViewController")
            }
            break
            
        case 5:
            
            
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
                
//                mailComposerVC.setToRecipients(["nurdin@gmail.com"])
//                mailComposerVC.setSubject("Sending you an in-app e-mail...")
//                mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
                self.presentViewController(mailComposerVC, animated: true, completion: nil)
            }
            
            /*
            if currentViewController is ContactUsViewController
            {
                destViewController = currentViewController
                break
            }
            else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("contactViewController")
            }
            break*/
 
        case 6:
            
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PrivacyViewController")

        default:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("preferencesViewController")
            break
        }
        if let viewController = destViewController{
            navController.viewControllers = [viewController]
            if let hamburguerViewController = self.findHamburguerViewController() {
                hamburguerViewController.hideMenuViewControllerWithCompletion({ () -> Void in
                    //hamburguerViewController.contentViewController = nil
                    hamburguerViewController.contentViewController = self.navController
                })
            }

        }
        /*let nvc = self.mainNavigationController()
        if let hamburguerViewController = self.findHamburguerViewController() {
            hamburguerViewController.hideMenuViewControllerWithCompletion({ () -> Void in
                nvc.visibleViewController!.performSegueWithIdentifier(self.segues[indexPath.row], sender: nil)
                hamburguerViewController.contentViewController = nvc
            })
        }*/
    }
    
    @IBAction func shareButtonClicked(sender: UIButton)
    {
        /*let textToShare = "Swift is awesome!  Check out this website about it!"
        let myWebsite = NSURL(string: "http://www.google.com")
        let objectsToShare = [textToShare, myWebsite]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        //
        
        self.presentViewController(activityVC, animated: true, completion: nil)*/
        
        let textToShare = "BuildersHub"
        
        if let myWebsite = NSURL(string: "http://www.google.com/")
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            //
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    func mainNavigationController() -> ReFrostedNavigationController {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("userloggedin") == true{
            return self.storyboard?.instantiateViewControllerWithIdentifier("mainNavController") as! ReFrostedNavigationController
        }
        else{
            return self.storyboard?.instantiateViewControllerWithIdentifier("navController") as! ReFrostedNavigationController
        }

    }
    
}
