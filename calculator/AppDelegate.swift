//
//  AppDelegate.swift
//  calculator
//
//  Created by M A on 2019/08/29.
//  Copyright © 2019 M A. All rights reserved.
//

import UIKit
import GoogleMobileAds
import StoreKit
//import SwiftyStoreKit

@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
class AppDelegate: UIResponder, UIApplicationDelegate, PurchaseManagerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // Attach an observer to the payment queue.
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())
        // see notes below for the meaning of Atomic / Non-Atomic
//            SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
//                for purchase in purchases {
//                    switch purchase.transaction.transactionState {
//                    case .purchased, .restored:
//                        if purchase.needsFinishTransaction {
//                            // Deliver content from server, then:
//                            SwiftyStoreKit.finishTransaction(purchase.transaction)
//                        }
//                        // Unlock content
//                    case .failed, .purchasing, .deferred:
//                        break // do nothing
//                    }
//                }
//            }
        
        return true
    }
    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    // Called when the application is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Remove the observer.
        SKPaymentQueue.default().remove(PurchaseManager.sharedManager())
    }


}

