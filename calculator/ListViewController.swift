//
//  ListViewController.swift
//  calculator
//
//  Created by M A on 02/04/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import Eureka

class ListViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationbar 編集ボタン定義
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItem = editButtonItem
        
        // 編集モードoff
        tableView.isEditing = false

        // テーブルの設定
        form +++
        MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                           header: "Multivalued TextField",
                           footer: ".Insert adds a 'Add Item' (Add New Tag) button row as last cell.") {
            $0.addButtonProvider = { section in
                return ButtonRow(){
                    $0.title = "Add New Tag"
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return NameRow() {
                    $0.placeholder = "Tag Name"
                }
            }
            $0 <<< NameRow() {
                $0.placeholder = "Tag Name"
                $0.onCellSelection({ (cell, row) in
                    self.performSegue(withIdentifier: "toPatternView", sender: nil)
                })
                }
//                <<< LabelRow(){
//
//                    $0.hidden = Condition.function(["switchRowTag"], { form in
//                        return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
//                    })
//                    $0.title = "Switch is on!"
//                            }
        }
        // セルアクション無効
        for row in form.rows {
            row.baseCell.isUserInteractionEnabled = false
        }
    }
    
    // 編集ボタンのアクション設定
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // 編集モードon
        tableView.isEditing = editing
        // セルアクション有効
        for row in form.rows {
            row.baseCell.isUserInteractionEnabled = true
        }
    }

    // スワイプボタンの文言指定
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localized
    }

}
