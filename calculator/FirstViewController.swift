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

class FirstViewController: UIViewController {
    
    // 新規計算可能かを管理する
    var restart = false
    // カウンターで正負を管理、偶数＝plus 奇数＝negative
    var countNegative = 0
    // 割合計算を管理するため、入力した数字を保管
    var stackedNumber = "0"
    var stackedNbsArray: [String] = []
    
    // 背景画像用View
    @IBOutlet weak var backImg: UIImageView!
    var backImgImage: Any = UIColor.orange
    let userDefaults = UserDefaults.standard
    
    // 広告バナーを表示するview
    @IBOutlet weak var bannerView: GADBannerView!
    
    // ボタンフォント設定
    @IBOutlet var fontSet: [UIButton]!
    
    // 計算結果表示画面ラベル
    @IBOutlet var outputLabel: UILabel!
    
    // 計算結果を保存するためのArray [名前][計算結果]
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
            if restart == false {
                outputLabel.text! = recalculateNb
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
            // テスト用にデータ消去
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
        case 12 : // Cボタンが押されたら一字消去
            guard outputLabel.text != nil else {
                return
            }
            outputLabel.text = String(outputLabel.text!.dropLast())
            stackedNumber =  String(stackedNumber.dropLast())
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
            if outputLabel.text!.hasSuffix("+") || outputLabel.text!.hasSuffix("-") || outputLabel.text!.hasSuffix("×") || outputLabel.text!.hasSuffix("÷") || outputLabel.text == "" {
                restart = true
                // カウンターで正負を管理、偶数＝plus 奇数＝negative
                countNegative += 1
                if countNegative % 2 != 0{
                    outputLabel.text = outputLabel.text! + "(-)"
                } else {
                    let startPoint = outputLabel.text!.index(outputLabel.text!.endIndex, offsetBy:-3)
                    let endPoint = outputLabel.text!.index(outputLabel.text!.endIndex, offsetBy: 0)
                    outputLabel.text!.removeSubrange(startPoint..<endPoint)
                    countNegative = 0
                }
            } else {
                return
            }
        }
    }
/* 広告用ソース */
    // iPhone/iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
//     let bannerID = "ca-app-pub-9368270017677505/5618856710" // 本番広告ユニット ID
    let bannerID = "ca-app-pub-3940256099942544/2934735716" // サンプル広告ユニット ID
    
    // 画面が呼び込まれる前に背景情報を読み込む
    override func viewWillAppear(_ animated: Bool) {

        changeBackground()
        changeTextColor()
        changeTextBackColor()
        changeFont()
        copyText()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ads表示
//        bannerViewActionShouldBegin()
        
        // ビューがロードされた時点で式と答えのラベルは空にする
        outputLabel.text = ""
        
        // 文字数に応じてフォントサイズ変更する
        outputLabel.adjustsFontSizeToFitWidth = true
        // ラベルタップでヒストリーに保存
        self.setupLabelTap()
        
        if UserDefaults.standard.object(forKey: "nameArray") != nil && UserDefaults.standard.object(forKey: "formulaArray") != nil{
            nameArray = UserDefaults.standard.object(forKey: "nameArray") as! [String]
            formulaArray = UserDefaults.standard.object(forKey: "formulaArray") as! [[String]]
        } else {
            return
        }
        
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
        // また`÷`を`/`に、`×`を`*`に置換する
        // %を”x/100"に置換え
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
            let answer = try expression.evaluate()
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
        guard let n = UserDefaults.standard.object(forKey: "copiedText") as! String? else {
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
            UserDefaults.standard.removeObject(forKey: "copiedText")
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
                UserDefaults.standard.removeObject(forKey: "copiedText")
            case ".":
                errorAlert()
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
        UserDefaults.standard.removeObject(forKey: "copiedText")
        // ＝ボタン押下後、計算結果を用いて計算可能にする
        restart = true
    }
    // エラー時のアラート
    func errorAlert(){
        let alert = UIAlertController(title: "Error".localized,
                                      message: "There was an error. Please try again.".localized,
                                 preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
/* 画面設定 */
    // 文字色設定変更
    func changeTextColor(){
        if let archiveData = UserDefaults.standard.data(forKey: "textColorData") {
            let textColor = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).tintColor = textColor
            outputLabel.textColor = textColor
        }
    }
    // 文字背景色設定変更
    func changeTextBackColor(){
        if let archiveData = UserDefaults.standard.data(forKey: "textBackColorData") {
            let textBackColor = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).backgroundColor = textBackColor
            outputLabel.backgroundColor = textBackColor
        }
        if UserDefaults.standard.data(forKey: "backColorData") == nil {
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).alpha = 0.8
            outputLabel.alpha = 0.8
        }
    }
    //文字フォント設定変更
    func changeFont(){
        if let textFont = UserDefaults.standard.object(forKey: "fontData") as? String{
            UILabel.appearance(whenContainedInInstancesOf: [FirstViewController.self]).font = UIFont(name: textFont, size: 30)
            for btn in fontSet{
                btn.titleLabel!.font = UIFont(name: textFont, size: 30)
            }
        }
    }
    // 背景設定変更
    func changeBackground()  {
        // 背景色の設定
        if let archiveData = UserDefaults.standard.data(forKey: "backColorData") {
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor
            backImg.image = nil
            backImg.backgroundColor = backImgImage
        }
        // 背景画像の設定
        if let archiveData = UserDefaults.standard.data(forKey: "backPhotoData") {
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIImage
            backImg.backgroundColor = nil
            backImg.image = backImgImage
            backImg.contentMode = UIView.ContentMode.scaleAspectFill
        }
        if let archiveData = UserDefaults.standard.data(forKey: "backPatternData") {
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? String
            backImg.backgroundColor = nil
            backImg.image = UIImage(named: backImgImage!)
            backImg.contentMode = UIView.ContentMode.scaleAspectFill
        }
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
//            guard let name = alert?.textFields?.first?.text ?? "" else {
//                return
//            }
            self.view.isMultipleTouchEnabled = false
            if alert?.textFields?.first?.text != nil {
                let name = alert?.textFields?.first?.text ?? ""
                self.nameArray.append(name)
                self.formulaArray.append([self.outputLabel.text!, self.recalculateNb])
                UserDefaults.standard.set(self.nameArray, forKey: "nameArray")
                UserDefaults.standard.set(self.formulaArray, forKey: "formulaArray")
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
    
    /* All iAd Functions */
    func bannerViewActionShouldBegin(){
        // iPodか判断してiPod用広告を表示する
        if deviceName == "iPad" {
            bannerView.isHidden = true
            bannerIPod()
        } else {
            // iPhone用バナー広告の設定
            // ->リリース前に実際のadunitIDに変更adunitする！
//            bannerView.adUnitID = bannerIDSample  // サンプル広告ID
            bannerView.adUnitID = bannerID  // 広告ID

            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
        
    }
    // iPod用のバナー広告
    func bannerIPod() {
        // stackviewを作成しバナー広告を入れる
        let stackBanner = UIStackView()
        self.view.addSubview(stackBanner)
        stackBanner.distribution = .fillEqually
        stackBanner.alignment = .fill
        stackBanner.spacing = 10.0
        stackBanner.translatesAutoresizingMaskIntoConstraints = false
        stackBanner.widthAnchor.constraint(equalToConstant: 700).isActive = true
        stackBanner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        // 縦方向は上辺をセーフエリアに合わせる
        stackBanner.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        // 横方向の中心は、親ビューの横方向の中心と同じ
        stackBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        // バナー広告を定義
        let bannerViewLeft = GADBannerView(adSize: kGADAdSizeBanner)
        let bannerViewRight = GADBannerView(adSize: kGADAdSizeBanner)
        bannerViewLeft.adUnitID = bannerID  // 広告ID
        bannerViewLeft.rootViewController = self
        bannerViewLeft.load(GADRequest())
        bannerViewRight.adUnitID = bannerID  // 広告ID
        bannerViewRight.rootViewController = self
        bannerViewRight.load(GADRequest())
        view.addSubview(bannerViewLeft)
        view.addSubview(bannerViewRight)
        stackBanner.addArrangedSubview(bannerViewLeft)
        stackBanner.addArrangedSubview(bannerViewRight)
    }

}
