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
class PurchaseManager : NSObject, SKPaymentTransactionObserver, SKRequestDelegate {
    
    var delegate : PurchaseManagerDelegate?
    // プロダクトID
    fileprivate var productIdentifier : String?
    fileprivate var refreshRequest: SKReceiptRefreshRequest?
    // レシート検証ステータス
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
            let errorMessage = "Purchase is not authorised".localized
            let error = NSError(domain: "PurchaseErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey:errorMessage])
            self.delegate?.purchaseManagerDidFailedPurchase?(self)
            print("InnApp : PurchaseManager" + errorMessage)
            showMessage(title: errorMessage, message: "Please check the restrection settings.".localized)
            return
        }
        print("InnApp : PurchaseManager startWithProduct CheckSupendedTransactions")
        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            print("transaction.count",transactions.count)
            for transaction in transactions {
                print("transaction.transactionState",transaction.transactionState)
                if transaction.transactionState != .purchased {
                    continue
                }
                if transaction.payment.productIdentifier == product.productIdentifier {
                    print("ransaction:payment.productIdentifier == productIdentifier")
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
                verifyPurchase()
                break
            case .failed :
                    //課金失敗 エラーが発生したことをユーザに知らせる
                    self.failedTransaction(transaction)
//                }
                break
            case .restored :
                //リストア レシートの確認やアイテムの付与を行う
                print("func paymentQueu .restored: start")
                self.restoreTransaction(transaction)
                print("func paymentQueu .restored: after restoreTransaction")
//                verifyPurchase()
//                print("func paymentQueu .restored: after verifyPurchase")
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
        if transaction.payment.productIdentifier == self.productIdentifier {
            self.productIdentifier = nil
            }
        SKPaymentQueue.default().finishTransaction(transaction)
        // キャンセルでなくTransactionが修了した場合、エラー表示
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            delegate?.purchaseManagerDidFailedPurchase!(self)
        }
    }
    fileprivate func restoreTransaction(_ transaction : SKPaymentTransaction) {
        print("func restoreTransaction: start")
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　func paymentQueueを呼ぶ ※設計に応じて変更
        self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction.original, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
                ("func restoreTransaction: transaction complete")
            }
        })
    }
    fileprivate func deferredTransaction(_ transaction : SKPaymentTransaction) {
        //承認待ち
        self.delegate?.purchaseManagerDidDeferred?(self)
        if transaction.payment.productIdentifier == self.productIdentifier {
            self.productIdentifier = nil
            }
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
        DispatchQueue.main.async { [self] in
            // レシートをリフレッシュ
            let refreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            // 要求完了前に開放されないよう、インスタンス変数に保持
            self.refreshRequest = refreshRequest
            refreshRequest.delegate = self
            refreshRequest.start()
            // 端末内の"Bundle.main.appStoreReceiptURL"で取得できるパスにレシートデータがあるか確認
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                        FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                print("receipt was in the device")
                // レシートがある場合、レシートをチェック
                verifyPurchase()
            } else {
                print("SKPaymentManager : no receipt. restore completed transaction.")
                // 自分をQueueに追加して、結果を待ち構えます。
                SKPaymentQueue.default().add(self)
                // Asks the payment queue to restore previously completed purchases リストア実行
                SKPaymentQueue.default().restoreCompletedTransactions()
                print("receipt was not in the device")
                verifyPurchase()
                // レシートがない場合 ＝ 未購入
                guard let receiptURL = Bundle.main.appStoreReceiptURL,
                      FileManager.default.fileExists(atPath: receiptURL.path) else {
                    delegate?.purchaseManagerFailedRestoreNeverPurchase?(self)
                    return
                }
            }
        }
    }
    // リストア要求終了時呼ばれる
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            // リストア要求終了時処理 解放
            self.refreshRequest = nil
        }
    }
    //AppStoreで必須
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    //リストア失敗時に呼ばれる
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("InnApp : PurchaseManager restoreCompletedTransactionFailed")
        // アラート表示
        delegate?.purchaseManagerDidFailedRestore?(self)
    }
    // called after all restorable transactions have been processed by the payment queue リストア完了時に呼ばれる
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("InnApp : PurchaseManager PaymentQueueRetoreCompletedTransactions")
        // queuに残っているすでに購入している商品を、復元
        for transaction in queue.transactions {
            print("InnApp : PurchaseManager CompleteRestore", transaction.payment.productIdentifier, transaction.transactionState)
        }
    }
    // レシートチェック
    func verifyPurchase(){
        #if DEBUG
        let certificateName = "StoreKitTestCertificate"
        print("debug")
        #else
        let certificateName = "AppleIncRootCertificate"
        print("production")
        #endif
        // Get the Path to the receipt
        guard
            // レシートデータは端末内の"Bundle.main.appStoreReceiptURL"で取得できるパスに保存される
            let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
        else {
            print("SKPaymentManager : No receipt.")
            showMessage(title: "Receipt does not exist".localized, message: "Would you like to remove advertisements? Why not purchase?".localized)
            return
        }
        // Check if it's actually there
        if FileManager.default.fileExists(atPath: receiptUrl.path) {
            // レシートチェック
            do {
                // return the PKCS #7 data structure
                let receiptDataPkcs7 = try PKCS7(data: receiptData)
                if let receiptInfo = receiptDataPkcs7.receipt() {
                    print(receiptInfo)
                }
                let receipt = receiptDataPkcs7.receipt()
                // プロダクトIDをチェック
                guard receipt?.bundleIdentifier == Bundle.main.bundleIdentifier else {
                    DispatchQueue.main.async { [self] in
                        showMessage(title: "Purchase information is invalid".localized, message: "Would you like to remove advertisements? Why not purchase?".localized)
                    }
                    return
                }
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
                showMessage(title: "Receipt Error".localized, message: "Please try again.".localized)
            }
            //Load in the receipt
            let receiptBio = BIO_new(BIO_s_mem())
            // write the contents of the certificate to memory
            BIO_write(receiptBio, (receiptData as NSData).bytes, Int32(receiptData.count))
            //Verify receiptPKCS7 is not nil
            let receiptPKCS7 = d2i_PKCS7_bio(receiptBio, nil)
            // Check that the container has a signature
            guard OBJ_obj2nid(receiptPKCS7!.pointee.type) == NID_pkcs7_signed else {
                print("receiptStatus = .invalidPKCS7Signature")
                showMessage(title: "Purchase information is invalid".localized, message: "Would you like to remove advertisements? Why not purchase?".localized)
                return
            }
            // Certificateのチェック
            //Read in Apple's Root CA
            guard
                let rootCertURL = Bundle.main.url(forResource: certificateName, withExtension: "cer"),
                let caData = try? Data(contentsOf: rootCertURL) else {
                print("error")
                showMessage(title: "Purchase information does not exist".localized, message: "Would you like to remove advertisements? Why not purchase?".localized)
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
                        #if DEBUG
                        let verifyResult = PKCS7_verify(receiptPKCS7, nil, caStore, nil, nil, PKCS7_NOCHAIN)
                        #else
            let verifyResult = PKCS7_verify(receiptPKCS7, nil, caStore, nil, nil, 0)
                        #endif
            // verify a certificate in the chain from the root certificate signed the receipt. If so, the function returns 1.
            if verifyResult != 1 {
                print("PKCS7_verify",verifyResult)
                delegate?.purchaseManagerFailedRestoreNeverPurchase?(self)
                return
            } else {
                print("validation succeed")
                UserDefaults.standard.set(true, forKey: "RemoveADs")
                print("verifyID",UserDefaults.standard.bool(forKey: "RemoveADs"))
                // リストア完了メッセージ表示
                delegate?.purchaseManagerDidFinishRestore?(self)
            }
        }
    }
    func showMessage(title: String, message: String){
        if let window = UIApplication.shared.delegate?.window {
            let ac = UIAlertController(title: title.localized, message: message, preferredStyle: .alert)
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
