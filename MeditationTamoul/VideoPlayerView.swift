//
//  PlayerView.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 29/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreMedia

class VideoPlayerView: UIView {
    
    @IBOutlet var backButton : UIButton!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    var videoId : NSString!
    var videoUrl : NSString!
    var audioUrl : NSString!
    var audioPlayer : AVPlayer!
    var videoPlayer : AVPlayer!
    var playerLayer = AVPlayerLayer()
    
    override func awakeFromNib() {
        activityIndicator.hidden = true
      }

    func loadVideoPayer(){
        if let youtubeId = videoUrl{
            
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoPlayerView.handleTapGestureRecognizer(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            self.addGestureRecognizer(tapGestureRecognizer)
            videoPlayer = AVPlayer(URL:  NSURL(string: youtubeId as String)!)
            videoPlayer.actionAtItemEnd = .None
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayerView.playerItemDidReachEnd(_:)),name: AVPlayerItemDidPlayToEndTimeNotification,object: videoPlayer.currentItem)
            let tempPlayer = AVPlayer(URL: NSURL(string: audioUrl as String)!)
            audioPlayer = tempPlayer
            audioPlayer!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
            audioPlayer!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
            videoPlayer!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
            playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer.videoGravity = AVLayerVideoGravityResize
            //playerController.view.layer.addSublayer(layer)
            playerLayer.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayerView.playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: audioPlayer.currentItem)
            
            let videoAsset : AVAsset = (videoPlayer.currentItem?.asset)!
            let audioTracks : NSArray = videoAsset.tracksWithMediaType(AVMediaTypeVideo)
            
            // Mute all the audio tracks
            let allAudioParams = NSMutableArray()
            for track: AnyObject in audioTracks{
                // AVAssetTrack
                let audioInputParams = AVMutableAudioMixInputParameters(track:track as? AVAssetTrack)
                audioInputParams.setVolume(0.0, atTime: kCMTimeZero)
                audioInputParams.trackID = track.trackID
                allAudioParams.addObject(audioInputParams)
            }
            let audioZeroMix = AVMutableAudioMix()
            if let params  = allAudioParams as? [AVAudioMixInputParameters]{
                audioZeroMix.inputParameters = params //as! [AVAudioMixInputParameters]
                videoPlayer.currentItem?.audioMix = audioZeroMix
            }
 
            videoPlayer.play()
            audioPlayer.play()
            
            // Create a player item
            /*let playerItem = AVPlayerItem(asset: asset)
            playerItem.audioMix = audioZeroMix
            AVMutableAudioMix *audioVolMix = [AVMutableAudioMix audioMix] ;
            [audioVolMix setInputParameters:allAudioParams];
            [[avPlayer currentItem] setAudioMix:audioVolMix];*/
            self.layer.addSublayer(playerLayer)
            //self.addChildViewController(playerController)
            //self.view.addSubview(playerController.view)
            self.bringSubviewToFront(backButton)
            CustomActivityIndicator.setColorAndBorderForIndicator(activityIndicator, view: self)
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }

    }
    @IBAction func backButtonClick(sender : UIButton){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if videoPlayer != nil{
            videoPlayer.pause()
            videoPlayer.removeObserver(self, forKeyPath: "rate")
        }
        if audioPlayer != nil{
            audioPlayer.pause()
            audioPlayer.removeObserver(self, forKeyPath: "status")
            audioPlayer.removeObserver(self, forKeyPath: "rate")
            
        }
        self.removeFromSuperview()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let obj = object as? NSObject
        if obj == self.audioPlayer {
            
            if keyPath == "rate" {
                
                let rate = self.audioPlayer.rate
                if rate == 1.0 {
                    
                } else if rate == 0.0 {
                    //self.audioPlayer.pause()
                }
                
            }
            else if obj == self.audioPlayer.currentItem {
                if keyPath == "status" {
                    print("Change at keyPath = \(keyPath) for \(object)")
                    let status : AVPlayerItemStatus? = self.audioPlayer?.currentItem?.status
                    if status == AVPlayerItemStatus.Failed {
                        
                        self.audioPlayer.pause()
                        
                    } else if status == AVPlayerItemStatus.ReadyToPlay {
                        self.audioPlayer.play()
                        //self.audioPlayer.play()
                        
                    }
                }
            }
            
            if keyPath == "playbackBufferEmpty" {
                //showAlert("No internet connection!", message: "Mixmatic requires an internet connection to continue streaming.")
                print("Change at keyPath = \(keyPath) for \(object)")
            }
            
            if keyPath == "playbackLikelyToKeepUp" {
                print("Change at keyPath = \(keyPath) for \(object)")
            }
        }
        else if obj == videoPlayer{
            if keyPath == "rate" {
                let rate = self.videoPlayer.rate
                if rate == 1.0 {
                    activityIndicator.stopAnimating()
                    activityIndicator.hidden = true
                    print("Playing")
                    if audioPlayer != nil{
                        self.audioPlayer.play()
                    }
                } else if rate == 0.0 {
                    print("Pause")
                    if audioPlayer != nil{
                        self.audioPlayer.pause()
                    }
                }
            }
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        if(p.isEqual(audioPlayer.currentItem)){
            videoPlayer.pause()
            audioPlayer.pause()
        }
        else if(p.isEqual(videoPlayer.currentItem)){
            p.seekToTime(kCMTimeZero)
        }
    }
    // MARK: UIGestureRecognizer
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        if(videoPlayer.rate == 1 || audioPlayer.rate == 1){
            videoPlayer.pause()
            audioPlayer.pause()
        }
        else if(videoPlayer.rate == 0 || audioPlayer.rate == 0){
            videoPlayer.play()
            audioPlayer.play()
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
