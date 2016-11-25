//
//  ContactUsViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 25/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController,HPGrowingTextViewDelegate,MFMailComposeViewControllerDelegate{

    @IBOutlet var txtFullName : UITextField!
    @IBOutlet var txtEmailAddress : UITextField!
    @IBOutlet var txtViewComments : HPGrowingTextView!
    @IBOutlet var scrollView : UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        txtViewComments.isScrollable = true;
        txtViewComments.contentInset = UIEdgeInsetsMake(0, 3, 0, 3);
        txtViewComments.minNumberOfLines = 1;
        txtViewComments.maxNumberOfLines = 4;
        txtViewComments.font = UIFont.systemFontOfSize(15.0)
        txtViewComments.delegate = self;
        txtViewComments.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        txtViewComments.textAlignment = .Left;
        txtViewComments.textColor = UIColor.whiteColor()
        txtViewComments.placeholder = "Enter your comments here!";
        txtViewComments.backgroundColor = UIColor.clearColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        //if self.isBeingDismissed() || self.isMovingFromParentViewController() || self.isMovingToParentViewController(){}
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

    @IBAction func sendCommentsButtonClick(sender : UIButton){
        if(TextFieldsValidation.isNullString(txtFullName!.text!)){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter a valid name.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
        }
        else if(!(TextFieldsValidation.validateEmailWithString(txtEmailAddress!.text!))){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter a valid email id.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
        }
        else if((TextFieldsValidation.isNullString(txtViewComments!.text!))){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter comment.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
        }
            /*else if(TextFieldsValidation.isNullString(txtPassword!.text!)){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Please enter a valid password.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
            }
            else if(!(TextFieldsValidation.comparePassword(txtPassword.text!, password: txtComfirmPassword.text!))){
            self.presentViewController( TextFieldsValidation.showModalAlertView("Password and confirm password mismatched.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
            }*/
        else{
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.presentViewController( TextFieldsValidation.showModalAlertView("Your device could not send e-mail.  Please check e-mail configuration and try again.", okTitle: "Ok", okHandler: {(_) in }), animated: true, completion: nil)
            }
            self.presentViewController(TextFieldsValidation.showModalAlertView("Your comments posted successfully.", okTitle: "Ok", okHandler: { (alertControl) -> Void in
                self.txtFullName.text = ""
                self.txtEmailAddress.text = ""
                self.txtViewComments.text = ""
            }), animated: true, completion: nil)
            if AppDelegate.deviceToken.length > 0{
                
            }
            else{
            }
        }

    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([txtEmailAddress.text!])
        mailComposerVC.setSubject("Tamoul")
        mailComposerVC.setMessageBody(txtViewComments.text!, isHTML: false)
        
        return mailComposerVC
    }
    //MARK: GrowingTextView Delegate Methods
    
    func growingTextView(growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        /*let diff : Float = (Float(growingTextView.frame.size.height) - height);
        
        var r :  CGRect  = commentsContainerView.frame;
        r.size.height -= CGFloat(diff)
        r.origin.y += CGFloat(diff);
        commentsContainerView.frame = r;*/
        
    }
    
    func growingTextViewShouldReturn(growingTextView: HPGrowingTextView!) -> Bool {
        txtViewComments.resignFirstResponder()
        return true
    }
    func growingTextViewDidBeginEditing(growingTextView: HPGrowingTextView!) {
        scrollView?.contentOffset = CGPointMake(0, 115)
    }
    func growingTextViewDidEndEditing(growingTextView: HPGrowingTextView!) {
        scrollView?.contentOffset = CGPointMake(0, 0)
    }
    
    //MARK: UITextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == txtFullName){
            scrollView?.contentOffset = CGPointMake(0, 80)
        }

       else if (textField == txtEmailAddress){
            scrollView?.contentOffset = CGPointMake(0, 90)
        }
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView?.contentOffset = CGPointMake(0, 0)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
