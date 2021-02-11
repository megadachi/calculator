//
//  ProductManager.swift
//  calculator
//
//  Created by M A on 18/01/2021.
//  Copyright © 2021 AnnApp. All rights reserved.
//

import UIKit
import Foundation
import StoreKit
    
private var productManagerShared : Set<ProductManager> = Set()
// 商品情報を取得する責務を持つクラス
final class ProductManager: NSObject, SKProductsRequestDelegate {
    private var completionForProductidentifiers : (([SKProduct]?,NSError?) -> Void)?
    // 課金アイテム情報を取得
    class func productsWithID(productIdentifiers : [String]!,completion:(([SKProduct]?,NSError?) -> Void)?){
        let productManager = ProductManager()
        productManager.completionForProductidentifiers = completion
        // Initialize the product request with the above identifiers.
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        // App Storeへ商品情報の取得を開始する
        productRequest.start()
        productManagerShared.insert(productManager)
    }
/* MARK: - SKProducts Request Delegate */
    // アイテム情報の取得が完了すると呼ばれる
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
        var error : NSError? = nil
        // responseオブジェクトに購入可能なアイテムの情報がわたってくるのでその情報を使って購入処理を開始
        // "products" contains products whose identifiers have been recognized by the App Store.
        if response.products.isEmpty {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"There are no products available.".localized])
        }
        if response.invalidProductIdentifiers.count > 0 {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"Invalid product idntifier.".localized])
        }
            self.completionForProductidentifiers?(response.products, error)
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            let error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"Product infomation does not exist.".localized])
            self.completionForProductidentifiers?(nil,error)
        productManagerShared.remove(self)
        }
    }
    // 処理修了
    func requestDidFinish(_ request: SKRequest) {
        productManagerShared.remove(self)
    }
/* MARK: - Utility */
    // 価格情報を抽出
    class func priceStringFromProduct(product: SKProduct!) -> String {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)!
    }
}

