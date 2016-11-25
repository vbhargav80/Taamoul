//
//  PrivacyViewController.swift
//  MeditationTamoul
//
//  Created by ALWAYSWANNAFLY on 10/1/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!
    
    let privacy_url = NSBundle.mainBundle().URLForResource("Taamoul_privacy", withExtension: "html")
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let url = privacy_url,
            let string = try? String(contentsOfURL: url) else  {
            return
        }
        webview.loadHTMLString(string, baseURL: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var menubuttonEvent: UIButton!
    @IBAction func menuButtonEvent(sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.URL else {
            return true
        }
        if url.absoluteString?.lowercaseString == "taamoul.com" {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        
        return true
    }
}
