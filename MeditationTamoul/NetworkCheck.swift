//
//  NetworkCheck.swift
//  BuildersHub
//
//  Created by AnilKumar Koya on 03/11/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import UIKit

public class NetworkCheck: NSObject {
    
   public class func checkNetworkConnection() -> Bool{
        do{
            let reachability : Reachability = try Reachability.reachabilityForInternetConnection()
            let networkStatus : Reachability.NetworkStatus = reachability.currentReachabilityStatus
            return !(networkStatus == Reachability.NetworkStatus.NotReachable);
        }
        catch ReachabilityError.FailedToCreateWithAddress(let address) {
            print(address)
            return false
        } catch { return false}
    }
}
