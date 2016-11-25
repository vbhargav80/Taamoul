//
//  MeditationsViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 25/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class MeditationsViewController: UIViewController {
    @IBOutlet var tableCourses : UITableView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isPlaylist = false
    
    var isLogin: Bool = {
        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
            return isLogin
        }
        return false
    }()
    var videosArray : NSArray = NSArray() //[ "nyc6iFMX78Q","lWIFMfEgc8A","n4fRZU5oEMI","CvME_EylPXU","2Wf4VRc0ETs"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidden = true
        // Do any additional setup after loading the view.
        tableCourses.tableFooterView = UIView()
        if isPlaylist {
            titleLabel.text = "Play list"
            videosArray = NSUserDefaults.standardUserDefaults().arrayForKey("Playlist") ?? []
            return
        }
        if AppDelegate.meditationsArray.count > 0{
            videosArray = AppDelegate.meditationsArray
        }
        else{
            self.getMeditationMediaServiceCall(["mode":"getmediadata"])
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        let application: UIApplication = UIApplication.sharedApplication()
        application.setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: true);
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
            self.isLogin = isLogin
        }
        logoutButton.hidden = !isLogin
        if isPlaylist {
            titleLabel.text = "Play list"
            videosArray = NSUserDefaults.standardUserDefaults().arrayForKey("Playlist") ?? []            
        }
    }
    
    func getMeditationMediaServiceCall(params : NSDictionary){
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
                            self.videosArray = tempArray;
                            for item in self.videosArray {
                                if let meditatonId = item.valueForKey("media_id") as? NSString{
                                    let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
                                    var savedTracks = Array<AnyObject>()
                                    if IAPManager.sharedManager.isProductPurchased(inAppIdentifier) {
                                        savedTracks.append(item)
                                        NSUserDefaults.standardUserDefaults().setObject(savedTracks, forKey: "Playlist")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                    }
                                    
                                }
                            }
                            self.tableCourses.reloadData();
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

    @IBAction func playVideoButtonClick(sender : UIButton){
        /*let buttonPosition : CGPoint  = sender.convertPoint(CGPointZero, toView: tableCourses)
        let indexPath : NSIndexPath = tableCourses.indexPathForRowAtPoint(buttonPosition)! as NSIndexPath
        if let mediaDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary{
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
            if let catName = mediaDic.valueForKey("name") as? NSString{
                var tempDic = NSMutableDictionary()
                if catName.isEqualToString("عش “الآن”"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.om", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.om"){
                        playerController.isPurchased = true
                    }
                }
                else if catName.isEqualToString("التوديع"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.swim", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.swim"){
                        playerController.isPurchased = true
                    }
                }
                else if catName.isEqualToString("الغضب"){
                    tempDic = NSMutableDictionary(dictionary: mediaDic)
                    tempDic.setObject("com.taamoul.meditation.sun", forKey: "identifier")
                    playerController.videoDic = tempDic
                    if identifiers.containsObject("com.taamoul.meditation.sun"){
                        playerController.isPurchased = true
                    }
                    
                }
                else if catName.isEqualToString("الغيرة"){
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
        return videosArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableCourses.dequeueReusableCellWithIdentifier("courseCell")! as UITableViewCell
        let imgCourse : UIImageView = cell.viewWithTag(100) as! UIImageView
        let indicatorView : UIActivityIndicatorView = cell.viewWithTag(102) as! UIActivityIndicatorView
        let lblCourseName : UILabel = cell.viewWithTag(101) as! UILabel
        let btnPlay : UIButton = cell.viewWithTag(104) as! UIButton
        lblCourseName.text = ""
        btnPlay.hidden = true
        if let urlStr = videosArray.objectAtIndex(indexPath.row) as? String{
            let imgUrl = "http://img.youtube.com/vi/\(urlStr)/0.jpg"
            imgCourse.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
                //btnPlay.hidden = false
            })
        }
        if let videoDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            if let catName = videoDic.valueForKey("name") as? String{
                lblCourseName.text = catName
                print(catName)
            }
            if let urlStr = videoDic.valueForKey("image_file") as? String{
                //let convertStr =  urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let convertStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                //print(convertStr)
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
        if let mediaDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            let playerController = self.storyboard?.instantiateViewControllerWithIdentifier("playerViewController") as! PlayerViewController
            playerController.isFromCourses = false
            if mediaDic.valueForKey("video_file") != nil{
                playerController.videoDic = mediaDic
            }
            if mediaDic.valueForKey("audio_file") != nil{
                playerController.videoDic = mediaDic
            }
            playerController.isPurchased = false
            playerController.videoDic = mediaDic
            if let meditatonId = mediaDic.valueForKey("media_id") as? NSString{
                let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
                playerController.productId = inAppIdentifier
                
            }
//            var identifiers = NSArray()
//            if let productIds = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
//                identifiers = productIds
//            }
//            if let meditatonId = mediaDic.valueForKey("media_id") as? NSString{
//                let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
//                if identifiers.containsObject(inAppIdentifier){
//                    playerController.isPurchased = true
//                }
//                
//            }
//            if let meditatonId = mediaDic.valueForKey("catid") as? NSString{
//                let inAppIdentifier = "taamoul_course_\(meditatonId)"
//                if identifiers.containsObject(inAppIdentifier){
//                    playerController.isPurchased = true
//                }
//                
//            }
            self.navigationController?.pushViewController(playerController, animated: true)
        }
    }
    
    func loadVideoFromUrl(urlStr : NSString, youtubePlayer : YouTubePlayerView){
        youtubePlayer.playerVars = [
            "playsinline": "1",
            "controls": "1",
            "showinfo": "0"
        ]
        youtubePlayer.loadVideoURL(NSURL(string: urlStr as String)!)
        youtubePlayer.play()
    }
    
    func loadVideoFromVideoId(videoId: NSString, youtubePlayer : YouTubePlayerView){
        youtubePlayer.playerVars = [
            "playsinline": "1",
            "controls": "1",
            "showinfo": "0"
        ]
        youtubePlayer.loadVideoID(videoId as String)
        youtubePlayer.play()
        
    }
    //MARK: YoutubePlayer Delegate Methods
    func playerReady(videoPlayer: YouTubePlayerView) {
        /*let buttonPosition : CGPoint  = videoPlayer.convertPoint(CGPointZero, fromView: tableCourses)
        let indexPath : NSIndexPath = tableCourses.indexPathForRowAtPoint(buttonPosition)! as NSIndexPath
        let cell : UITableViewCell = tableCourses.cellForRowAtIndexPath(indexPath)!
        let indicatorView : UIActivityIndicatorView = cell.viewWithTag(102) as! UIActivityIndicatorView
        indicatorView.stopAnimating()
        indicatorView.hidden = true*/
    }
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        /*let buttonPosition : CGPoint  = videoPlayer.convertPoint(CGPointZero, fromView: tableCourses)
        let indexPath : NSIndexPath = tableCourses.indexPathForRowAtPoint(buttonPosition)! as NSIndexPath
        let cell : UITableViewCell = tableCourses.cellForRowAtIndexPath(indexPath)!
        let indicatorView : UIActivityIndicatorView = cell.viewWithTag(102) as! UIActivityIndicatorView
        if playerState == .Playing{
        indicatorView.stopAnimating()
        indicatorView.hidden = true
        }*/
    }
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
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
