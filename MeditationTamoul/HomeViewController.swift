//
//  HomeViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 21/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,YouTubePlayerDelegate {

    @IBOutlet var collectionCourses : UICollectionView!
    @IBOutlet var tableCourses : UITableView!
    @IBOutlet var pageControl : UIPageControl!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var logoutButton: UIButton!

    @IBOutlet weak var headerView: UIView!
    
    var isLogin = false {
        didSet {
            if isViewLoaded() {
                logoutButton.hidden = !isLogin
            }
        }
    }
    var videosArray : NSArray = NSArray() {
        didSet {
            tableCourses.reloadData()
        }
    }
    
    var detailsArray: NSArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let layout: UICollectionViewFlowLayout = collectionCourses.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .Horizontal
            
        }
        collectionCourses.pagingEnabled = true
        self.getMeditationMediaServiceCall(["mode":"getcategory"])
        self.getMeditationMediaDataServiceCall(["mode":"getmediadata"])
        var headerViewFrame = headerView.frame
        headerViewFrame.size.height = 230
        headerView.frame = headerViewFrame
        tableCourses.tableHeaderView = headerView
        tableCourses.tableHeaderView = nil
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
            self.isLogin = isLogin
        }
    }
    func getMeditationMediaDataServiceCall(params : NSDictionary){
        CustomActivityIndicator.setColorAndBorderForIndicator(activityIndicator, view: self.view)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        WebServices.fetchContentOfUrlAndUrlPath(NSMutableDictionary(dictionary: params), path: "", completionHandler: { (data) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            //print(data)
            if let responseDic = data as? NSDictionary{
                if let responseCode = responseDic.valueForKey("code") as? Int{
                    if responseCode == 200{
                        if let tempArray = responseDic.valueForKey("result") as? NSArray{
                            AppDelegate.meditationsArray = tempArray;
                            self.collectionCourses.reloadData();
                        }
                    }
                    else{
                        /*if let message = responseDic.valueForKey("message") as? String{
                            self.presentViewController(TextFieldsValidation.showModalAlertView(message, okTitle: "Ok", okHandler: {(_) -> Void in}), animated: true, completion: {})
                            
                        }*/
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
        let buttonPosition : CGPoint  = sender.convertPoint(CGPointZero, toView: tableCourses)
        let indexPath : NSIndexPath = tableCourses.indexPathForRowAtPoint(buttonPosition)! as NSIndexPath
        if let categoryDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary {
            if let categoryId = categoryDic.valueForKey("catid") as? NSString{
                let categoryController = self.storyboard?.instantiateViewControllerWithIdentifier("categoryViewController") as! CategoryViewController
                categoryController.categoryDic = categoryDic
                categoryController.categoryId = categoryId
                self.navigationController?.pushViewController(categoryController, animated: true)
            }
        }
    }
    //MARK: UICollectionView Delegate Methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionCourses.frame.size.width, collectionCourses.frame.size.height)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = AppDelegate.meditationsArray.count
        pageControl.numberOfPages = count
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier  = "homeCell"
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier as String, forIndexPath: indexPath)
        if indexPath.row <= AppDelegate.meditationsArray.count-1 {
            let dicProperty : NSDictionary = AppDelegate.meditationsArray.objectAtIndex(indexPath.row) as! NSDictionary
            let imgCourse : UIImageView = collectionCell.viewWithTag(100) as! UIImageView
            let indicatorView : UIActivityIndicatorView = collectionCell.viewWithTag(102) as! UIActivityIndicatorView
            let lblCourseName : UILabel = collectionCell.viewWithTag(107) as! UILabel
            if let catName = dicProperty.valueForKey("name") as? String{
                lblCourseName.text = catName
                print(catName)
            }
            //let lblComments : UILabel = collectionCell.viewWithTag(104) as! UILabel
            if let urlStr = dicProperty.valueForKey("image_file") as? String{
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
            //lblLikes.text = "15 Likes"
            //lblComments.text = "5 Comments"
        }

        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth : CGFloat = collectionCourses.frame.size.width
        var currentPage : CGFloat = collectionCourses.contentOffset.x / pageWidth
        if (0.0 != fmodf(Float(currentPage), 1.0)) {
            currentPage = currentPage++;
            pageControl.currentPage = Int(currentPage)
            //print(Int(currentPage))
        } else {
            pageControl.currentPage = Int(currentPage)
        }
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
        lblCourseName.text = "--"
        if let urlStr = videosArray.objectAtIndex(indexPath.row) as? String{
            let imgUrl = "http://img.youtube.com/vi/\(urlStr)/0.jpg"
            imgCourse.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
                
            })
        }
        lblCourseName.text = "--"
        if let videoDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary{
            if let catName = videoDic.valueForKey("category_name") as? String{
                lblCourseName.text = "  "+catName
            }
            if let urlStr = videoDic.valueForKey("image_file") as? String{
                //print(urlStr)
                let convertStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                //print(convertStr)
                //let convertStr1 =  urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                //print(convertStr1)
                indicatorView.hidden = false
                indicatorView.startAnimating()
                imgCourse.sd_setImageWithURL(NSURL(string: convertStr!), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
                    indicatorView.hidden = true
                    indicatorView.stopAnimating()
                })
            }
            
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let categoryDic = videosArray.objectAtIndex(indexPath.row) as? NSDictionary {
            if let categoryId = categoryDic.valueForKey("catid") as? NSString{
                let categoryController = self.storyboard?.instantiateViewControllerWithIdentifier("categoryViewController") as! CategoryViewController
                let inAppIdentifier = "taamoul_course_\(categoryId)"
                categoryController.categoryIdentifier = inAppIdentifier
                categoryController.categoryDic = categoryDic
                categoryController.categoryId = categoryId
                self.navigationController?.pushViewController(categoryController, animated: true)
            }
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
