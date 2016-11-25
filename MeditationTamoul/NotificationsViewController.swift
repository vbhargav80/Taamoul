//
//  NotificationsViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 25/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet var notificationsSwitch : UISwitch!
    @IBOutlet var settingsTableView : UITableView!
    
    let settingsArray = ["get_notified".localized("Notifications"), "Rate This App".localized("Rate This App"),"Logout","Version"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        settingsTableView.tableFooterView = UIView()
    }

    //MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = settingsTableView.dequeueReusableCellWithIdentifier("settingsCell")! as UITableViewCell
        let lblTitle : UILabel = cell.viewWithTag(100) as! UILabel
        let lblSubTitle : UILabel = cell.viewWithTag(101) as! UILabel
        let notifySwitch : UISwitch = cell.viewWithTag(102) as! UISwitch
        
        lblTitle.text = settingsArray[indexPath.row]
        lblSubTitle.text = ""
        notifySwitch.hidden = true
        if indexPath.row == 3{
            let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
            lblSubTitle.text = version
        }
        if indexPath.row == 0{
            notifySwitch.hidden = false
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch (indexPath.row) {
            
        case 0:
             break
            
        case 1:
            let textToShare = "Tamoul"
            
            if let myWebsite = NSURL(string: "http://www.google.com/")
            {
                let objectsToShare = [textToShare, myWebsite]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                //New Excluded Activities Code
                activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
                //
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }

            break
            
        case 2:
            NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("isLogin")
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginViewController, animated: true)

            break
        case 3:
            break
            
        default:
            break
        }
    }

    //MARK: Button Click Methods
    
    @IBAction func sideMenuButtonClick(sender: AnyObject)
    {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    @IBAction func signOutButtonClick(sender : UIButton){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isLogin")
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
