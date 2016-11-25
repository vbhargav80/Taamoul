//
//  PlayerViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 25/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Foundation
import StoreKit

@IBDesignable class TopAlignedLabel: UILabel {
    override func drawTextInRect(rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(self.frame), CGFloat.max),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil).size
            super.drawTextInRect(CGRectMake(0, 0, CGRectGetWidth(self.frame), ceil(labelStringSize.height)))
        } else {
            super.drawTextInRect(rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //layer.borderWidth = 1
        //layer.borderColor = UIColor.blackColor().CGColor
    }
}

class PlayerViewController: UIViewController,AudioPlayerDelegate {

    //@IBOutlet var playerView : UIView!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var playPauseButton : UIButton!
    @IBOutlet var mediaImage : UIImageView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!
    @IBOutlet var progresslider : UISlider!
    @IBOutlet var currentDurationLabel : UILabel!
    @IBOutlet var totalDurationLabel : UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    var videoId : NSString!
    var videoDic : NSDictionary!
    var audioPlayer : AudioPlayer!
    let playerController = AVPlayerViewController()
    var isPurchased : Bool = false {
        didSet {
            if isViewLoaded() {
                buyNowButton.hidden = isPurchased
            }
        }
    }
    
    var isUserLogin : Bool = false
    var isFromCourses : Bool = false
    var productId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
//        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
//            isUserLogin = isLogin
//        }
        if let urlStr = videoDic.valueForKey("image_file") as? String{
            //print(urlStr)
            //let convertStr =  urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let convertStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            mediaImage.sd_setImageWithURL(NSURL(string: convertStr!), placeholderImage: UIImage(named: "Placeholder"), options: .RefreshCached, completed: { (image, error, cache, url) -> Void in
            })
        }
        self.view.bringSubviewToFront(activityIndicator)
        isPurchased = IAPManager.sharedManager.isProductPurchased(self.productId)
        self.initializingPlayerWithPurchaseState()
        //progresslider.minimumTrackTintColor = UIColor(red: 208.0/255.0, green: 51.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        //progresslider.maximumTrackTintColor = UIColor.whiteColor()
        //progresslider.thumbTintColor = UIColor(red: 223.0/255.0, green: 87.0/255.0, blue: 69.0/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
//        if let isLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as? Bool{
//            isUserLogin = isLogin
//        }
        if let price = videoDic["price"] {
            buyNowButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            buyNowButton.setTitle("BUY NOW \(price)", forState: .Normal)
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if audioPlayer != nil && audioPlayer.currentItem != nil {
            audioPlayer.playItem(audioPlayer.currentItem!)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        if audioPlayer != nil{
            audioPlayer.pause()
        }
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func shouldAutorotate() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.All.rawValue)
    }
    func canRotate(){
        
    }
    func initializingPlayerWithPurchaseState(){
        //self.alertWindow.hidden = true
        if let audioUrl = videoDic.valueForKey("video_file") as? NSString{
            if audioPlayer != nil{
                audioPlayer.pause()
            }
            audioPlayer = nil
            //print(audioUrl)
            let convertStr = audioUrl.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            /*let assetItem = AVAsset(URL: NSURL(string: convertStr! as String)!)
            let playerItem = AVPlayerItem(asset: assetItem)
            let tempPlayer = AVPlayer(playerItem: playerItem)
            tempPlayer.play()
            let duration : Float64 = CMTimeGetSeconds(tempPlayer.currentItem!.asset.duration);
            print(duration)*/
            //print(convertStr)
            audioPlayer = AudioPlayer()
            audioPlayer.delegate = self
            audioPlayer.volume = 50.0
            let item = AudioItem(mediumQualitySoundURL: NSURL(string: convertStr! as String)!)
            audioPlayer.playItem(item!)
            if let trackDesc = videoDic.valueForKey("track_desc") as? NSString{
                descriptionLabel.text = trackDesc as String
            }
            if let trackTitle = videoDic.valueForKey("name") as? String{
                titleLabel.text = "   "+trackTitle
            }
            if let trackTitle = videoDic.valueForKey("category_name") as? String{
                titleLabel.text = "   "+trackTitle
            }
            self.view.bringSubviewToFront(backButton)
            CustomActivityIndicator.setColorAndBorderForIndicator(activityIndicator, view: self.view)
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }

    }
    func playerPremiumCheckingTimer(){
        let audioplayerTime : Float = Float(audioPlayer.currentItemProgression!)
        if (audioplayerTime > 89){
            
                let  isLogin = true;
                if isLogin == true {
                    if isFromCourses == false{
                        if let meditatonId = videoDic.valueForKey("media_id") as? NSString{
                            let inAppIdentifier = "taamoul_meditation_\(meditatonId)"
                            /*if identifiers.containsObject(inAppIdentifier){
                                playerController.isPurchased = true
                            }*/
                            audioPlayer.pause()
                            self.showInAppPurchaseAlert(inAppIdentifier)
                            if audioPlayer != nil{
                                audioPlayer.pause()
                            }
                            audioPlayer.delegate = nil
                            audioPlayer = nil
                            
                        }
                    }
                    else{
                        if let categoryId = videoDic.valueForKey("catid") as? NSString{
                            let inAppIdentifier = "taamoul_course_\(categoryId)"
                            /*if identifiers.containsObject(inAppIdentifier){
                            playerController.isPurchased = true
                            }*/
                            audioPlayer.pause()
                            self.showInAppPurchaseAlert(inAppIdentifier)
                            if audioPlayer != nil{
                                audioPlayer.pause()
                            }
                            audioPlayer.delegate = nil
                            audioPlayer = nil
                            
                        }
  
                    }
                }
                else{
                    let alertView : UIAlertController = UIAlertController(title: "Taamoul", message: "Please login to continue." as String, preferredStyle: UIAlertControllerStyle.Alert)
                    //alertView.view.tag=100
                    let okAction : UIAlertAction = UIAlertAction(title:"Login" as String, style: UIAlertActionStyle.Default) { (action) -> Void in
                        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("isLogin")
                        self.navigationController?.pushViewController(loginViewController, animated: true)
                    }
                    alertView.addAction(okAction)
                    let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                        self.gobackToPreviousScreen()
                    }
                    
                    alertView.addAction(cancelAction)
                    if self.audioPlayer != nil{
                        self.audioPlayer.pause()
                    }
                    self.audioPlayer = nil
                    self.navigationController?.presentViewController(alertView, animated: true, completion: nil)

                }
            
        }
    }
    
    func showInAppPurchaseAlert( identifier : NSString){
        let alertView : UIAlertController = UIAlertController(title: "Purchase", message: "Go premium to listen full tracks." as String, preferredStyle: UIAlertControllerStyle.Alert)
        //alertView.view.tag=100
        let okAction : UIAlertAction = UIAlertAction(title:"Buy" as String, style: UIAlertActionStyle.Default) { (action) -> Void in
            self.goPremiumVideoWithInappPurchase(identifier as String,isRestore: false)
        }
        alertView.addAction(okAction)
        let restoreAction : UIAlertAction = UIAlertAction(title: "Restore", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.goPremiumVideoWithInappPurchase(identifier as String,isRestore: true)
        }
        alertView.addAction(restoreAction)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
            self.gobackToPreviousScreen()
        }
        
        alertView.addAction(cancelAction)
        self.navigationController?.presentViewController(alertView, animated: true, completion: nil)

    }
    func goPremiumVideoWithInappPurchase(identifier : String,isRestore: Bool) {
        
        func purchaseDidFinished(error: NSError?) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            if let error = error {
                let alertView : UIAlertController = UIAlertController(title: "Transaction failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                //alertView.view.tag=100
                let okAction : UIAlertAction = UIAlertAction(title:"Retry" as String, style: UIAlertActionStyle.Default) { (action) -> Void in
                    self.goPremiumVideoWithInappPurchase(identifier as String,isRestore: isRestore)
                }
                alertView.addAction(okAction)
                let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                    self.gobackToPreviousScreen()
                }
                alertView.addAction(cancelAction)
                self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
            } else {
                self.isPurchased = IAPManager.sharedManager.isProductPurchased(identifier)
                self.initializingPlayerWithPurchaseState()
                
                if(self.isPurchased){
                    // add alert here
                    self.Alert();
                }
                
            }
        }
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        if !isRestore {
            IAPManager.sharedManager.purchaseProductWithId(identifier) { (error) in
                purchaseDidFinished(error)
            }
        } else {
            IAPManager.sharedManager.restoreCompletedTransactions({ (error) in
                purchaseDidFinished(error)
            })
        }
        
        return
        /*
        inappPurchase = InAppPurchase(productIds: Set([identifier]))
        inappPurchase?.transactionHandler = {(state , transaction) in
            switch state{
            case .Purchased:
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.purchasedItemDataSaving(identifier, isRestore: isRestore, transaction: transaction)
                break
            case .Failed:
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                let alertView : UIAlertController = UIAlertController(title: "Transaction failed", message: (transaction.error?.localizedDescription)! as String, preferredStyle: UIAlertControllerStyle.Alert)
                //alertView.view.tag=100
                let okAction : UIAlertAction = UIAlertAction(title:"Retry" as String, style: UIAlertActionStyle.Default) { (action) -> Void in
                    self.goPremiumVideoWithInappPurchase(identifier as String,isRestore: isRestore)
                }
                alertView.addAction(okAction)
                let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                    self.gobackToPreviousScreen()
                }
                alertView.addAction(cancelAction)
                self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
                break
            case .Restored:
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                break
            case .Purchasing:
                self.activityIndicator.hidden = false
                break
            default:
                break
            }
        }
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        if isRestore == false{
            inappPurchase?.requestProductsWithCompletionHandler({ (status, products) -> Void in
                if (products.count > 0 && status == true){
                    let product = products.objectAtIndex(0) as! SKProduct
                    self.inappPurchase?.buyProduct(product)
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.hidden = false
                }
                else{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
            })
        } else if isRestore == true{
            self.inappPurchase?.restoreProductsHandler={(queue) in
                //let transactionQueue :SKPaymentQueue = queue
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.restoredProductsDataSaving(identifier, isRestore: isRestore, queue: queue)
            }
        }*/
    }
    
    func purchasedItemDataSaving(identifier :NSString, isRestore :Bool, transaction : SKPaymentTransaction){
        if let purchaseIdentifiers = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
            let purchaseIds : NSMutableSet = NSMutableSet(array: purchaseIdentifiers as [AnyObject])
            if transaction.payment.productIdentifier.isEmpty == false {
                purchaseIds.addObject(transaction.payment.productIdentifier)
            }
            let identifiers = purchaseIds.allObjects as NSArray
            NSUserDefaults.standardUserDefaults().setObject(identifiers, forKey: "purchasedIdentifiers")
        }
        else{
            if transaction.payment.productIdentifier.isEmpty == false {
                let purchaseIds : NSMutableSet = NSMutableSet(object: transaction.payment.productIdentifier)
                let identifiers = purchaseIds.allObjects as NSArray
                NSUserDefaults.standardUserDefaults().setObject(identifiers, forKey: "purchasedIdentifiers")
            }
            
        }
        self.isPurchased = true
        self.initializingPlayerWithPurchaseState()
    }
    
    func restoredProductsDataSaving(identifier :NSString, isRestore :Bool, queue : SKPaymentQueue){
        if queue.transactions.count == 0{
            let alertView : UIAlertController = UIAlertController(title: "Taamoul", message: "There was a problem with your purchase. Please try again later." as String, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction : UIAlertAction = UIAlertAction(title: "OK" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                self.showInAppPurchaseAlert(identifier)
            }
            alertView.addAction(cancelAction)
            self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
        }
        else{
            if let purchaseIdentifiers = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
                if  purchaseIdentifiers.containsObject(identifier){
                    let cancelAction : UIAlertAction = UIAlertAction(title: "OK" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                        self.isPurchased = true
                        self.initializingPlayerWithPurchaseState()
                    }
                    let alertView : UIAlertController = UIAlertController(title: "Thank You", message: "Your purchase(s) were restored." as String, preferredStyle: UIAlertControllerStyle.Alert)
                    alertView.addAction(cancelAction)
                    self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
                }
                else{
                    let alertView : UIAlertController = UIAlertController(title: "Taamoul", message: "There was a problem with your purchase. Please try again later." as String, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction : UIAlertAction = UIAlertAction(title: "OK" as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
                        self.showInAppPurchaseAlert(identifier)
                    }
                    alertView.addAction(cancelAction)
                    self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func volumeSliderValueChange(sender : UISlider){
        
        audioPlayer.seekToTime(Double(progresslider.value))
    }
    
    @IBAction func playPauseButtonClick(sender : UIButton){
        if audioPlayer.state == .Paused{
            //playPauseButton.setBackgroundImage(UIImage(named: "Play"), forState: .Normal)
            audioPlayer.resume()
        }
        else{
            //playPauseButton.setBackgroundImage(UIImage(named: "Pause"), forState: .Normal)
            audioPlayer.pause()
        }
    }
    @IBAction func backButtonClick(sender : UIButton){
        self.gobackToPreviousScreen()
    }
    @IBAction func buyButtonClick(sender: AnyObject) {
        showInAppPurchaseAlert(productId)
    }
    
    func gobackToPreviousScreen(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if audioPlayer != nil{
            audioPlayer.pause()
        }
        audioPlayer = nil
        //videoPlayer = nil
        let application: UIApplication = UIApplication.sharedApplication()
        application.setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: true);
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        //self.dismissViewControllerAnimated(false, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //print("presented size")
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    

    //MARK : AudioPlayer Delegate Methods
    
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        switch (audioPlayer.state) {
        case .Buffering:
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
            break
        case .Playing :
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            playPauseButton.setBackgroundImage(UIImage(named: "Pause"), forState: .Normal)
            break
        case .Paused :
            playPauseButton.setBackgroundImage(UIImage(named: "Play"), forState: .Normal)
            break
        case .Stopped :
            playPauseButton.setBackgroundImage(UIImage(named: "Play"), forState: .Normal)
            break
        case .WaitingForConnection :
            break
        case .Failed(_) :
            break
        //default:
            //break
        }
        print(audioPlayer.state)
        
    }
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        
    }
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        progresslider.value = Float(audioPlayer.currentItemProgression!)
        currentDurationLabel.text = self.stringFromTimeInterval((audioPlayer.currentItemProgression!)) as String
        let remainingTime = audioPlayer.currentItemDuration! - audioPlayer.currentItemProgression!
        totalDurationLabel.text = NSString(format: "-%@", self.stringFromTimeInterval(remainingTime)) as String
        if (isPurchased == false){
            self.playerPremiumCheckingTimer()
        }
    }
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        progresslider.minimumValue = 0.0
        if audioPlayer.currentItemDuration != nil{
            progresslider.maximumValue = Float(audioPlayer.currentItemDuration!)
            totalDurationLabel.text = self.stringFromTimeInterval((audioPlayer.currentItemDuration!)) as String
        }
        
    }
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        
    }
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem) {
        if audioPlayer.currentItemDuration != nil{
            progresslider.maximumValue = Float(audioPlayer.currentItemDuration!)
            //totalDurationLabel.text = self.stringFromTimeInterval((audioPlayer.currentItemDuration!)) as String
        }
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        //var ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        //let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
        //return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }

    //Then in your UIResponder (or your AppDelegate if you will)
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            audioPlayer.remoteControlReceivedWithEvent(event)
        }
    }
    // MARK: UIGestureRecognizer
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        /*if(audioPlayer.rate == 1){
            audioPlayer.pause()
        }
        else if(audioPlayer.rate == 0){
            audioPlayer.resume()
        }*/
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
    
    
    @IBAction func Alert()
    {
        let alertController = UIAlertController(title: "Congratulations", message: "Congratulations! You have unlocked this track. You can enjoy it across all of your iOS devices!", preferredStyle:UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
        { action -> Void in
            // Put your code here
            })
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

}
