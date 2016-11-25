//
//  CategoryViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 29/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet var tableCatagories : UITableView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var titleLabel : UILabel!
    
    var categoryDic = NSDictionary()
    var categoryId = NSString()
    var catVideosArray = NSArray()
    var categoryIdentifier = NSString()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let catName = categoryDic.valueForKey("category_name") as? String{
            self.titleLabel.text = catName;
        }
        if let catId = categoryDic.valueForKey("catid") as? String{
            self.getCategoryDetailsServiceCall(["mode":"getmediadata","catid":catId])
        }
        self.tableCatagories.tableFooterView = UIView()
    }

    override func viewWillAppear(animated: Bool) {
        
        let application: UIApplication = UIApplication.sharedApplication()
        application.setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: true);
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
         
        }
    }
    func getCategoryDetailsServiceCall(params : NSDictionary){
        CustomActivityIndicator.setColorAndBorderForIndicator(activityIndicator, view: self.view)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        WebServices.fetchContentOfUrlAndUrlPath(NSMutableDictionary(dictionary: params), path: "", completionHandler: { (data) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            print(data)
            if let responseDic = data as? NSDictionary{
                if let responseCode = responseDic.valueForKey("code") as? Int{
                    if responseCode == 200{
                        if let tempArray = responseDic.valueForKey("result") as? NSArray{
                            self.catVideosArray = tempArray;
                            self.tableCatagories.reloadData();
                        }
                    }
                    else{
                        if let message = responseDic.valueForKey("message") as? String{
                            self.presentViewController(TextFieldsValidation.showModalAlertView(message, okTitle: "Ok", okHandler: {(_) -> Void in}), animated: true, completion: {})
                            
                        }
                    }
                }
            }
            
            }, badRequest: { (badReq) -> Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.presentViewController(TextFieldsValidation.showModalAlertView(badReq, okTitle: "Ok", okHandler: {(_) -> Void in}), animated: true, completion: {})
            }) { (error) -> Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.presentViewController(TextFieldsValidation.showModalAlertView(error.localizedDescription, okTitle: "Ok", okHandler: {(_) -> Void in}), animated: true, completion: {})
        }
    }

    //MARK: ButtonClick Methods
    @IBAction func backButtonClick( sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func signOutButtonClick(sender : UIButton){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isLogin")
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

    @IBAction func playVideoButtonClick(sender : UIButton){
        /*let buttonPosition : CGPoint  = sender.convertPoint(CGPointZero, toView: tableCatagories)
        let indexPath : NSIndexPath = tableCatagories.indexPathForRowAtPoint(buttonPosition)! as NSIndexPath
        if let mediaDic = catVideosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            let playerController = self.storyboard?.instantiateViewControllerWithIdentifier("playerViewController") as! PlayerViewController
            if mediaDic.valueForKey("video_file") != nil{
                playerController.videoDic = mediaDic
            }
            if mediaDic.valueForKey("audio_file") != nil{
                playerController.videoDic = mediaDic
            }
            playerController.isPurchased = false
            var identifiers = NSArray()
            if let productIds = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
                identifiers = productIds
            }
            if let catName = categoryDic.valueForKey("category_name") as? NSString{
               var tempDic = NSMutableDictionary()
                if catName.isEqualToString("Om"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.om", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.om"){
                        playerController.isPurchased = true
                    }
                }
                else if catName.isEqualToString("Swim"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.swim", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.swim"){
                        playerController.isPurchased = true
                    }
                }
                else if catName.isEqualToString("Sun"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.sun", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.sun"){
                        playerController.isPurchased = true
                    }
                }
                else if catName.isEqualToString("Water"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.water", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.water"){
                        playerController.isPurchased = true
                    }
                }
                
            }
            //self.navigationController?.presentViewController(playerController, animated: false,completion: nil)
            self.navigationController?.pushViewController(playerController, animated: true)
            /*let navcontroller = UINavigationController(rootViewController: playerController)
            navigationController?.navigationBarHidden = true
            self.navigationController?.presentViewController(navcontroller, animated: false,completion: nil)
            let playerView : VideoPlayerView = NSBundle.mainBundle().loadNibNamed("VideoPlayerView", owner: 0, options: nil)[0] as! VideoPlayerView
            playerView.frame = self.view.frame
            playerView.autoresizesSubviews = true
            if let videoUrl = mediaDic.valueForKey("video_file") as? NSString{
                playerView.videoUrl = videoUrl
            }
            if let audioUrl = mediaDic.valueForKey("audio_file") as? NSString{
                playerView.audioUrl = audioUrl
            }
            playerView.backgroundColor = UIColor.clearColor()
            playerView.loadVideoPayer()
            self.view.addSubview(playerView)*/

        }*/
    }

    //MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catVideosArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableCatagories.dequeueReusableCellWithIdentifier("courseCell")! as UITableViewCell
        let imgCourse : UIImageView = cell.viewWithTag(100) as! UIImageView
        let indicatorView : UIActivityIndicatorView = cell.viewWithTag(102) as! UIActivityIndicatorView
        let lblCourseName : UILabel = cell.viewWithTag(101) as! UILabel
        let btnPlay : UIButton = cell.viewWithTag(104) as! UIButton
        btnPlay.hidden = true
        if let urlStr = catVideosArray.objectAtIndex(indexPath.row) as? String{
            let imgUrl = "http://img.youtube.com/vi/\(urlStr)/0.jpg"
            imgCourse.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //btnPlay.hidden = false
                })
            })
        }
        if let videoDic = catVideosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            if let catName = videoDic.valueForKey("name") as? String{
                lblCourseName.text = "  "+catName
            }
            if let urlStr = videoDic.valueForKey("image_file") as? String{
                //print(urlStr)
                //let convertStr =  urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let convertStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                indicatorView.hidden = false
                indicatorView.startAnimating()
                imgCourse.sd_setImageWithURL(NSURL(string: convertStr!), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
                    indicatorView.hidden = true
                    indicatorView.stopAnimating()
                    //btnPlay.hidden = false
                })
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let mediaDic = catVideosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            let playerController = self.storyboard?.instantiateViewControllerWithIdentifier("playerViewController") as! PlayerViewController
            playerController.isFromCourses = true
            if mediaDic.valueForKey("video_file") != nil{
                playerController.videoDic = mediaDic
            }
            if mediaDic.valueForKey("audio_file") != nil{
                playerController.videoDic = mediaDic
            }
            playerController.isPurchased = false
//            var identifiers = NSArray()
//            if let productIds = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
//                identifiers = productIds
//            }
//            /*if let meditatonId = mediaDic.valueForKey("catid") as? NSString{
//                let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
//                if identifiers.containsObject(inAppIdentifier){
//                    playerController.isPurchased = true
//                }
//            }*/
//
//            if identifiers.containsObject(categoryIdentifier){
//                playerController.isPurchased = true
//            }
            if let meditatonId = mediaDic.valueForKey("media_id") as? NSString{
                let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
                playerController.productId = inAppIdentifier
                
            }
            self.navigationController?.pushViewController(playerController, animated: true)
        }
    }
    func dontRotate(){
        
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func shouldAutorotate() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.Portrait.rawValue)
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //print("presented size")
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
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
