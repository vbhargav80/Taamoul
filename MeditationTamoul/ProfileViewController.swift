//
//  ProfileViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 21/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var imgProfile : UIImageView?
    @IBOutlet var tableCourses : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

    //MARK: Button Click Methods
    
    @IBAction func signInButtonClick( sender : UIButton){
        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    //MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell  = tableCourses.dequeueReusableCellWithIdentifier("profileCell")! as UITableViewCell
        let lblFieldTitle : UILabel = cell.viewWithTag(100) as! UILabel
        let lblFieldValue : UILabel = cell.viewWithTag(101) as! UILabel
        let switchSocial : UISwitch = cell.viewWithTag(102) as! UISwitch
        let btnConnect : UIButton = cell.viewWithTag(103) as! UIButton
        btnConnect.hidden = true
        
        if indexPath.row > 2{
            lblFieldValue.hidden = true
            switchSocial.hidden = false
        }
        else{
            lblFieldValue.hidden = false
            switchSocial.hidden = true
        }

        switch (indexPath.row) {
            
        case 0:
            lblFieldTitle.text = "Username"
            lblFieldValue.text = "bestmeditator"
            break
        case 1:
            lblFieldTitle.text = "Email"
            lblFieldValue.text = "bestmeditator@gmail.com"
             break
        case 2:
            lblFieldTitle.text = "Password"
            lblFieldValue.text = "**************"
            break
        case 3:
            lblFieldTitle.text = "Facebook"
            switchSocial.on = true
            break
        case 4:
            lblFieldTitle.text = "Twitter"
            switchSocial.on = false
            break
        case 5:
            lblFieldTitle.text = "Google+"
            switchSocial.hidden = true
            btnConnect.hidden = false
            btnConnect.setTitle("Connect", forState: .Normal)
            break

            
        default:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("preferencesViewController")
            break
        }
        //let imgCourse : UIImageView = cell.viewWithTag(100) as! UIImageView
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        /* let builderDetailView  = self.storyboard?.instantiateViewControllerWithIdentifier("builderDetailsView") as! BuilderViewController
        let builderDic = arrComments.objectAtIndex(indexPath.row) as? NSDictionary
        if let builderId = builderDic?.valueForKey("BuilderId") as? Int{
        builderDetailView.builderId = NSString(format: "%d", builderId)
        }
        if let bytesArray  = builderDic?.valueForKey("BuilderLogo") as? NSArray{
        builderDetailView.builderImage = ByteArrayConvertion.convertImage(bytesArray as [AnyObject])
        }
        
        self.navigationController?.pushViewController(builderDetailView, animated: true)*/
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
