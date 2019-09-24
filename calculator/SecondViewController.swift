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
        
    }
    
    // 文字色変更の表示設定
    func rowSetUp(rowShown:String, rowHidden:String){
        self.form.rowBy(tag: rowShown)?.hidden = false
        self.form.rowBy(tag: rowHidden)?.hidden = true
        self.form.rowBy(tag: rowShown)?.evaluateHidden()
        self.form.rowBy(tag: rowHidden)?.evaluateHidden()
    }
    
    func showTable(){
        // 背景のテーブル
        form +++ Section("Background")
            <<< SegmentedRow<String>() {
//                $0.title = "Select"
                $0.options = ["Color", "Image"]
                }.onChange{ (picker) in
                    if let optionChosen = picker.value{
                        if optionChosen == "Color"{
                            self.rowSetUp(rowShown: "Color Row", rowHidden: "Image Row")
                        } else if optionChosen == "Image" {
                            self.rowSetUp(rowShown: "Image Row", rowHidden: "Color Row")
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
                    //                    print("pickerimgname", pickerChosen!)
                    UserDefaults.standard.removeObject(forKey: "backImgData")
                    UserDefaults.standard.set(archiveColorData, forKey: "backColorData")
                    //                    UserDefaults.standard.synchronize()
                    picker.collapseInlineRow()
            }
            <<< ImageRow("Image Row") {
                $0.title = "ImageRow"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.hidden = true
                }.onChange{ row in
                    let rowChosen = row.value
                    guard let archiveImgData = try? NSKeyedArchiver.archivedData(withRootObject: rowChosen!, requiringSecureCoding: true) else {
                        fatalError("Archive failed")
                    }
                    UserDefaults.standard.removeObject(forKey: "backColorData")
                    UserDefaults.standard.set(archiveImgData, forKey: "backImgData")
                    //                    UserDefaults.standard.synchronize()
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
                    //                    print("pickertxtname", pickerChosen!)
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
                    //                    print("pickertxtname", pickerChosen!)
                    UserDefaults.standard.set(archiveTextBackColorData, forKey: "textBackColorData")
                    picker.collapseInlineRow()
        }
    }
}

