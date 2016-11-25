//
//  ViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 20/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var txtUseName : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var signUpbutton: UIButton!
    @IBOutlet weak var dontHaveAccountLb: UILabel!
    override func viewDidLoad() {
        //    passcode = 092Dk
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        activityIndicator.hidden = true
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.txtUseName.placeholder = "hint_email".localized()
            self.txtPassword.placeholder = "hint_pwd".localized()
            self.signInButton.setTitle("signin".localized(), forState: .Normal)
            self.signUpbutton.setTitle("signup".localized(), forState: .Normal)
            self.skipButton.setTitle("Skip", forState: .Normal)
            self.dontHaveAccountLb.text = "dont_have_acount".localized()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.clearTextfields()
    }

    func clearTextfields(){
        txtPassword.text = ""
        txtUseName.text = ""
    }
    func upload2(image : UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.3)
        let url = NSURL(string:"http://49.205.65.37:8080/smart-city/api/posts")!
        print(url)
        let request = NSMutableURLRequest(URL: url)
        //var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let boundary = "---------------------------14737809831466499882746641449"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        print(contentType)
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("'Bearer'5627fd08-c2f7-479f-b7d4-72eea4600b0a", forHTTPHeaderField: "Authorization")

        print(request.allHTTPHeaderFields)
        
        let body = NSMutableData()
        
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"field_name\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("field_mobileinfo_image".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"files[field_mobileinfo_image]\"; filename=\"img.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData!)
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        var response: NSURLResponse? = nil
        var reply = NSData()
        do {
            reply = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
            let returnString = NSString(data: reply, encoding: NSUTF8StringEncoding)
            print("returnString \(returnString)")
        } catch {
            print("ERROR")
        }
        
        
        
    }
    func userLoginServiceCall(params : NSMutableDictionary){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        CustomActivityIndicator.setColorAndBorderForIndicator(activityIndicator, view: self.view)
        WebServices.fetchContentOfUrlAndUrlPath(params, path: "", completionHandler: { (data) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            //print(data)
            self.txtUseName.text = ""
            self.txtPassword.text = ""
            if let responseDic = data as? NSDictionary{
                if let responseCode = responseDic.valueForKey("code") as? Int{
                    if responseCode == 200{
                        /*if let message = responseDic.valueForKey("message") as? String{
                            self.presentViewController(TextFieldsValidation.showModalAlertView(message, okTitle: "Ok", okHandler: {(_) -> Void in }), animated: true, completion: {})
                        }*/
                        self.clearTextfields()
                        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meditationViewController") as! MeditationsViewController
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
                        //NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isVerified")
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLogin")
                        self.navigationController?.pushViewController(homeViewController, animated: true)
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
    
    @IBAction func signInButtonClick( sender : UIButton){
        if(!(TextFieldsValidation.validateEmailWithString(txtUseName!.text!))){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter a valid email id.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
        }
        else if(TextFieldsValidation.isNullString(txtPassword!.text!)){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter a valid password.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
        }
        else{
            txtUseName.resignFirstResponder()
            txtPassword.resignFirstResponder()
            if AppDelegate.deviceToken.length > 0{
                self.userLoginServiceCall(NSMutableDictionary(dictionary: ["mode":"login","emailid":txtUseName!.text!,"passcode":txtPassword!.text!,"devicetoken":AppDelegate.deviceToken as String]))
            }
            else{
                self.userLoginServiceCall(NSMutableDictionary(dictionary: ["mode":"login","emailid":txtUseName!.text!,"passcode":txtPassword!.text!,"devicetoken":""]))
            }
        }

        //let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        //self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    @IBAction func signUpButtonClick(sender : UIButton){
        let signUpController = self.storyboard?.instantiateViewControllerWithIdentifier("signUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    @IBAction func skipLoginButttonClick(sender : UIButton){
        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("meditationViewController") as! MeditationsViewController
        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isVerified")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLogin")
        self.navigationController?.pushViewController(homeViewController, animated: true)

    }
    //MARK: UITextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == txtUseName{
            scrollView?.contentOffset = CGPointMake(0, 90)
        }
        else if textField == txtPassword{
            scrollView?.contentOffset = CGPointMake(0, 130)
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView?.contentOffset = CGPointMake(0,0)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

