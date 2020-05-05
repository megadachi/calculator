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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTable()
        
        if UserDefaults.standard.data(forKey: "backPatternData") == nil {
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
            }.onChange { (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    print("colorSpec.hex", colorSpec.hex)
                    UserDefaults.standard.set(colorSpec.hex, forKey: "backColorHexData")
                    UserDefaults.standard.set(colorSpec.name, forKey: "backColorNameData")
                }
                UserDefaults.standard.removeObject(forKey: "backPhotoData")
                UserDefaults.standard.removeObject(forKey: "backPatternData")
                picker.collapseInlineRow()
            }
            // 背景写真
            <<< ImageRow("Photo Row") {
                $0.title = "Photo".localized
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.hidden = true
            }.onChange{ row in
                let rowChosen = row.value
                guard let archivePhotoData = try? NSKeyedArchiver.archivedData(withRootObject: rowChosen!, requiringSecureCoding: true) else {
                    fatalError("Archive failed")
                }
                UserDefaults.standard.removeObject(forKey: "backColorHexData")
                UserDefaults.standard.removeObject(forKey: "backColorNameData")
                UserDefaults.standard.removeObject(forKey: "backPatternData")
                UserDefaults.standard.set(archivePhotoData, forKey: "backPhotoData")
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
            .onChange { (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    print("colorSpec.hex", colorSpec.hex)
                    UserDefaults.standard.set(colorSpec.hex, forKey: "textColorHexData")
                    UserDefaults.standard.set(colorSpec.name, forKey: "textColorNameData")
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
            .onChange { (picker) in
                if let colorSpec = picker.cell.colorSpec(forColor: picker.value)?.color {
                    print(colorSpec.hex)
                    UserDefaults.standard.set(colorSpec.hex, forKey: "textBackColorHexData")
                    UserDefaults.standard.set(colorSpec.name, forKey: "textBackColorNameData")
                } else {
                    fatalError("Archive failed")
                }
                picker.collapseInlineRow()
            }
    
            <<< ActionSheetRow<String>() {
                $0.title = "Font".localized
                $0.selectorTitle = "Choose a font".localized
                $0.options = ["BPdots","Chistoso","Spirax"]
                //                $0.value = "BPdots"    // initially selected
            }
            .onChange { (picker) in
                if let pickerChosen = picker.value{
                    switch pickerChosen{
                    case "Chistoso":
                        UserDefaults.standard.set("Chistoso CF", forKey: "fontData")
                    case "Spirax":
                        UserDefaults.standard.set("Spirax", forKey: "fontData")
                    default:
                        UserDefaults.standard.set("BPdotsDiamond-Bold", forKey: "fontData")
                    }
                }
        }
    }
}

// 端末の言語設定によって言語切り替え
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

