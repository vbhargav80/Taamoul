//
//  TextFieldsValidation.swift
//  BuildersHub
//
//  Created by AnilKumar Koya on 04/11/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import UIKit

public class TextFieldsValidation: NSObject
{
   

    class func validateEmailWithString(email: NSString) -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" as NSString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex) as NSPredicate
        return emailTest.evaluateWithObject(email)
        
    }
    
    class func validatePasswordWithString(password: NSString) -> Bool{
        let passwordRegex = "^$|^[^[:space:]]{0,20}$" as NSString
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex) as NSPredicate
        return passwordTest.evaluateWithObject(password)
    }
    
    class func mobileNumberValidation(mobileNumber: NSString) -> Bool{
        //let mobileNumberRegex = "[789][0-9]{9}" as NSString
        let mobileNumberRegex = "[0-9][0-9]{9}" as NSString
        let mobileNumberTest = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex) as NSPredicate
        return mobileNumberTest.evaluateWithObject(mobileNumber)
        
    }
    class func validateUsernameTF(username: NSString) -> Bool{
        let usernamePattern = "[A_Z0-9a-z  !@#$%^&()]{4,20}" as NSString
        let filter = NSPredicate(format: "SELF MATCHES %@", usernamePattern) as NSPredicate
        return filter.evaluateWithObject(username)
        
    }
    
    class func isNullString(var string : NSString) -> Bool {
        if(!(string.isKindOfClass(NSNull))){
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        if(string == NSNull() || string.length == 0 || string.isEqualToString("") || string.isEqualToString("(null)") || string.isEqualToString("<null>")){
            return true
        }
        return false
    }
    
    class func trimString( oldString : NSString) -> NSString {
        return oldString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    class func comparePassword(compare : NSString, password : NSString) -> Bool {
        return compare.isEqualToString(password as String)
    }
    
    class func validateCreditCardString(cardNumber : NSString) -> Bool {
        let illegalCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet as NSCharacterSet
        let components = cardNumber.componentsSeparatedByCharactersInSet(illegalCharacters) as NSArray
        let formattedString = components.componentsJoinedByString("") as NSString
        
        if (formattedString == NSNull() || formattedString.length < 16 || formattedString.length > 19) {
            return false;
        }

        let reversedString = NSMutableString(capacity: formattedString.length)
        let opts : NSStringEnumerationOptions =  [NSStringEnumerationOptions.Reverse , NSStringEnumerationOptions.ByComposedCharacterSequences]

        formattedString.enumerateSubstringsInRange(NSMakeRange(0, formattedString.length), options: opts ) { (substring, substringRange, enclosingRange, stop) -> Void in
            reversedString.appendString(substring!)
        }
        
        var evenSum = 0 as Int
        var oddSum = 0 as Int
        
        for i in 0..<reversedString.length {
            let digit : NSInteger = NSString(format: "%C", reversedString.characterAtIndex(i)).integerValue
            
            if (i % 2 == 0) {
                evenSum += digit;
            }
            else {
                oddSum += digit / 5 + (2 * digit) % 10;
            }

        }
        return (oddSum + evenSum) % 10 == 0;
    }
    
    class func showModalAlertView(message : NSString,okTitle : NSString, okHandler:(alertControl : UIAlertController) -> Void) -> UIAlertController{
        
        let alertView : UIAlertController = UIAlertController(title: "Taamoul", message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        //alertView.view.tag=100
        let okAction : UIAlertAction = UIAlertAction(title: okTitle as String, style: UIAlertActionStyle.Default) { (action) -> Void in
            if let handler:() = okHandler(alertControl: alertView){
                handler
            }
        }
        alertView.addAction(okAction)
        return alertView
    }
    
    class func showModalAlertView(message : NSString,cancelTitle : NSString,okTitle : NSString, cancelHandler:(alertControl : UIAlertController) -> Void, okHandler:(alertControl : UIAlertController) -> Void) -> UIAlertController{
        
        let alertView : UIAlertController = UIAlertController(title: "Taamoul", message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        //alertView.view.tag=100
        let okAction : UIAlertAction = UIAlertAction(title: okTitle as String, style: UIAlertActionStyle.Default) { (action) -> Void in
            if let handler:() = okHandler(alertControl: alertView){
                handler
            }
        }
        alertView.addAction(okAction)
        let cancelAction : UIAlertAction = UIAlertAction(title: cancelTitle as String, style: UIAlertActionStyle.Cancel) { (action) -> Void in
            if let handler:() = cancelHandler(alertControl: alertView){
                handler
            }
        }
        
        alertView.addAction(cancelAction)
        return alertView
    }
    class func getUserId() -> NSString {
        var userId = NSString()
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("userloggedin") == true{
            if(defaults.valueForKey("UserId") != nil){
                userId = defaults.valueForKey("UserId") as! String
            }
            else{
                userId = ""
            }
        }
        else{
            if(defaults.valueForKey("builderId") != nil){
                userId = defaults.valueForKey("builderId") as! String
            }
            else{
                userId = ""
            }
        }
        return userId
    }
    class func getUserPerferencesDictionary() -> NSDictionary {
        let preferencesDic = NSMutableDictionary()
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("userloggedin") == true{
            if(defaults.valueForKey("UserId") != nil){
                preferencesDic.setObject(defaults.valueForKey("UserId")!, forKey: "userId")
            }
            else{
                preferencesDic.setObject("", forKey: "userId")
            }
            if(defaults.valueForKey("city") != nil){
                preferencesDic.setObject(defaults.valueForKey("city") as! String, forKey: "city")
                //preferencesDic.setObject("Hyderabad", forKey: "city")

            }
            else{
                //preferencesDic.setObject("", forKey: "city")
            }
            if(defaults.valueForKey("area") != nil){
                preferencesDic.setObject(defaults.valueForKey("area") as! String, forKey: "area")
                //preferencesDic.setObject("Gachibowli", forKey: "area")
            }
            else{
                //preferencesDic.setObject("", forKey: "area")
            }
            if(defaults.valueForKey("size") != nil){
                preferencesDic.setObject(defaults.valueForKey("size") as! String, forKey: "size")
            }
            else{
                //preferencesDic.setObject("", forKey: "size")
            }
            if(defaults.valueForKey("other") != nil){
                preferencesDic.setObject(defaults.valueForKey("other") as! String, forKey: "other")
            }
            else{
                //preferencesDic.setObject("", forKey: "other")
            }
            if(defaults.valueForKey("price") != nil){
                preferencesDic.setObject(defaults.valueForKey("price") as! String, forKey: "price")
            }
            else{
                //preferencesDic.setObject("", forKey: "price")
            }
            if(defaults.valueForKey("propertyType") != nil){
                preferencesDic.setObject(defaults.valueForKey("propertyType") as! String, forKey: "propertyType")
            }
            else{
                //preferencesDic.setObject("", forKey: "propertyType")
            }
            
            if(defaults.valueForKey("noofBedrooms") != nil){
                preferencesDic.setObject(defaults.valueForKey("noofBedrooms") as! String, forKey: "noofBedrooms")
                
            }
            else{
                //preferencesDic.setObject("", forKey: "noofBedrooms")
            }
            
            if(defaults.valueForKey("amenities") != nil){
                preferencesDic.setObject(defaults.valueForKey("amenities") as! String, forKey: "amenities")
            }
            else{
                //preferencesDic.setObject("", forKey: "amenities")
            }
            if(defaults.valueForKey("latitude") != nil){
                preferencesDic.setObject(defaults.valueForKey("latitude") as! String, forKey: "latitude")
            }
            else{
                //preferencesDic.setObject("", forKey: "latitude")
            }
            if(defaults.valueForKey("longitude") != nil){
                preferencesDic.setObject(defaults.valueForKey("longitude") as! String, forKey: "longitude")
            }
            else{
                //preferencesDic.setObject("", forKey: "longitude")
            }
        }
        else{
            if(defaults.valueForKey("builderId") != nil){
                preferencesDic.setObject(defaults.valueForKey("builderId")!, forKey: "builderId")
            }
            else{
                preferencesDic.setObject("", forKey: "builderId")
            }
            if(defaults.valueForKey("builderName") != nil){
                preferencesDic.setObject(defaults.valueForKey("builderName")!, forKey: "builderName")
            }
            else{
                preferencesDic.setObject("", forKey: "builderName")
            }
            if(defaults.valueForKey("projectsCount") != nil){
                preferencesDic.setObject(defaults.valueForKey("projectsCount")!, forKey: "projectsCount")
            }
            else{
                preferencesDic.setObject("", forKey: "projectsCount")
            }
            if(defaults.valueForKey("builderImage") != nil){
                preferencesDic.setObject(defaults.valueForKey("builderImage")!, forKey: "builderImage")
            }
            else{
                preferencesDic.setObject("", forKey: "builderImage")
            }

        }
        return preferencesDic

    }
}
