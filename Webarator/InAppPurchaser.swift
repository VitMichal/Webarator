//
//  InAppPurchaser.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 03.05.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation
import StoreKit

private let _InAppPurchaserSharedInstance = InAppPurchaser()


class InAppPurchaser: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let noAdsProductID = "cz.VitMichal.SpeakToMe.NoAds"
    let noAdsKey = "noADSPurchased"
    
    class var sharedInstance: InAppPurchaser {
        return _InAppPurchaserSharedInstance
    }

    override init() {
        super.init();
        SKPaymentQueue.defaultQueue().addTransactionObserver(self);
    }
    
    //
    // saves a record of the transaction by storing the receipt to disk
    //
    func recordTransaction(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier==self.noAdsProductID{
            NSUserDefaults.standardUserDefaults().setValue(transaction.transactionIdentifier, forKey: "transactionIdentifier");
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    //
    // enable pro features
    //
    func provideContent(productId: NSString) {
        print("provideContent");
        if productId==self.noAdsProductID {
            print("enable noADS features");
            // enable noADS features
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.noAdsKey)
            NSUserDefaults.standardUserDefaults().synchronize();
        }
    }

    func isNoAdsPurchased() -> Bool {
        let ret = NSUserDefaults.standardUserDefaults().valueForKey(self.noAdsKey) as? Bool
        if ret != nil {
            return ret!
        } else {
            return false
        }
    }
    
    //
    // removes the transaction from the queue and posts a notification with the transaction result
    //
    func finishTransaction(transaction:SKPaymentTransaction, wasSuccessful: Bool) {
        // remove the transaction from the payment queue.
        SKPaymentQueue.defaultQueue().finishTransaction(transaction);
        
        let userInfo = NSDictionary(object: transaction, forKey: "transaction") as NSDictionary;
        
        if wasSuccessful {
            // send out a notification that we’ve finished the transaction
            NSNotificationCenter.defaultCenter().postNotificationName("kInAppPurchaseManagerTransactionFailedNotification", object: self, userInfo: userInfo as [NSObject : AnyObject])
        } else {
            // send out a notification for the failed transaction
            NSNotificationCenter.defaultCenter().postNotificationName("kInAppPurchaseManagerTransactionSucceededNotification", object: self, userInfo: userInfo as [NSObject : AnyObject])
        
        }
    }
    
    //
    // called when the transaction was successful
    //
    func completeTransaction(transaction: SKPaymentTransaction) {
        self.recordTransaction(transaction);
        self.provideContent(transaction.payment.productIdentifier);
        self.finishTransaction(transaction, wasSuccessful: true);
    }

    //
    // called when a transaction has been restored and successfully completed
    //
    func restoreTransaction(transaction: SKPaymentTransaction) {
        self.recordTransaction(transaction.originalTransaction!);
        self.provideContent(transaction.originalTransaction!.payment.productIdentifier);
        self.finishTransaction(transaction, wasSuccessful: true)
    }

    //
    // called when a transaction has failed
    //
    func failedTransaction(transaction: SKPaymentTransaction) {
        if transaction.error!.code != SKErrorPaymentCancelled {
            // error
            self.finishTransaction(transaction, wasSuccessful: false);
        } else {
            // this is fine, the user just cancelled, so don’t notify
            SKPaymentQueue.defaultQueue().finishTransaction(transaction);
        }
    }

    
    func makeProductsRequest() {
        print("About to fetch the products");
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments())
        {
            let productID:NSSet = NSSet(object: self.noAdsProductID);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String> );
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fething Products");
        }else{
            print("can not make purchases");
        }
    }
    
    func buyProduct(product: SKProduct) {
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("got the request from Apple", response.products)
        let count : Int = response.products.count
        if (count>0) {
            //var validProducts = response.products
            let validProduct: SKProduct = response.products[0] 
            if (validProduct.productIdentifier == self.noAdsProductID) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(validProduct);
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            print("nothing")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                    case .Purchased:
                        print("Product Purchased");
                        self.completeTransaction(transaction as! SKPaymentTransaction);
                        break;
                    case .Failed:
                        print("Purchased Failed");
                        self.failedTransaction(transaction as! SKPaymentTransaction);
                        break;
                    
                    case .Restored:
                        print("Purchased Restored");
                        self.restoreTransaction(transaction as! SKPaymentTransaction);
                    default:
                        print("Purchase wrong state");
                        break;
                }
            }
        }
    }

}