//
//  IAPManager.swift
//  MeditationTamoul
//
//  Created by ALWAYSWANNAFLY on 9/25/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import Foundation
import StoreKit

public typealias RestoreTransactionsCompletionBlock = NSError? -> Void
public typealias LoadProductsCompletionBlock = (Array<SKProduct>?, NSError?) -> Void
public typealias PurchaseProductCompletionBlock = (NSError?) -> Void
public typealias LoadProductsRequestInfo = (request: SKProductsRequest, completion: LoadProductsCompletionBlock)
public typealias PurchaseProductRequestInfo = (productId: String, completion: PurchaseProductCompletionBlock)

public class IAPManager: NSObject {
    public static let sharedManager = IAPManager()
    
    override init() {
        super.init()
        
        restorePurchasedItems()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAPManager.savePurchasedItems), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    public func canMakePayments() -> Bool {
        if SKPaymentQueue.canMakePayments() {
            // check connection
            let hostname = "appstore.com"
            let hostinfo = gethostbyname(hostname)
            return hostinfo != nil
        }
        return false
    }
    
    public func isProductPurchased(productId: String) -> Bool {
        return purchasedProductIds.contains(productId)
    }
    
    public func restoreCompletedTransactions(completion: RestoreTransactionsCompletionBlock) {
        restoreTransactionsCompletionBlock = completion
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    public func loadProductsWithIds(productIds: Array<String>, completion:LoadProductsCompletionBlock) {
        var loadedProducts = Array<SKProduct>()
        var remainingIds = Array<String>()
        
        for productId in productIds {
            if let product = availableProducts[productId] {
                loadedProducts.append(product)
            } else {
                remainingIds.append(productId)
            }
        }
        
        if remainingIds.count == 0 {
            completion(loadedProducts, nil)
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(remainingIds))
        request.delegate = self
        loadProductsRequests.append(LoadProductsRequestInfo(request: request, completion: completion))
        request.start()
    }
    
    public func purchaseProductWithId(productId: String, completion: PurchaseProductCompletionBlock) {
        if !canMakePayments() {
            let error = NSError(domain: "inapppurchase", code: 0, userInfo: [NSLocalizedDescriptionKey: "In App Purchasing is unavailable"])
            completion(error)
        } else {
            loadProductsWithIds([productId]) { (products, error) -> Void in
                if error != nil {
                    completion(error)
                } else {
                    if let product = products?.first {
                        self.purchaseProduct(product, completion: completion)
                    }
                }
            }
        }
    }
    
    public func purchaseProduct(product: SKProduct, completion: PurchaseProductCompletionBlock) {
        purchaseProductRequests.append(PurchaseProductRequestInfo(productId: product.productIdentifier, completion: completion))
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    private func callLoadProductsCompletionForRequest(request: SKProductsRequest, responseProducts:Array<SKProduct>?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            for i in 0..<self.loadProductsRequests.count {
                let requestInfo = self.loadProductsRequests[i]
                if requestInfo.request == request {
                    self.loadProductsRequests.removeAtIndex(i)
                    requestInfo.completion(responseProducts, error)
                    return
                }
            }
        }
    }
    
    private func callPurchaseProductCompletionForProduct(productId: String, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            for i in 0..<self.purchaseProductRequests.count {
                let requestInfo = self.purchaseProductRequests[i]
                if requestInfo.productId == productId {
                    self.purchaseProductRequests.removeAtIndex(i)
                    requestInfo.completion(error)
                    return
                }
            }
        }
    }
    
    private var availableProducts = Dictionary<String, SKProduct>()
    private var purchasedProductIds = Array<String>()
    private var restoreTransactionsCompletionBlock: RestoreTransactionsCompletionBlock?
    private var loadProductsRequests = Array<LoadProductsRequestInfo>()
    private var purchaseProductRequests = Array<PurchaseProductRequestInfo>()
    
}

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        for product in response.products {
            availableProducts[product.productIdentifier] = product
        }
        
        callLoadProductsCompletionForRequest(request, responseProducts: response.products, error: nil)
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError) {
        if let productRequest = request as? SKProductsRequest {
            callLoadProductsCompletionForRequest(productRequest, responseProducts: nil, error: error)
        }
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let productId = transaction.payment.productIdentifier
            switch transaction.transactionState {
            case .Restored: fallthrough
            case .Purchased:
                purchasedProductIds.append(productId)
                savePurchasedItems()
                
                callPurchaseProductCompletionForProduct(productId, error: nil)
                queue.finishTransaction(transaction)
            case .Failed:
                callPurchaseProductCompletionForProduct(productId, error: transaction.error)
                queue.finishTransaction(transaction)
            case .Purchasing:
                print("Purchasing \(productId)...")
            default: break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        for item in queue.transactions {
            let productId = item.payment.productIdentifier
            if !purchasedProductIds.contains(productId) {
                purchasedProductIds.append(productId)
            }
        }
        if let completion = restoreTransactionsCompletionBlock {
            completion(nil)
        }
    }
    
    public func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        if let completion = restoreTransactionsCompletionBlock {
            completion(error)
        }
    }
}

extension IAPManager { // Store file managment
    
    func purchasedItemsFilePath() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        return  (NSURL(string: documentsDirectory)!.URLByAppendingPathComponent("purchased.plist")!.path)!
    }
    
    func restorePurchasedItems()  {
        if let items = NSKeyedUnarchiver.unarchiveObjectWithFile(purchasedItemsFilePath()) as? Array<String> {
            purchasedProductIds.appendContentsOf(items)
        }
    }
    
    func savePurchasedItems() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(purchasedProductIds)
        var error: NSError?
        do {
            try data.writeToFile(purchasedItemsFilePath(), options: [.AtomicWrite, .DataWritingFileProtectionComplete])
        } catch let error1 as NSError {
            error = error1
            print("Failed to save purchased items: \(error)")
        }
    }
}
