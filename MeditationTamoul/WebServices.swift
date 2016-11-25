//
//  WebServices.swift
//  BuildersHub
//
//  Created by AnilKumar Koya on 30/10/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import Foundation

//var  kAPIDomainURL : NSString = "http://52.34.199.6/taamoul/tamoul/mobile.php"
var  kAPIDomainURL : NSString = "http://www.taamoul.com/mobile.php"
//var  kAPIDomainURL : NSString = "http://taamoul.billionapps.co/tamoul/mobile.php"
public class WebServices {
    
    static var session : NSURLSession?
    static var onceToken : dispatch_once_t = 0
    
    class func dataSession() -> NSURLSession{
        
        dispatch_once(&onceToken, { () -> Void in
            session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        })
        return session!
    }
    
    class func createPOSTRequestWithUrlAndUrlPath(params : AnyObject, path : String) -> NSMutableURLRequest{
        let request : NSMutableURLRequest
        let urlString : NSString = NSString(format: "%@/%@",kAPIDomainURL,path)
        let url : NSURL = NSURL(string: urlString.stringByRemovingPercentEncoding!)!
        
        print(url)
        request = NSMutableURLRequest (URL:url)
        
        
        request.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        request.timeoutInterval = 30.0
        request.HTTPShouldHandleCookies = true
        request.HTTPMethod = "POST"
        //var error : NSError
        var jsonData : NSData = NSData()
        
        if (NSJSONSerialization.isValidJSONObject(params)){
            do {
                jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                // use anyObj here
            } catch let error as NSError {
                print("params json error: \(error.localizedDescription)")
            }
        }
        do {
            let  jsonString = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions .MutableContainers)
            // use anyObj here
            print("params: %@",jsonString)
        } catch let error as NSError {
            print("params json error: \(error.localizedDescription)")
        }
        
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.setValue(NSString(format: "%@", "application/json") as String, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue(NSString(format: "%d", jsonData.length) as String, forHTTPHeaderField: "Content-Type")
        
        
        
        return request
    }
    
    class func fetchContentOfUrlAndUrlPath(params : NSMutableDictionary, path : NSString, completionHandler:( data : AnyObject) -> Void , badRequest:(badReq: NSString) -> Void, errorHandler:(error : NSError) -> Void) {
        
        if(NetworkCheck.checkNetworkConnection()){
            let queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) { () -> Void in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    
                    //let dataTask : NSURLSessionDataTask = self.dataSession().dataTaskWithRequest(self.createPOSTRequestWithUrlAndUrlPath(params, path: path as String)), completionHandler { data, response, error in})
                    let dataTask : NSURLSessionDataTask = self.dataSession().dataTaskWithRequest(self.createPOSTRequestWithUrlAndUrlPath(params, path: path as String), completionHandler: { (data, response, error) -> Void in
                        let httpResponse  = response as? NSHTTPURLResponse
                        let responseData : NSData
                        var jsonObject : AnyObject
                        if(httpResponse != nil){
                            if(httpResponse!.statusCode == 200){
                                do {
                                    if(data != nil){
                                        responseData = data!
                                        jsonObject = try NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions .MutableContainers)
                                        // use anyObj here
                                        //print("params: %@",jsonObject)
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            completionHandler(data: jsonObject)
                                        })
                                    }
                                    
                                } catch let error as NSError {
                                    print("json error: \(error.localizedDescription)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        //completionHandler(data: data!)
                                        errorHandler(error: error)
                                    })
                                }
                            }
                            else if(httpResponse!.statusCode == 400){
                                do {
                                    if(data != nil){
                                        responseData = data!
                                        jsonObject = try NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions .MutableContainers) as! NSString
                                        // use anyObj here
                                        //print("params: %@",jsonObject)
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            badRequest(badReq: jsonObject.valueForKey("ErrorMessage") as! NSString)
                                        })
                                    }
                                    
                                } catch let error as NSError {
                                    print("json error: \(error.localizedDescription)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        badRequest(badReq:error.localizedDescription)
                                    })
                                }
                            }
                            else{
                                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                    if  (error != nil){
                                        errorHandler(error: error!)
                                    }
                                    else{
                                        badRequest(badReq:"")
                                    }
                                })
                            }
                            
                        }
                        else if let err = error{
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                errorHandler(error: err)
                            })
                        }
                        
                    })
                    dataTask.resume()
                })
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                badRequest(badReq: "The Internet connection appears to be offline")
            })
        }
    }
    
    class func createGETRequestWithUrlPath(path : NSString, params : NSMutableDictionary) -> NSMutableURLRequest {
        let request : NSMutableURLRequest
        //let urlString : NSString = NSString(format: "%@/%@",kAPIDomainURL,path)
        let urlString : NSString = path
        let url : NSURL = NSURL(string: urlString.stringByRemovingPercentEncoding!)!
        request = NSMutableURLRequest (URL:url)
        
        
        request.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        request.timeoutInterval = 30.0
        request.HTTPShouldHandleCookies = true
        request.HTTPMethod = "GET"
        //var error : NSError
        var jsonData : NSData = NSData()
        if params.count>0{
            if (NSJSONSerialization.isValidJSONObject(params)){
                do {
                    jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                    // use anyObj here
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
            }
            do {
                let  jsonString = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions .MutableContainers)
                // use anyObj here
                print("params: %@",jsonString)
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        
        request.HTTPMethod = "GET"
        request.HTTPBody = jsonData
        request.setValue(NSString(format: "%@", "application/json") as String, forHTTPHeaderField:"Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue(NSString(format: "%d", jsonData.length) as String, forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    class func getContentsOfURLPath(params : NSMutableDictionary, path : NSString, completionHandler:( data : AnyObject) -> Void , badRequest:(badReq: NSString) -> Void, errorHandler:(error : NSError) -> Void) {
        if(NetworkCheck.checkNetworkConnection()){
            let queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) { () -> Void in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    
                    //let dataTask : NSURLSessionDataTask = self.dataSession().dataTaskWithRequest(self.createPOSTRequestWithUrlAndUrlPath(params, path: path as String)), completionHandler { data, response, error in})
                    let dataTask : NSURLSessionDataTask = self.dataSession().dataTaskWithRequest(self.createGETRequestWithUrlPath( path as String, params: params), completionHandler: { (data, response, error) -> Void in
                        let httpResponse  = response as? NSHTTPURLResponse
                        let responseData : NSData
                        var jsonObject : AnyObject
                        if(httpResponse != nil){
                            if(httpResponse!.statusCode == 200){
                                do {
                                    if(data != nil){
                                        responseData = data!
                                        jsonObject = try NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions.MutableContainers)
                                        // use anyObj here
                                        //print("params: %@",jsonObject)
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            completionHandler(data: jsonObject)
                                        })
                                    }
                                    
                                } catch let error as NSError {
                                    print("json error: \(error.localizedDescription)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        completionHandler(data: data!)
                                    })
                                }
                            }
                            else if(httpResponse!.statusCode == 400){
                                do {
                                    if(data != nil){
                                        responseData = data!
                                        jsonObject = try NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions .MutableContainers) as! NSString
                                        // use anyObj here
                                        print("params: %@",jsonObject)
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            badRequest(badReq: jsonObject.valueForKey("ErrorMessage") as! NSString)
                                        })
                                    }
                                    
                                } catch let error as NSError {
                                    print("json error: \(error.localizedDescription)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        badRequest(badReq:error.localizedDescription)
                                    })
                                }
                            }
                            else {
                                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                    errorHandler(error: error!)
                                })
                            }

                            
                        }
                        else if let err = error{
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                errorHandler(error: err)
                            })
                        }
                        
                    })
                    dataTask.resume()
                })
            }
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                badRequest(badReq: "The Internet connection appears to be offline")
            })
        }

        
    }
    
}


