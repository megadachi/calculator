//
//  SecondViewController.swift
//  calculator
//
//  Created by M A on 2019/08/29.
//  Copyright © 2019 M A. All rights reserved.
//

import UIKit
import Eureka
import ColorPickerRow
import ImageRow
import Photos
import StoreKit

class SecondViewController: FormViewController, PurchaseManagerDelegate {
    // 課金処理クラス
//    let iapManager = IAPManager()
    // iPhone/iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    let uds = UserDefaults.standard
    // プロダクトID
    let productIdentifiers : [String] = ["com.megadachi.calculator_removeADs"]
//    let productIdentifiers = "com.megadachi.calculator_removeADs"
    var purchaseInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定テーブルを表示
        showTable()
        // 背景設定欄の表示設定
        if uds.data(forKey: "backPatternData") == nil {
            self.form.rowBy(tag: "Color Row")!.hidden = true
            self.form.rowBy(tag: "Photo Row")!.hidden = true
        }
        // プロダクト情報取得
        fetchProductInformationForIds(productIdentifiers)
        print(productIdentifiers[0])
//        iapManager.getProductInfo(productIdentifiers: productIdentifiers)
//        getProductInfo()
        print("ad",uds.bool(forKey: "RemoveADs"))
       
    }
    
    // picker変更の表示設定
    func rowSetUp(rowShown:String, rowHidden1:String, rowHidden2:String){
        self.form.rowBy(tag: rowShown)?.hidden = false
        self.form.rowBy(tag: rowHidden1)?.hidden = true
        self.form.rowBy(tag: rowHidden2)?.hidden = true
        self.form.rowBy(tag: rowShown)?.evaluateHidden()
        self.form.rowBy(tag: rowHidden1)?.evaluateHidden()
        self.form.rowBy(tag: rowHidden2)?.evaluateHidden()
    }

    func showTable(){
        // 背景のテーブル
        form +++ Section("Wallpaper".localized)
            <<< SegmentedRow<String>() {
                //                $0.title = "Select"
                $0.options = ["Color", "Photo", "Pattern"]
            }
            .onChange{ (picker) in
                if let optionChosen = picker.value{
                    if optionChosen == "Color"{
                        self.rowSetUp(rowShown: "Color Row", rowHidden1: "Photo Row", rowHidden2: "Pattern Row")
                    } else if optionChosen == "Photo" {
                        self.rowSetUp(rowShown: "Photo Row", rowHidden1: "Color Row", rowHidden2: "Pattern Row")
                    } else if optionChosen == "Pattern"{
                        self.rowSetUp(rowShown: "Pattern Row", rowHidden1: "Color Row", rowHidden2: "Photo Row")
                    }
                }
            }
            // 背景色
            <<< InlineColorPickerRow("Color Row") { (row) in
                row.title = "Color".localized
                row.isCircular = true
                row.showsPaletteNames = true
                row.value = UIColor.orange
                row.hidden = true
            }.onChange { [self] (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    print("colorSpec.hex", colorSpec.hex)
                    uds.set(colorSpec.hex, forKey: "backColorHexData")
                    uds.set(colorSpec.name, forKey: "backColorNameData")
                }
                uds.removeObject(forKey: "backPhotoData")
                uds.removeObject(forKey: "backPatternData")
                picker.collapseInlineRow()
            }
            // 背景写真
            <<< ImageRow("Photo Row") {
                $0.title = "Photo".localized
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.hidden = true
            }.onChange{ [self] row in
                let rowChosen = row.value
                guard let archivePhotoData = try? NSKeyedArchiver.archivedData(withRootObject: rowChosen!, requiringSecureCoding: true) else {
                    fatalError("Archive failed")
                }
                uds.removeObject(forKey: "backColorHexData")
                uds.removeObject(forKey: "backColorNameData")
                uds.removeObject(forKey: "backPatternData")
                uds.set(archivePhotoData, forKey: "backPhotoData")
            }
            // 背景パターン
            <<< LabelRow("Pattern Row") {
                $0.title = "Pattern".localized
                $0.onCellSelection({ (cell, row) in
                    self.performSegue(withIdentifier: "toPatternView", sender: nil)
                })
        }
        
        // 文字色のテーブル
        form
            +++ Section("Text".localized)
            <<< InlineColorPickerRow("TextColorRow") { (row) in
                row.title = "Text Color".localized
                row.isCircular = true
                row.showsPaletteNames = true
            }
            .onChange { [self] (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    uds.set(colorSpec.hex, forKey: "textColorHexData")
                    uds.set(colorSpec.name, forKey: "textColorNameData")
                } else {
                    fatalError("Archive failed")
                }
                picker.collapseInlineRow()
            }
            <<< InlineColorPickerRow("TextBackColorRow") { (row) in
                row.title = "Background Color".localized
                row.isCircular = true
                row.showsPaletteNames = true
            }
            .onChange { [self] (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    uds.set(colorSpec.hex, forKey: "textBackColorHexData")
                    uds.set(colorSpec.name, forKey: "textBackColorNameData")
                } else {
                    fatalError("Archive failed")
                }
                picker.collapseInlineRow()
            }
            // フォント選択
            <<< ActionSheetRow<String>() {
                $0.title = "Font".localized
                $0.selectorTitle = "Choose a font".localized
                $0.options = ["BPdots","Chistoso","Spirax"]
            }
            .onChange { [self] (picker) in
                if let pickerChosen = picker.value{
                    switch pickerChosen{
                    case "Chistoso":
                        uds.set("Chistoso CF", forKey: "fontData")
                    case "Spirax":
                        uds.set("Spirax", forKey: "fontData")
                    default:
                        uds.set("BPdotsDiamond-Bold", forKey: "fontData")
                    }
                }
        }
        // 広告
        form +++ Section(header: "ADs".localized, footer: "Disable advertisements by making a purchase or restore.".localized)
            // 広告表示選択
            <<< ButtonRow () { (row: ButtonRow) -> Void in
                row.tag = "Remove ADs"
                row.title = "Remove ADs".localized
            }.cellUpdate ({ [self] (cell, row) in
                // 購入済の場合は操作不可にする
                    if uds.bool(forKey: "RemoveADs") != true {
                        row.disabled = false
                    } else {
                        row.disabled = true
                    }
                })
                .onCellSelection({ [self] (cell, row) in
                    // 購入アラート表示
                    showPurchaseMenu()
                    row.updateCell()
                })
    }
/* アラート表示 */
    func showPurchaseMenu() {
        //アラート生成
        let actionSheet = UIAlertController(title: "\(purchaseInfo)", message: "\nNew purchase -> Purchase\nAlready purchased -> Restore".localized, preferredStyle: .alert)
        // 購入処理へ
        let purchaseAction = UIAlertAction(title: "Purchase".localized, style: .default, handler: { [self]
            (action: UIAlertAction!) in
            startPurchase(productIdentifier: productIdentifiers[0])
//            startPurchase(productIdentifier: productIdentifier)
//            iapManager.startPurchase(productIdentifiers: productIdentifiers)
//            iapManager.startPurchase(productIdentifiers: productIdentifiers)
        })
        // 購入済み復元処理へ
        let restoreAction = UIAlertAction(title: "Restore".localized, style: .default, handler: { [self]
            (action: UIAlertAction!) in
            // リストア処理
            startRestore()
//            iapManager.startRestore(productIdentifiers: productIdentifiers)
        })
        // キャンセル
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {
            (action: UIAlertAction!) in
            print("cancel")
        })
        //UIAlertControllerにActionボタンを追加
        actionSheet.addAction(purchaseAction)
        actionSheet.addAction(restoreAction)
        actionSheet.addAction(cancelAction)
        //実際にAlertを表示する
        self.present(actionSheet, animated: true, completion: nil)
    }
    func showAlertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
//------------------------------------
///* プロダクト情報 */
//    // プロダクト情報取得
//    func getProductInfo() {
//        SwiftyStoreKit.retrieveProductsInfo([productIdentifiers]) { [self] result in
//            if let product = result.retrievedProducts.first {
//                let priceString = product.localizedPrice!
//                purchaseInfo = "\(product.localizedTitle) : \(priceString)"
//                print(purchaseInfo)
//            } else if let invalidProductId = result.invalidProductIDs.first {
//                print("Invalid product identifier: \(invalidProductId)")
//            } else {
//                print("Error: \(result.error)")
//            }
//        }
//    }
// 課金処理開始
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithID(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if products?.isEmpty != true {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print("error")
                self.showAlertMessage(title: "Error".localized, message: "Unable to purchase the product.".localized)
            }
        })
    }
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }
//------------------------------------
// MARK: - PurchaseManager Delegate
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //アラート表示
        showAlertMessage(title: "THANK YOU", message: "Successfully purchased!".localized)
//        uds.set(true, forKey: "RemoveADs")
        // コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金失敗時
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
        showAlertMessage(title: "", message: "Purchase failed.".localized)
    }
    // 1度もアイテム購入したことがなく、リストアを選択した時
    func purchaseManagerFailedRestoreNeverPurchase(_ purchaseManager: PurchaseManager!) {
        print("リストア不可！！")
        showAlertMessage(title: "", message: "There are no purchases to restore.".localized)
    }
    //リストアに失敗した時
    func purchaseManagerDidFailedRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア失敗！！")
        //リストア失敗をユーザに知らせるアラートを表示
        showAlertMessage(title: "", message: "Restore failed.".localized)
    }
    // リストア終了時(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア終了！！")
        //アラート表示
        showAlertMessage(title: "THANK YOU", message: "Successfully restored!".localized)
//        uds.set(true, forKey: "RemoveADs")
    }
    // 承認待ち状態時(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
        print("承認待ち！！")
        showAlertMessage(title: "Waiting For Approval", message: "Thank you! You can continue to use Cutelator while your purchase is pending an approval from your parent.")
    }
    // プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
        ProductManager.productsWithID(productIdentifiers: productIds,completion: {[weak self] (products : [SKProduct]?, error : NSError?) -> Void in
            if error != nil {
                if self != nil {
                }
                print(error?.localizedDescription as Any)
                return
            }
            for product in products! {
                let priceString = ProductManager.priceStringFromProduct(product: product)
                if self != nil {
                    print(product.localizedTitle + ":\(priceString)")
                    self!.purchaseInfo = product.localizedTitle + ": \(priceString)"
                }
            }
        })
    }
}

// 端末の言語設定によって言語切り替え
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

