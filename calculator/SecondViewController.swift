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

class SecondViewController: FormViewController {
    
    // iPhone/iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    let uds = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTable()
        
        if uds.data(forKey: "backPatternData") == nil {
            self.form.rowBy(tag: "Color Row")!.hidden = true
            self.form.rowBy(tag: "Photo Row")!.hidden = true
        }
        
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
        
        // レイアウトロック
        form +++ Section("Layout".localized)
        <<< SwitchRow("Lock") { row in
            row.title = "Layout Lock".localized
            row.value = uds.bool(forKey: "LayoutLock")
        }.onChange { [self] row in
//            if row.value == true {
//                            (self.form.rowBy(tag: "Lock") as? SwitchRow)?.cell.switchControl.isOn = true
//                        } else {
//                            (self.form.rowBy(tag: "Lock") as? SwitchRow)?.cell.switchControl.isOn = false
//                        }
            uds.set(row.value, forKey: "LayoutLock")
            row.updateCell()
        }
    }
}

// 端末の言語設定によって言語切り替え
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

