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
    
    var dataArray:[[String]] = [] // 式を格納する配列
    var dataNumber = -1 // 式の配列番号を管理
    var rowNumber = 0 // 式を表示するセルの番号
    var selectedRow = 0 // 変更するセル
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefaultsにキー値で保存された配列を取り出す
        if UserDefaults.standard.object(forKey: "dataArray") != nil {
            print("n1")
            dataArray = UserDefaults.standard.object(forKey: "dataArray") as! [[String]]
            print("n2")
            if dataArray.count == 0 {
                self.navigationController?.isNavigationBarHidden = true
                print("dataArrayは空")
                return
            } else {
                self.navigationController?.isNavigationBarHidden = false
                navigationItem.rightBarButtonItem = editButtonItem
                print("n3")
                while rowNumber < dataArray.count {
                    dataNumber += 1
                    rowNumber += 1
                    form +++
                        MultivaluedSection(multivaluedOptions: [/*.Reorder,*/ .Delete], footer: "\(dataArray[dataNumber][1])") { // フッターに式を表示
                            $0 <<< TextRow("\(rowNumber)") {
                                $0.value = dataArray[dataNumber][0] // セルの値に式の名前を表示
                            }
                            .onChange{ row in
                                self.selectedRow = Int(row.tag!)! - 1
                                print(self.selectedRow)
                                self.dataArray[self.selectedRow][0] = row.value! // セルの値を配列中の式名に
                            }
//                            .onCellSelection({ (cell, row) in
//                                self.dataNumber = Int(row.tag!)! - 1
//                                print(self.dataNumber)
//
//                            })
//                                .cellUpdate{ cell, row in
//                                self.dataArray[self.dataNumber][0] = row.value! // セルの値を配列中の式名に
//                            }
                    }
                    
                    print( "n4", "セル番号", rowNumber, "配列", dataArray)
                }
            }
        } else {
            return
        }
        
        //tableViewを更新
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationbar、編集ボタンの定義
        //        self.navigationController?.isNavigationBarHidden = false
        //        navigationItem.rightBarButtonItem = editButtonItem
        
        // でフォルドで編集モードoff
        tableView.isEditing = false
        
        // デフォルトでセルアクションを無効
        for row in form.rows {
            row.baseCell.isUserInteractionEnabled = false
        }
    }
    
    // デフォルトでスワイプ無効
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    // 編集ボタンのアクション設定
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        // 編集モードon・offの場合設定
        if tableView.isEditing {
            for row in form.rows {
                row.baseCell.isUserInteractionEnabled = true
            }
        } else {
            for row in form.rows {
                row.baseCell.isUserInteractionEnabled = false
            }
            UserDefaults.standard.set(self.dataArray, forKey: "dataArray")
            print("n5", "userdefaults", UserDefaults.standard.object(forKey: "dataArray")!)
            print("配列", dataArray)
        }
    }
    //    // ここを編集！
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
//                        let selectedRow = tableView.indexPathsForSelectedRows!
//        print(selectedRow)
        //        selectedRow -= 1
        //        dataArray.remove(at: selectedRow)
        //        // 先にデータを削除しないと、エラーが発生します。
        //        self.tableData.remove(at: indexPath.row)
        //        tableView.deleteRows(at: [indexPath], with: .automatic)
        dataArray.remove(at: indexPath.row)
        UserDefaults.standard.set(dataArray, forKey: "dataArray")
        dataNumber = -1 // 式の配列番号を管理
        rowNumber = 0// 式を表示するセルの番号
        //        selectedRow -= 1 // 変更するセル
        print("n6","削除後のuserdefaults", UserDefaults.standard.object(forKey: "dataArray")!)
        if dataArray.count != 0{
            print("n7 削除後の配列", dataArray)
        }
//        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        print("n8")
    }
    // スワイプボタンの文言指定
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localized
    }
    
}
