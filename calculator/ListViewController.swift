//
//  ListViewController.swift
//  calculator
//
//  Created by M A on 02/04/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
/* 宣言 */
    @IBOutlet weak var tableView: UITableView!
    // 名前と式を格納する配列
    var nameArray:[String] = []
    var formulaArray:[[String]] = []
    var copiedText:String = ""
    
/* テーブル表示の設定 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = nameArray[indexPath.section]
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = formulaArray[indexPath.section][0]
        return cell
    }

/* 編集設定 */
    // 編集ボタン設定
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        // 編集モードon・offの場合設定
        if tableView.isEditing {
            tableView.isUserInteractionEnabled = true
        } else {
            tableView.isUserInteractionEnabled = false
            resetData()
        }
    }
    // デフォルトでスワイプ無効
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    // データをストック
    func resetData(){
        UserDefaults.standard.set(self.nameArray, forKey: "nameArray")
        UserDefaults.standard.set(formulaArray, forKey: "formulaArray")
    }
/* テキスト入力 */
    // セルタップ検知
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            // タップされたセルのセクション番号を出力
            let selectedRow = indexPath.section
            displayForm(path: selectedRow)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // タップイベント設定
     @objc func displayForm(path:Int){
        //create alert
        let alert = UIAlertController(title: "", message: "Rename".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addTextField { (tf) in
            tf.placeholder = "Enter new name".localized
        }
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] (ac) in
            self.view.isMultipleTouchEnabled = false
            if alert?.textFields?.first?.text != nil {
                let name = alert?.textFields?.first?.text ?? ""
                self.nameArray[path] = name
                self.resetData()
                self.tableView.reloadData()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // defaultからデータ配列を取り出す
        if UserDefaults.standard.object(forKey: "nameArray") != nil && UserDefaults.standard.object(forKey: "formulaArray") != nil {
            nameArray = UserDefaults.standard.object(forKey: "nameArray") as! [String]
            formulaArray = UserDefaults.standard.object(forKey: "formulaArray") as! [[String]]
        }
        // データが無いときは編集ボタンを表示しない
        if nameArray.count == 0 {
            self.navigationController?.isNavigationBarHidden = true
            // 編集モードoff
            tableView.isEditing = false
            return
        } else {
            self.navigationController?.isNavigationBarHidden = false
            navigationItem.rightBarButtonItem = editButtonItem
        }
        //tableViewを更新
        tableView.reloadData()
    }
}

extension ListViewController {
    // スワイプアクション設定
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard tableView.isEditing else {
            return .none
        }
        // タイトル変更を設定
        let renameAction = UIContextualAction(style: .normal, title: "Rename".localized) {
            (ctxAction, view, completionHandler) in
            self.displayForm(path: indexPath.section)
            completionHandler(true)
        }
        renameAction.backgroundColor = UIColor.systemGreen
        // コピーのアクションを設定する
        let copyAction = UIContextualAction(style: .normal, title: "Copy".localized) {
            (ctxAction, view, completionHandler) in
            if self.formulaArray[indexPath.section][1] == "0" && !self.formulaArray[indexPath.section][0].contains("=") {
                self.copiedText = self.formulaArray[indexPath.section][0]
            } else {
                // 答えを代入
                self.copiedText = self.formulaArray[indexPath.section][1]
            }
            // クリップボードにコピー
            UIPasteboard.general.string = self.copiedText
            UserDefaults.standard.set(self.copiedText, forKey: "copiedText")
            completionHandler(true)
        }
        // コピーボタンのデザインを設定する
        copyAction.backgroundColor = UIColor.systemBlue
        // 削除のアクションを設定する
        let deleteAction = UIContextualAction(style: .destructive, title:"Delete".localized) {
            (ctxAction, view, completionHandler) in
             //resultArray内のindexPathのrow番目を消去
            self.nameArray.remove(at: indexPath.section)
            self.formulaArray.remove(at: indexPath.section)
            //再びアプリ内に消去した配列を保存
            self.resetData()
            tableView.deleteSections(IndexSet(integer: 0),with: UITableView.RowAnimation.fade)
            //tableViewを更新
            tableView.reloadData()
            completionHandler(true)
        }
        // 削除ボタンのデザインを設定する
        deleteAction.backgroundColor = UIColor.red
        // ボタンにアイコンを表示
        if #available(iOS 13.0, *) {
            renameAction.image = UIImage(systemName: "pencil")
            copyAction.image = UIImage(systemName: "doc.on.doc")
            deleteAction.image = UIImage(systemName: "trash")
        }
        // スワイプでの削除を無効化して設定する
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction, copyAction, renameAction])
        swipeAction.performsFirstActionWithFullSwipe = false
       
        return swipeAction
    }
}
