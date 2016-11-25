//
//  AppDelegate.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 20/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   static var deviceToken = NSString()
    static var meditationsArray = NSArray()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // com.tamoul.meditation
        //Clear SDWebImageManager images cache
        SDWebImageManager.sharedManager().imageCache.clearMemory()
        SDWebImageManager.sharedManager().imageCache.clearDisk()
        // Register for remote notifications
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        application.beginReceivingRemoteControlEvents()
        return true
    }
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        /*if self.window?.rootViewController?.presentedViewController is PlayerViewController {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.All.rawValue);
        } else {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.Portrait.rawValue);
        }*/
        let currentViewController: UIViewController = self.topViewController()
        
        // Check whether it implements a dummy methods called canRotate
        if currentViewController.respondsToSelector(Selector("canRotate")){
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        }
        else if currentViewController.respondsToSelector(Selector("dontRotate")){
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.Portrait.rawValue)
        }
        else{
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.Portrait.rawValue)
        }
        // Only allow portrait (standard behaviour)

    }
    func topViewController() -> UIViewController{
        if  UIApplication.sharedApplication().keyWindow != nil{
            if UIApplication.sharedApplication().keyWindow!.rootViewController != nil{
                return self.topViewControllerWithRootViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
            }
        }
        return UIViewController()
    }
    
    func topViewControllerWithRootViewController(rootViewController : UIViewController) -> UIViewController {
        
        if (rootViewController.isKindOfClass(UITabBarController)) {
            let tabBarController: UITabBarController = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(tabBarController.selectedViewController!);
        } else if (rootViewController.isKindOfClass(UINavigationController)) {
            let navigationController: UINavigationController = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(navigationController.visibleViewController!);
        } else if ((rootViewController.presentedViewController) != nil) {
            let presentedViewController: UIViewController  = rootViewController.presentedViewController!;
            return self.topViewControllerWithRootViewController(presentedViewController);
        }
        return rootViewController
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK:Pushnotifications delagate methods
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        AppDelegate.deviceToken = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        print(AppDelegate.deviceToken)
        
        /*if deviceToken.length > 0 {
        AppDelegate.deviceToken = NSString(data: deviceToken, encoding: NSUTF8StringEncoding)!
        }*/
    }
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            
    }
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
    }

}


extension String {
    func localized(comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? self)
    }
}
