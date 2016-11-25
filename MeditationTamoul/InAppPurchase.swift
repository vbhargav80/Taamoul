//
//  InAppPurchase.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 11/02/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchase: NSObject,SKProductsRequestDelegate, SKPaymentTransactionObserver {

    var product: SKProduct?
    
    var productsRequest:SKProductsRequest?
    var completionHandler:((Bool,NSArray) -> Void)?
    var transactionHandler:((SKPaymentTransactionState,SKPaymentTransaction) -> Void)?
    var restoreProductsHandler:((SKPaymentQueue) -> Void)?
    var productIdentifiers:Set<String>
    var productsDict:[String:SKProduct] = [:]
    var productsArray = Array<SKProduct>()

    init(productIds:Set<String>)  {
        productIdentifiers = productIds
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    convenience override init() {
        self.init(productIds:Set([""])) // calls above mentioned controller with default name
    }
    
    // In-App Purchase Methods
    
    func requestProductsWithCompletionHandler(handler:((Bool,NSArray) -> Void)) {
        if SKPaymentQueue.canMakePayments() {
            self.completionHandler = handler
            print("Requesting products \(productIdentifiers)")
            productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productsRequest?.delegate = self
            productsRequest?.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            let viewController : UIViewController = self.superclass as! UIViewController
            viewController.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)  {
        print("Loaded list of products")
        self.productsRequest = nil
        
        let skproducts = response.products
        for product in skproducts {
            productsDict[product.productIdentifier] = product
        }
        self.completionHandler?(true, skproducts)
        completionHandler = nil
    }
    
    func request(request: SKRequest, didFailWithError error: NSError)  {
        productsRequest = nil
        self.completionHandler?(false, NSArray())
        self.completionHandler = nil
    }
    
    func buyProduct(product:SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                completeTransaction(transaction.transactionState,transaction: transaction)
                break
            case .Failed:
                failedTransaction(transaction.transactionState,transaction: transaction)
                break
            case .Restored:
                print("Restored!")
                restoreTransaction(transaction.transactionState,transaction: transaction)
                break
            case .Purchasing:
                print("Purchasing!")
            default:
                break
            }
            
        }
    }
    
    func completeTransaction(state : SKPaymentTransactionState ,transaction:SKPaymentTransaction) {
        if transactionHandler != nil{
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            transactionHandler!(state,transaction)
            transactionHandler = nil
        }
    }
    
    func failedTransaction(state : SKPaymentTransactionState,transaction:SKPaymentTransaction) {
        print("Failed transaction")
        if transaction.error != nil {
            if transaction.error!.code != 2 {
                print("Transaction error: \(transaction.error!.localizedDescription)")
            }
        } else {
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            if transactionHandler != nil{
                transactionHandler!(state,transaction)
                transactionHandler = nil
            }
        }
    }
    func restoreTransaction(state : SKPaymentTransactionState,transaction:SKPaymentTransaction) {
        print("Restore transaction")
        var userInfo:[String:String] = [:]
        let productID = transaction.payment.productIdentifier
        userInfo = ["productID":productID]
        NSNotificationCenter.defaultCenter().postNotificationName("productPurchased", object: nil, userInfo: userInfo)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        if transactionHandler != nil{
            transactionHandler!(state,transaction)
            transactionHandler = nil
        }
    }
    func restoreCompletedTransactions() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    func requestProductData()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:self.productIdentifiers as Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            let viewController : UIViewController = self.superclass as! UIViewController
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            for var i = 0; i < products.count; i++
            {
                self.product = products[i] //as? SKProduct
                self.productsArray.append(product!)
            }
        } else {
            print("No products found")
        }
        
        let  identifiers = response.invalidProductIdentifiers
        
        for product in identifiers
        {
            print("Product not found: \(product)")
        }
    }
    
    func buyProduct(sender: UIButton) {
        let payment = SKPayment(product: productsArray[sender.tag])
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }*/
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
        {
            print("Consumable Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
        {
            print("Non-Consumable Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap3"
        {
            print("Auto-Renewable Subscription Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
        {
            print("Free Subscription Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
        {
            print("Non-Renewing Subscription Product Purchased")
            // Unlock Feature
        }
    }
    
    func restorePurchases(sender: UIButton) {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("Transactions Restored")
        if let purchaseIdentifiers = NSUserDefaults.standardUserDefaults().valueForKey("purchasedIdentifiers") as? NSArray{
            let purchaseIds : NSMutableSet = NSMutableSet(array: purchaseIdentifiers as [AnyObject])
            for transaction:SKPaymentTransaction in queue.transactions {
                purchaseIds.addObject(transaction.payment.productIdentifier)
            }
            let identifiers = purchaseIds.allObjects as NSArray
            NSUserDefaults.standardUserDefaults().setObject(identifiers, forKey: "purchasedIdentifiers")
        }
        else{
            let purchaseIds = NSMutableSet()
            for transaction:SKPaymentTransaction in queue.transactions {
                purchaseIds.addObject(transaction.payment.productIdentifier)
            }
            if purchaseIds.count > 0{
                let identifiers = purchaseIds.allObjects as NSArray
                NSUserDefaults.standardUserDefaults().setObject(identifiers, forKey: "purchasedIdentifiers")
            }
        }

        if restoreProductsHandler != nil{
            restoreProductsHandler!(queue)
        }
        //var purchasedItemIDS = []
        /*for transaction:SKPaymentTransaction in queue.transactions {
            print(transaction.payment.productIdentifier)
            if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
            {
                print("Consumable Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
            {
                print("Non-Consumable Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap3"
            {
                print("Auto-Renewable Subscription Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
            {
                print("Free Subscription Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
            {
                print("Non-Renewing Subscription Product Purchased")
                // Unlock Feature
            }
        }*/
    }

    deinit{
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }

}
