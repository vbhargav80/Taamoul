//
//  DLDemoRootViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class REFrostedRootViewController: REFrostedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        
        /*let defaults = NSUserDefaults.standardUserDefaults()
        /*defaults.setBool(false, forKey: "builderloggedin")
        defaults.setBool(true, forKey: "userloggedin")
        defaults.setObject("test", forKey: "UserName")
        defaults.setObject("24", forKey: "UserId")*/
        if(defaults.boolForKey("builderloggedin") == true){
            let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("builderDetailsView")
            let navController = self.storyboard?.instantiateViewControllerWithIdentifier("navController") as! ReFrostedNavigationController
            navController.viewControllers = [rootViewController!]
            self.contentViewController = navController
        }

       else if defaults.boolForKey("userloggedin") == true{
            self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainNavController")
        }
        else{
            self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("navController")
        }*/
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("navController")
        self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("sideMenuViewController")
        
        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
            if isLogin == true{
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isVerified")
                if let hamburguerViewController =  self.contentViewController{
                    let navController  = hamburguerViewController as? UINavigationController
                    if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("meditationViewController") as? MeditationsViewController{
                        navController!.viewControllers = [viewController]
                        if let hamburguerViewController = self.findHamburguerViewController() {
                            hamburguerViewController.hideMenuViewControllerWithCompletion({ () -> Void in
                                //hamburguerViewController.contentViewController = nil
                                hamburguerViewController.contentViewController = navController
                            })
                        }
                        
                    }
                }
            }
        }

        /*if let isVerifier = NSUserDefaults.standardUserDefaults().valueForKey("isVerified") as? Bool{
            if isVerifier == false{
                if let hamburguerViewController =  self.contentViewController{
                    let navController  = hamburguerViewController as? UINavigationController
                    if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("confirmViewController") as? ConfirmationViewController{
                        navController!.viewControllers = [viewController]
                        if let hamburguerViewController = self.findHamburguerViewController() {
                            hamburguerViewController.hideMenuViewControllerWithCompletion({ () -> Void in
                                //hamburguerViewController.contentViewController = nil
                                hamburguerViewController.contentViewController = navController
                            })
                        }
                        
                    }
                }
            }
        }*/
    }
}
