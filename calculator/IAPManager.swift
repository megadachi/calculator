//
//  IAPManager.swift
//  calculator
//
//  Created by M A on 01/02/2021.
//  Copyright © 2021 AnnApp. All rights reserved.
//

import UIKit
import SwiftyStoreKit

final class IAPManager: NSObject {
    
    let uds = UserDefaults.standard
    
/* 購入関係 */
    // プロダクト購入（自動課金）
    func startPurchase(productIdentifiers: String) {
        SwiftyStoreKit.retrieveProductsInfo([productIdentifiers]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { [self] result in
                    switch result {
                    // 購入成功
                    case .success(let purchase):
                        // 購入後の処理
                        print("Purchase Success: \(purchase.productId)")
                        // 購入の検証
                        verifyData(productIdentifiers: productIdentifiers)
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(result as! PaymentTransaction)
                        }
                    // 購入失敗
                    case .error(let error):
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        default: print((error as NSError).localizedDescription)
                        }
                    }
                }
            }
        }
    }
    // 過去の購入の復元（自動課金）（アップル要求条件項目）
    func startRestore(productIdentifiers: String) {
        SwiftyStoreKit.restorePurchases(atomically: true) { [self] results in
            if results.restoreFailedPurchases.count > 0 {
                // リストアに失敗
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                // リストアに成功
                print("Restore Success: \(results.restoredPurchases)")
                // 購入の検証
                verifyData(productIdentifiers: productIdentifiers)
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
            }
            else {
                // リストアするものがない
                print("Nothing to Restore")
            }
        }
    }
    // レシートの確認
    func checkReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { [self] result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                uds.set(true, forKey: "RemoveADs")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    // 購入の確認
    func verifyData(productIdentifiers: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [self] result in
            switch result {
            case .success(let receipt):
                let id = productIdentifiers
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: id,
                    inReceipt: receipt)
                switch purchaseResult {
                //リストアの成功
                case .purchased(let receiptItem):
                    print("\(id) is purchased: \(receiptItem)")
                    checkReceipt()
                //リストアの失敗
                case .notPurchased:
                    print("The user has never purchased \(id)")
//                    uds.set(false, forKey: "RemoveADs")
                }
            //エラー
            case .error(let error):
                print("Receipt verification failed: \(error)")
                uds.set(false, forKey: "RemoveADs")
            }
        }
    }
}
