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
    
    // 計算可能かを管理する
    var startCalculate = false
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
    
    // 計算結果表示画面ラベル
    @IBOutlet var outputLabel: UILabel!
    
    // 数字ボタンを定義
    @IBAction func numbers(_ sender: UIButton) {
        // ＝ボタンで計算完了後に数字が押された場合、情報をクリアし計算可能に
        if startCalculate == false {
            outputLabel.text = ""
            stackedNumber = ""
            startCalculate = true
        }
        // 割合計算用に数字をストックする
        if let nb = sender.titleLabel?.text {
            stackedNumber = stackedNumber + nb
        }
        // ボタン（Cと=以外）が押されたら式を表示する
        guard let formulaText = outputLabel.text else {
            return
        }
        // 押されたボタンのTitleを取得
        guard let senderedText = sender.titleLabel?.text else {
            return
        }
        outputLabel.text = formulaText + senderedText
        countNegative = 0
    }
    
    // 演算子ボタンを定義
    @IBAction func operators(_ sender: UIButton) {
        // ＝ボタン押下後、計算結果を用いて計算可能にする
        startCalculate = true
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
        case 14, 15, 16, 17 : // ÷ボタン、×ボタン
            // 演算子ボタン押下のたびに直前に入力された数字を配列に保管
            stackedNbsArray.append(stackedNumber)
            // 数字をスタックし直すため、いったんクリア
            stackedNumber = ""
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
            // 直前の数字を配列に追加
            stackedNbsArray.append(stackedNumber)
            // 割合計算用に文字列を変換
            let formulas: String = formatpFormula(formulaText)
            // その他の文字列を変換
            let formula: String = formatFormula(formulas)
            outputLabel.text = evalFormula(formula)
            startCalculate = false
            stackedNumber = ""
            // 数字配列を空にする
            stackedNbsArray.removeAll()
        default: // +/-ボタン
            // 数字の途中に正負ボタンを押せないように設定
            if outputLabel.text!.hasSuffix("+") || outputLabel.text!.hasSuffix("-") || outputLabel.text!.hasSuffix("×") || outputLabel.text!.hasSuffix("÷") || outputLabel.text == "" {
                startCalculate = true
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
    
    // iPhone/iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
    // let bannerID = "ca-app-pub-9368270017677505/5618856710" // 広告ユニット ID
    let bannerIDSample = "ca-app-pub-3940256099942544/2934735716" // 広告ユニット ID
    
    // 画面が呼び込まれる前に背景情報を読み込む
    override func viewWillAppear(_ animated: Bool) {

        changeBackground()
        changeTextColor()
        changeTextBackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPodか判断してiPod用広告を表示する
        if deviceName == "iPad" {
            bannerView.isHidden = true
            bannerIPod()
        }
        // バナー広告の設定
        bannerView.adUnitID = bannerIDSample    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // ビューがロードされた時点で式と答えのラベルは空にする
        outputLabel.text = ""
        
        // 文字数に応じてフォントサイズ変更する
        outputLabel.adjustsFontSizeToFitWidth = true
        
    }
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
            return "retry"
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
        bannerViewLeft.adUnitID = bannerIDSample    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
        bannerViewLeft.rootViewController = self
        bannerViewLeft.load(GADRequest())
        bannerViewRight.adUnitID = bannerIDSample    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
        bannerViewRight.rootViewController = self
        bannerViewRight.load(GADRequest())
        view.addSubview(bannerViewLeft)
        view.addSubview(bannerViewRight)
        stackBanner.addArrangedSubview(bannerViewLeft)
        stackBanner.addArrangedSubview(bannerViewRight)
    }
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
                        print("txtcolorname", textBackColor!)
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).backgroundColor = textBackColor
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).alpha = 0.8
            outputLabel.backgroundColor = textBackColor
            outputLabel.alpha = 0.8
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
}
