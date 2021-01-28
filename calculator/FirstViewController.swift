//
//  FirstViewController.swift
//  calculator
//
//  Created by M A on 2019/08/29.
//  Copyright © 2019 M A. All rights reserved.
// 
// アプリ ID: ca-app-pub-9368270017677505~4908410270
// 広告ユニット ID: ca-app-pub-9368270017677505/5618856710

import UIKit
import Expression
import GoogleMobileAds
import Photos
import ColorPickerRow

class FirstViewController: UIViewController {
    
    // 電卓アイテムを収納
    @IBOutlet weak var contentView = FVManager.shared.setUPStackView()
    // 背景View
    @IBOutlet weak var bgView: UIImageView!
    var backImgImage: Any = UIColor.orange
    // ボタン
    @IBOutlet var btns: [UIButton]!
    // ラベル
    @IBOutlet weak var outputLabel: UILabel!
    // バナー
    @IBOutlet weak var bannerView: UIView!
/* ジェスチャ用 */
    // ピンチ倍率、最大値、最小値
    var pinchScale:CGFloat = 1
    var maxScale:CGFloat = 1
    var minScale:CGFloat = 0.5
    // 稼働サイズ設定
    var rectRange = CGRect()
    // パン移動範囲管理用
    var savedPoint:[CGFloat] = []
    
    // iPhone・iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    let uds = UserDefaults.standard
/* 計算 */
    // 新規計算可能かを管理する
    var restart = false
    // カウンターで正負を管理、偶数＝plus 奇数＝negative
    var countNegative = 0
    // 割合計算を管理するため、入力した数字を保管
    var stackedNumber = "0"
    var stackedNbsArray: [String] = []
    // 計算結果を保存する name[名前] formul[[式][計算結果]]
    var nameArray:[String] = []
    var formulaArray:[[String]] = []
    // copy&pasteに使う
    var copiedText = ""
    // 計算結果(回答)
    var recalculateNb = "0"
    // 数字ボタンを定義
    @IBAction func numbers(_ sender: UIButton) {
        // ＝ボタンで計算完了後に数字が押された場合、情報をクリアし計算可能に
        if restart == false {
            outputLabel.text = ""
            stackedNumber = ""
            restart = true
        }
        // 割合計算用に数字をストックする
        if let nb = sender.titleLabel?.text {
            stackedNumber = stackedNumber + nb
        }
        // ラベルに数字がある場合、代入する
        guard let formulaText = outputLabel.text else {
            return
        }
        // 押されたボタンのTitleを取得
        guard let senderedText = sender.titleLabel?.text else {
            return
        }
        // 代入した数字と取得したボタンタイトルをラベルに表示
        outputLabel.text = formulaText + senderedText
        countNegative = 0
    }
    // 演算子ボタンを定義
    @IBAction func operators(_ sender: UIButton) {
        // ラベルが空の場合は何もしない
        guard outputLabel.text != "" else {
            return
        }
        // 既に演算子ボタンを押した状態で再度押された場合、既存の演算子を削除し演算子の重複を防止
        if outputLabel.text!.hasSuffix("+") || outputLabel.text!.hasSuffix("-") || outputLabel.text!.hasSuffix("×") || outputLabel.text!.hasSuffix("÷") {
            outputLabel.text = String(outputLabel.text!.dropLast())
        }
        // 割合計算の設定
        switch sender.tag {
        case 14, 15, 16, 17 : // + - ÷ ×ボタン
            // ＝押下後に演算子を選択した場合、回答に演算子をつけて計算再開
            if restart == false {
                outputLabel.text! = recalculateNb
                // 回答をリセット
                recalculateNb = "0"
            }
            // 演算子ボタン押下のたびに直前に入力された数字を配列に保管
            stackedNbsArray.append(stackedNumber)
            // 数字をスタックし直すため、いったんクリア
            stackedNumber = ""
            // ＝ボタン押下後、計算結果を用いて計算可能にする
            restart = true
        default: // ％ボタン、小数点ボタンの重複を防止
            if outputLabel.text!.hasSuffix("%") || outputLabel.text!.hasSuffix("."){
                outputLabel.text = String(outputLabel.text!.dropLast())
            }
            guard restart == true else {
                return
            }
        }
        guard let formulaText = outputLabel.text else {
            return
        } // 押されたボタンのTitleを取得
        guard let senderedText = sender.titleLabel?.text else {
            return
        }
        outputLabel.text = formulaText + senderedText
    }
    // その他のボタンを定義
    @IBAction func symbols(_ sender: UIButton) {
        switch sender.tag {
        case 11 : // ACボタンが押されたら式と数字管理をクリアする
            outputLabel.text = ""
            stackedNumber = ""
            stackedNbsArray.removeAll()
            countNegative = 0
        case 12 : // Cボタンが押されたら一字消去
            guard outputLabel.text != nil else {
                return
            }
            // =押下後に押せないようにする
            guard restart == true else {
                return
            }
            if outputLabel.text?.hasSuffix(")") == true {
                outputLabel.text = String(outputLabel.text!.dropLast(3))
                countNegative = 0
            } else {
                outputLabel.text = String(outputLabel.text!.dropLast())
                stackedNumber =  String(stackedNumber.dropLast())
            }
        case 18 : // =ボタンが押されたら答えを計算して表示する
            guard let formulaText = outputLabel.text else {
                return
            }
            guard restart == true else {
                return
            }
            // 直前の数字を配列に追加
            stackedNbsArray.append(stackedNumber)
            // 割合計算用に文字列を変換
            let formulas: String = formatpFormula(formulaText)
            // その他の文字列を変換
            let formula: String = formatFormula(formulas)
            recalculateNb = evalFormula(formula)
            outputLabel.text = outputLabel.text! + "=" + recalculateNb
            restart = false
            stackedNumber = ""
            // 数字配列を空にする
            stackedNbsArray.removeAll()
        default: // +/-ボタン
            // 数字の途中に正負ボタンを押せないように設定
            if outputLabel.text!.hasSuffix("+") || outputLabel.text!.hasSuffix("-") || outputLabel.text!.hasSuffix("×") || outputLabel.text!.hasSuffix("÷") || outputLabel.text == "" || outputLabel.text!.hasSuffix(")") {
                restart = true
                // カウンターで正負を管理、偶数＝plus 奇数＝negative
                countNegative += 1
                if countNegative % 2 != 0{
                    outputLabel.text = outputLabel.text! + "(-)"
                } else {
                    outputLabel.text = String(outputLabel.text!.dropLast(3))
                    countNegative = 0
                }
            } else {
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ビューがロードされた時点で式と答えのラベルは空にする
        outputLabel.text = ""
        // 文字数に応じてフォントサイズ変更する
        outputLabel.adjustsFontSizeToFitWidth = true
        // ラベルタップでヒストリーに保存
        self.setupLabelTap()
        
        if uds.object(forKey: "nameArray") != nil && uds.object(forKey: "formulaArray") != nil{
            nameArray = uds.object(forKey: "nameArray") as! [String]
            formulaArray = uds.object(forKey: "formulaArray") as! [[String]]
        } else {
            return
        }
        // 倍率が保存されていれば代入し使用
        if let rate = uds.object(forKey: "PinchScale"){
            pinchScale = rate as! CGFloat
        }
        // 座標が保存されていれば代入し使用
        if let point = uds.object(forKey: "savedPoint"){
            savedPoint = point as! [CGFloat]
        }
    }
    // 画面遷移の際に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // ads表示
        if uds.bool(forKey: "RemoveADs") != true {
            bannerView.isHidden = false
            bannerViewAction()
        } else {
            bannerView.isHidden = true
        }
        // カスタマイズ設定
        FVManager.shared.changeBackground(backImg: bgView)
        FVManager.shared.changeTextColor(label: outputLabel)
        FVManager.shared.changeTextBackColor(label: outputLabel)
        FVManager.shared.changeFont(btns: btns)
        // 履歴コピー
        copyText()
        // レイアウトセット
        defaultPosition()
    }
    // レイアウト変更(回転、画面遷移)のたび呼ばれる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 可動域設定
        getRange()
        // 倍率が保存されていれば代入し使用
        if let rate = uds.object(forKey: "PinchScale"){
            pinchScale = rate as! CGFloat
        }
        // 座標が保存されていれば代入し使用
        if let point = uds.object(forKey: "savedPoint"){
            savedPoint = point as! [CGFloat]
        }
        // 画面回転時の座標ずれ調整
        adjustPoint()
        // ジェスチャ登録
        FVManager.shared.onPinch(view: contentView!, range: rectRange)
        FVManager.shared.onPan(view: contentView!, range: rectRange)
    }
/* 電卓機能 */
    // 割合計算用に数字配列を用いて文字列を置換え
    private func formatpFormula(_ pformula: String) -> String {
        // %を”x/100","*(1-x/100)","*(1+x/100)"に置き換え
        var formulas = ""
        for number in stackedNbsArray {
            let formattedpFormula: String = pformula.replacingOccurrences(of: "-" + number + "%", with: "*(1-" + number + "/100)").replacingOccurrences(of: "+" + number + "%", with: "*(1+" + number + "/100)")
            formulas = formattedpFormula
        }
        return formulas
    }
    // 計算用に文字列を置換え
    private func formatFormula(_ formula: String) -> String {
        // 入力された整数には`.0`を追加して小数として評価する
        // また`÷`を`/`に、`×`を`*`に置換、 %を”x/100"に置換え
        let formattedFormula: String = formula.replacingOccurrences(
            of: "(?<=^|[÷×\\+\\-\\(])([0-9]+)(?=[÷×\\+\\-\\)]|$)",
            with: "$1.0",
            options: NSString.CompareOptions.regularExpression,
            range: nil
            ).replacingOccurrences(of: "÷", with: "/").replacingOccurrences(of: "×", with: "*").replacingOccurrences(of: "(-)", with: "(-1)*").replacingOccurrences(of: "%", with: "/100")
        return formattedFormula
    }
    // 計算
    private func evalFormula(_ formula: String) -> String {
        do {
            // Expressionで文字列の計算式を評価して答えを求める
            let expression = Expression(formula)
            var answer = try expression.evaluate()
            // 小数点以下を丸めて誤差をなくす
            if String(answer).contains("."){
                answer = round(answer * 10000000000) / 10000000000
            }
            return formatAnswer(String(answer))
        } catch {
            // 計算式が不当だった場合
            errorAlert()
            return ""
        }
    }
    // 回答
    private func formatAnswer(_ answer: String) -> String {
        // 答えの小数点以下が`.0`だった場合は、`.0`を削除して答えを整数で表示する
        let formattedAnswer: String = answer.replacingOccurrences(
            of: "\\.0$",
            with: "",
            options: NSString.CompareOptions.regularExpression,
            range: nil)
        return formattedAnswer
    }
    // ヒストリーからコピー＆ペースト
    func copyText(){
        guard let n = uds.object(forKey: "copiedText") as! String? else {
            return
        }
        copiedText = n
        // 計算結果が表示されていた場合、代入
        if restart == false {
            outputLabel.text = copiedText
            // 割合計算用に数字をstackedNumberにストックする
            stackedNbsArray.append(copiedText)
            stackedNumber = ""
            copiedText = ""
            // コピーボードを空にする
            uds.removeObject(forKey: "copiedText")
            restart = true
        } else {
            // 負の数字の場合、マイナスをカッコに入れる
            if copiedText.hasPrefix("-"){
                copiedText = copiedText.replacingOccurrences(of: "-", with: "(-)")
            }
            switch outputLabel.text!.suffix(1) {
            case "+", "-", "×", "÷", ")", "": // そのままペーストできるケース
                // ラベルにコピーを追加して表示
                outputLabel.text = outputLabel.text! + copiedText
                stackedNbsArray.append(copiedText)
                stackedNumber = ""
                copiedText = ""
                // コピーボードを空にする
                uds.removeObject(forKey: "copiedText")
            case ".":
                errorAlert()
                copiedText = ""
                uds.removeObject(forKey: "copiedText")
                return
            default: // オペレータを選択してペースト
                selectOperationAlert()
            }
        }
        countNegative = 0
    }
    // ペースト時のアラート設定
    func selectOperationAlert() {
        let alert = UIAlertController(title: "Select Operation".localized,
                                      message: "",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "+", style: .default, handler: { action in
        self.outputLabel.text! += "+" + self.copiedText
            }
        ))
        alert.addAction(UIAlertAction(title: "-", style: .default, handler: { action in
            self.outputLabel.text! += "-" + self.copiedText
        }
        ))
        alert.addAction(UIAlertAction(title: "×", style: .default, handler: { action in
            self.outputLabel.text! += "×" + self.copiedText
        }
        ))
        alert.addAction(UIAlertAction(title: "÷", style: .default, handler: { action in
            self.outputLabel.text! += "÷" + self.copiedText
        }
        ))
        present(alert, animated: true, completion: nil)
        // 割合計算用に数字をstackedNumberにストックする
        stackedNbsArray.append(copiedText)
        stackedNumber = ""
        // コピーボードを空にする
        uds.removeObject(forKey: "copiedText")
        // ＝ボタン押下後、計算結果を用いて計算可能にする
        restart = true
    }
    // コピーエラー時のアラート
    func errorAlert(){
        let alert = UIAlertController(title: "Error".localized,
                                      message: "There was an error. Please try again.".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
/* 計算結果表示ラベルのタップイベント */
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        // タップ時のイベント定義
        let alert = UIAlertController(title: "Save".localized,
                                      message: "Save as".localized,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addTextField { (tf) in
            tf.placeholder = "Enter the name".localized
        }
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] (ac) in
            self.view.isMultipleTouchEnabled = false
            if alert?.textFields?.first?.text != nil {
                let name = alert?.textFields?.first?.text ?? ""
                // 計算結果を保存する name[名前]
                self.nameArray.append(name)
                print("recalculate",self.recalculateNb)
                // 計算結果を保存する formul[[式][計算結果]]
                self.formulaArray.append([self.outputLabel.text!, self.recalculateNb])
                self.uds.set(self.nameArray, forKey: "nameArray")
                self.uds.set(self.formulaArray, forKey: "formulaArray")
                print("set formul",self.formulaArray)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    // 表示ラベルのタップインスタンス作成
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.outputLabel.isUserInteractionEnabled = true
        self.outputLabel.addGestureRecognizer(labelTap)
    }
/* レイアウト */
    // 均等配置
    func defaultPosition() {
        // コンテナサイズ調整
        contentView!.translatesAutoresizingMaskIntoConstraints = false
        contentView!.widthAnchor.constraint(equalTo: bgView.widthAnchor, constant: -20).isActive = true
        contentView!.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10).isActive = true
        contentView!.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10).isActive = true
        contentView!.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
        // ボタンサイズ調整
        let btnHeightRatio = contentView!.frame.height / 8 / contentView!.frame.height
        for btn in btns {
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalTo: contentView!.heightAnchor, multiplier: btnHeightRatio).isActive = true
        }
        // ラベルサイズ調整
        outputLabel.heightAnchor.constraint(equalTo: contentView!.heightAnchor, multiplier: btnHeightRatio * 2).isActive = true
        UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).titleLabel?.adjustsFontSizeToFitWidth = true
        // 倍率が保存されていれば代入し使用
        if let rate = uds.object(forKey: "PinchScale"){
            pinchScale = rate as! CGFloat
        }
        // 倍率設定があれば代入
        if pinchScale < 1 {
            // 倍率の反映
            contentView!.transform = CGAffineTransform(scaleX: pinchScale, y: pinchScale)
        }
        // 画面回転時の座標ずれ調整
        adjustPoint()
    }
    // 可動域計算
    func getRange() {
        let originX = bgView.frame.minX + 10
        let originY = bannerView.frame.maxY + 10
        rectRange.origin = CGPoint(x: originX, y: originY)
        rectRange.size = CGSize(width: bgView.frame.maxX - 10 - originX, height: bgView.frame.maxY - 10 - originY)
    }
    // 画面回転時の座標を計算
    func adjustPoint() {
        if savedPoint.count > 0 {
            contentView!.frame.origin.x = savedPoint[0] * rectRange.maxX
            contentView!.frame.origin.y = savedPoint[1] * rectRange.maxY
            fitToRange()
        }
    }
    // 可動域を超える場合に可動域限に配置
    func fitToRange() {
        if contentView!.frame.maxX > rectRange.maxX {
            contentView!.frame.origin.x = rectRange.maxX - contentView!.frame.width - 1
                print("-x",contentView!.frame.origin)
            }
            if contentView!.frame.maxY > rectRange.maxY {
                contentView!.frame.origin.y = rectRange.maxY - contentView!.frame.height - 1
                print("-y",contentView!.frame.origin)
            }
            if contentView!.frame.minX < rectRange.minX {
                contentView!.frame.origin.x = rectRange.minX
                print("+x",contentView!.frame.origin)
            }
            if contentView!.frame.minY < rectRange.minY {
                contentView!.frame.origin.y = rectRange.minY
                print("+y",contentView!.frame.origin)
            }
    }
    
/* バナー広告表示 */
    func bannerViewAction(){
        bannerView.backgroundColor = UIColor.clear
        // iPodか判断してiPod用広告を表示する
        if deviceName == "iPhone" {
            let adView = AdmobManager.shared.showBanner(self)
            AdmobManager.shared.addBannerToView(adView, bannerView, n: 0)
        } else {
            let adViewL = AdmobManager.shared.showBanner(self)
            AdmobManager.shared.addBannerToView(adViewL, bannerView, n: -170)
            let adViewR = AdmobManager.shared.showBanner(self)
            AdmobManager.shared.addBannerToView(adViewR, bannerView, n: 170)
        }
    }
}
