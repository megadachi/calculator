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
        form +++ Section("Background")
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

            
            <<< InlineColorPickerRow("Color Row") { (row) in
                row.title = "Color Picker"
                row.isCircular = true
                row.showsPaletteNames = false
                row.value = UIColor.orange
                row.hidden = true
                }.onChange { (picker) in
                    let pickerChosen = picker.value
                    guard let archiveColorData = try? NSKeyedArchiver.archivedData(withRootObject: pickerChosen!, requiringSecureCoding: true) else {
                        fatalError("Archive failed")
                    }
                    UserDefaults.standard.removeObject(forKey: "backPhotoData")
                    UserDefaults.standard.removeObject(forKey: "backPatternData")
                    UserDefaults.standard.set(archiveColorData, forKey: "backColorData")
                    picker.collapseInlineRow()
            }
            <<< ImageRow("Photo Row") {
                $0.title = "Photo Picker"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.hidden = true
                }.onChange{ row in
                    let rowChosen = row.value
                    guard let archivePhotoData = try? NSKeyedArchiver.archivedData(withRootObject: rowChosen!, requiringSecureCoding: true) else {
                        fatalError("Archive failed")
                    }
                    UserDefaults.standard.removeObject(forKey: "backColorData")
                    UserDefaults.standard.removeObject(forKey: "backPatternData")
                    UserDefaults.standard.set(archivePhotoData, forKey: "backPhotoData")
                }
            <<< LabelRow("Pattern Row") {
                $0.title = "Pattern Picker"
                $0.onCellSelection({ (cell, row) in
                    self.performSegue(withIdentifier: "toPatternView", sender: nil)
                })
                }


        // 文字色のテーブル
        form
            +++ Section("Text")
            <<< InlineColorPickerRow("TextColorRow") { (row) in
                row.title = "Text Color"
                row.isCircular = true
                row.showsPaletteNames = false
                }
                .onChange { (picker) in
                    let pickerChosen = picker.value
                    guard let archiveTextColorData = try? NSKeyedArchiver.archivedData(withRootObject: pickerChosen!, requiringSecureCoding: true) else {
                        fatalError("Archive failed")
                    }
                    UserDefaults.standard.set(archiveTextColorData, forKey: "textColorData")
                    UserDefaults.standard.synchronize()
                    picker.collapseInlineRow()
            }
            <<< InlineColorPickerRow("TextBackColorRow") { (row) in
                row.title = "Background Color"
                row.isCircular = true
                row.showsPaletteNames = false
                }
                .onChange { (picker) in
                    let pickerChosen = picker.value
                    guard let archiveTextBackColorData = try? NSKeyedArchiver.archivedData(withRootObject: pickerChosen!, requiringSecureCoding: true) else {
                        fatalError("Archive failed")
                    }
                    UserDefaults.standard.set(archiveTextBackColorData, forKey: "textBackColorData")
                    picker.collapseInlineRow()
        }
    }
}

