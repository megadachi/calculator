//
//  PurchaseManager.swift
//  calculator
//
//  Created by M A on 18/01/2021.
//  Copyright © 2021 AnnApp. All rights reserved.
//

import UIKit
import StoreKit
import ASN1Decoder

private let purchaseManagerShared = PurchaseManager()
// アイテムの購入を処理するためのプロトコル
class PurchaseManager : NSObject,SKPaymentTransactionObserver, SKRequestDelegate {
    
    var delegate : PurchaseManagerDelegate?
    // プロダクトID
    fileprivate var productIdentifier : String?
    // レシート検証ステータス
    var receiptCheck = false
    enum ReceiptValidationError : Error {
        case couldNotFindReceipt
        case emptyReceiptContents
        case receiptNotSigned
        case appleRootCertificateNotFound
        case receiptSignatureInvalid
    }
    // Initialize the store observer.
        override init() {
            super.init()
        }
    // シングルトン
    class func sharedManager() -> PurchaseManager{
        return purchaseManagerShared;
    }
/* 課金処理 */
    // 課金開始
    func startWithProduct(_ product : SKProduct){
        print("InnApp : PurchaseManager startWithProduct")
        // configures the app to make payments on the device, before presenting products for sale
        //エラーがあれば終了
        if SKPaymentQueue.canMakePayments() == false {
            let errorMessage = "Purchase is not valid.".localized
            let error = NSError(domain: "PurchaseErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey:errorMessage])
            self.delegate?.purchaseManagerDidFailedPurchase?(self)
            print("error",error)
            print("InnApp : PurchaseManager" + errorMessage)
            return
        }
        print("InnApp : PurchaseManager startWithProduct CheckSupendedTransactions")
        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }
                if transaction.payment.productIdentifier == product.productIdentifier {
                    if let window = UIApplication.shared.delegate?.window {
                        let ac = UIAlertController(title: nil, message: "Purchase was on the way.\nContinue to download for free.".localized, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Continue".localized, style: UIAlertAction.Style.default, handler: {[weak self] (action : UIAlertAction!) -> Void in
                            if let weakSelf = self {
                                weakSelf.productIdentifier = product.productIdentifier
                                weakSelf.completeTransaction(transaction)
                            }
                            })
                        ac.addAction(action)
                        window!.rootViewController?.present(ac, animated: true, completion: nil)
                        return
                    }
                }
            }
        }
        //課金処理開始
        print("InnApp : PurchaseManager startWithProduct MakeNewTransaction", product.productIdentifier)
        // Create a Payment Request
        let payment = SKMutablePayment(product: product)
        // Submit a Payment Request
        SKPaymentQueue.default().add(payment)
        self.productIdentifier = product.productIdentifier
    }
/* MARK: - SKPaymentTransactionObserver, create an Observer */
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //課金状態が更新されるたびに呼ばれる
        for transaction in transactions {
            print("InnApp : PurchaseManager updatedTransactions", transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .purchasing :
                //課金中 処理中であることがわかるようにインジケータをだす
                print("InnApp : PurchaseManager Purchasing")
                break
            case .purchased :
                //課金完了 レシートの確認やアイテムの付与を行う
                self.completeTransaction(transaction)
                verifySignature()
                if receiptCheck == true {
                    verifyID()
                }
                break
            case .failed :
                    //課金失敗 エラーが発生したことをユーザに知らせる
                    self.failedTransaction(transaction)
//                }
                break
            case .restored :
                //リストア
                self.restoreTransaction(transaction)
                verifySignature()
                if receiptCheck == true {
                    verifyID()
                }
                break
            case .deferred :
                //承認待ち
                self.deferredTransaction(transaction)
                break
            @unknown default:
                break
            }
        }
    }
/* MARK: - SKPaymentTransaction process */
    fileprivate func completeTransaction(_ transaction : SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            self.productIdentifier = nil
        } else {
            //課金終了(以前中断された課金処理)
            self.delegate?.purchaseManager?(self, didFinishUntreatedPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
    fileprivate func failedTransaction(_ transaction : SKPaymentTransaction) {
        print("InnApp : PurchaseManager failedTransaction")
        //課金失敗
        self.delegate?.purchaseManagerDidFailedPurchase?(self)
//        if transaction.payment.productIdentifier == self.productIdentifier {
            self.productIdentifier = nil
//            }
        SKPaymentQueue.default().finishTransaction(transaction)
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            delegate?.purchaseManagerDidFailedPurchase!(self)
        }
    }
    fileprivate func restoreTransaction(_ transaction : SKPaymentTransaction) {
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction.original, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }
    fileprivate func deferredTransaction(_ transaction : SKPaymentTransaction) {
        //承認待ち
        self.delegate?.purchaseManagerDidDeferred?(self)
//        if transaction.payment.productIdentifier == self.productIdentifier {
            self.productIdentifier = nil
//            }
    }
    // 全ての購入処理が終わったとき
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
    print("InnApp : PurchaseManager removedTransactions")
    }
/* Restore Purchase Functions & Delegates */
    // リストア開始
    func startRestore(){
        print("InnApp : PurchaseManager startRestore")
        // Create a receipt refresh request
        DispatchQueue.main.async {
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
        }
//            SKPaymentQueue.default().add(self)
        // initWithReceiptProperties:メソッドの値を参照する
            SKPaymentQueue.default().restoreCompletedTransactions()
//        } else {
//            print("InnApp : PurchaseManager startRestore Second")
//            self.isRestore = false
//            let error = NSError(domain: "PurchaseErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"Restore on the way".localized])
//            self.delegate?.purchaseManagerDidFailedRestore?(self)
//        }
    }
    //リストア失敗時に呼ばれる
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("InnApp : PurchaseManager restoreCompletedTransactionFailed")
        // アラート表示
        delegate?.purchaseManagerDidFailedRestore?(self)
    }
    // 購入履歴が確認できた場合、復元する
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("InnApp : PurchaseManager PaymentQueueRetoreCompletedTransactions")
        // 購入履歴がない場合、アラート表示
        guard !queue.transactions.isEmpty else {
                    print("not purchased yet!")
            delegate?.purchaseManagerFailedRestoreNeverPurchase?(self)
                    return
                }
        // すでに商品を購入していたら、復元を行う
        for transaction in queue.transactions {
            print("InnApp : PurchaseManager CompleteRestore", transaction.payment.productIdentifier, transaction.transactionState)
            //リストア完了時に呼ばれる
            delegate?.purchaseManagerDidFinishRestore?(self)
        }
    }
    func verifySignature(){
//        #if DEBUG
//        let certificateName = "StoreKitTestCertificate"
//        print("debug")
//        #else
        let certificateName = "AppleIncRootCertificate"
//        print("production")
//        #endif
        // Get the Path to the receipt
        let receiptUrl = Bundle.main.appStoreReceiptURL
        //Check if it's actually there
        if FileManager.default.fileExists(atPath: receiptUrl!.path)
        {
            //Load in the receipt
            let receipt: Data = try! Data(contentsOf: receiptUrl!)
            let receiptBio = BIO_new(BIO_s_mem())
            // write the contents of the certificate to memory
            BIO_write(receiptBio, (receipt as NSData).bytes, Int32(receipt.count))
            //Verify receiptPKCS7 is not nil
            let receiptPKCS7 = d2i_PKCS7_bio(receiptBio, nil)
            // Check that the container has a signature
            guard OBJ_obj2nid(receiptPKCS7!.pointee.type) == NID_pkcs7_signed else {
              print("receiptStatus = .invalidPKCS7Signature")
              return
            }
            //Read in Apple's Root CA
            guard
                let rootCertURL = Bundle.main.url(forResource: certificateName, withExtension: "cer"),
                let caData = try? Data(contentsOf: rootCertURL) else {
                print("error")
                return
            }
            let caBIO = BIO_new(BIO_s_mem())
            let receiptBytes: [UInt8] = .init(caData)
            BIO_write(caBIO, receiptBytes, Int32(caData.count))
            let caRootX509 = d2i_X509_bio(caBIO, nil)
            //Verify the receipt was signed by Apple
            let caStore = X509_STORE_new()
            X509_STORE_add_cert(caStore, caRootX509)
            OPENSSL_init_crypto(UInt64(OPENSSL_INIT_ADD_ALL_DIGESTS), nil)
//            #if DEBUG
//            let verifyResult = PKCS7_verify(receiptPKCS7, nil, caStore, nil, nil, PKCS7_NOCHAIN)
//            #else
            let verifyResult = PKCS7_verify(receiptPKCS7, nil, caStore, nil, nil, 0)
            print("result",verifyResult)
//            #endif
            // verify a certificate in the chain from the root certificate signed the receipt. If so, the function returns 1.
            if verifyResult != 1 {
                print("Validation Fails!")
                print("receiptPKCS7",receiptPKCS7)
                receiptCheck = false
                return
            } else {
                print("validation succeed")
                receiptCheck = true
            }
        }
    }
    // Appleサーバーに問い合わせてレシートを取得
    func verifyID() {
        guard
            let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
        else {
            print("SKPaymentManager : No receipt.")
            return
        }
        print("receiptData",receiptData)
        do {
            // return the PKCS #7 data structure
            let receiptDataPkcs7 = try PKCS7(data: receiptData)
            if let receiptInfo = receiptDataPkcs7.receipt() {
                print(receiptInfo)
            }
            let receipt = receiptDataPkcs7.receipt()
            print("receipt bi",receipt?.bundleIdentifier)
            guard receipt?.bundleIdentifier == Bundle.main.bundleIdentifier else {
                DispatchQueue.main.async { [self] in
                    receiptErrorMessage()
                }
                return
            }
            UserDefaults.standard.set(true, forKey: "RemoveADs")
            print(UserDefaults.standard.bool(forKey: "RemoveADs"))
        } catch let error {
            print("SKPaymentManager : Failure to validate receipt: \(error)")
        }
    }
    func receiptErrorMessage(){
        if let window = UIApplication.shared.delegate?.window {
            let ac = UIAlertController(title: "Receipt Error".localized, message: "Please try again.".localized, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            window!.rootViewController?.present(ac, animated: true, completion: nil)
            return
        }
    }
}

@objc protocol PurchaseManagerDelegate: class {
    //課金完了
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //課金完了(中断していたもの)
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //リストア完了
    @objc optional func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!)
    //1度もアイテム購入したことがなく、リストアを実行した時
    @objc optional func purchaseManagerFailedRestoreNeverPurchase(_ purchaseManager: PurchaseManager!)
    //リストアに失敗した時
    @objc optional func purchaseManagerDidFailedRestore(_ purchaseManager: PurchaseManager!)
    //課金失敗
    @objc optional func purchaseManagerDidFailedPurchase(_ purchaseManager: PurchaseManager!)
    //承認待ち(ファミリー共有)
    @objc optional func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!)
}
