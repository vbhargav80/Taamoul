//
//  CustomActivityIndicator.swift
//  BuildersHub
//
//  Created by AnilKumar Koya on 02/11/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import Foundation

public class CustomActivityIndicator : NSObject {
    
    class func  setColorAndBorderForIndicator(activity : UIActivityIndicatorView, view: UIView){
        activity.backgroundColor = UIColor(colorLiteralRed: 250.0/255.0, green: 44.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        activity.color = UIColor.whiteColor()
        activity.frame = CGRectMake(0, 0, 40, 40);
        activity.center = view.center;
        //activity.layer.borderWidth = 1.0;
        activity.layer.cornerRadius = 5.0;
        //activity.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithRed:42.0/255.0 green:186.0/255.0 blue:187.0/255.0 alpha:1]);
        //activity.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    class func  setColorAndBorderForProgressBar(progressBar : UIProgressView, view: UIView){
        progressBar.backgroundColor = UIColor.darkGrayColor();
        //    progressBar.color=[UIColor whiteColor];
        progressBar.frame = CGRectMake(0, 0, 100, 300);
        progressBar.center = view.center;
        progressBar.layer.borderWidth = 1.0;
        progressBar.layer.cornerRadius = 3.0;
        //rgba(17,17,17,0.9) !important
        progressBar.layer.borderColor = UIColor.blackColor().CGColor;
        
    }

}