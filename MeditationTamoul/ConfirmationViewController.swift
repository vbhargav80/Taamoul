//
//  ConfirmationViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 21/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet var txtVerifyCode : UITextField!
    var password = NSString()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        if let passcode = NSUserDefaults.standardUserDefaults().valueForKey("verifyCode") as? String{
            password = passcode
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
    }

    //MARK: Button Click Methods f1925
    
    @IBAction func signUpButtonClick(sender : UIButton){
        
        if password.length > 0{
            if ((TextFieldsValidation.comparePassword(password, password: txtVerifyCode.text!))){
                let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
                NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
                self.navigationController?.pushViewController(homeViewController, animated: true)
            }
        }
    }
    
    @IBAction func resendButtonClick(sender : UIButton){
        
    }
    
    @IBAction func signInButtonClick(sender : UIButton){
        let signinController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.navigationController?.pushViewController(signinController, animated: true)
        
    }
    
    @IBAction func backButtonClick(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    //MARK: UITextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
