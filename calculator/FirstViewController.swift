//
//  FirstViewController.swift
//  calculator
//
//  Created by M A on 2019/08/29.
//  Copyright © 2019 M A. All rights reserved.
//
//次のステップ
//AdMob を利用するには、アプリのソースコードにアプリ ID を追加する必要があるため、新しいアプリ ID を控えておいてください。
//広告ユニットを作成し、アプリで広告を表示できるようにしてください。
//Google Play や App Store でアプリが公開されたら、必ずアプリをリンクしてください。
// アプリ ID: ca-app-pub-9368270017677505~4908410270
// 広告ユニット ID: ca-app-pub-9368270017677505/5618856710

import UIKit
import Expression
import GoogleMobileAds

class FirstViewController: UIViewController {
    
    // 広告バナーを表示するviewの設定
    @IBOutlet weak var bannerView: GADBannerView!
    
    //    var numberOnScreen:Double = 0; // 画面上の数字
    //    var previousNumber:Double = 0; // 前回表示されていた数字
    //    var performingMath = false  // 計算してもいい？の判断値
    //    var operation = 0; //  + , - , × , ÷
    
    // 計算結果表示画面を定義
    @IBOutlet var outputLabel: UILabel!
    
    // 数字ボタンと演算子ボタンを定義
    @IBAction func numbers(_ sender: UIButton) {
        // ボタン（Cと=以外）が押されたら式を表示する
        guard let formulaText = outputLabel.text else {
            return
        } // 押されたボタンのTitleを取得
        guard let senderedText = sender.titleLabel?.text else {
            return
        }
        outputLabel.text = formulaText + senderedText
        
        //        if performingMath == true{
        //            outputLabel.text = String(sender.tag-1)  // numberOnScreen の値が上書きされる
        //            numberOnScreen = Double(outputLabel.text!)!
        //            performingMath = false
        //        }
        //        else{
        //            outputLabel.text = outputLabel.text! + String(sender.tag-1)  // String(sender.tag-1) 数字が代入
        //            numberOnScreen = Double(outputLabel.text!)!  // 数字が表示
        //        }
    }
    // その他のボタンを定義
    @IBAction func symbols(_ sender: UIButton) {
        switch sender.tag {
        case 11 : // Cボタンが押されたら式と答えをクリアする
            outputLabel.text = ""
        case 18 :        // =ボタンが押されたら答えを計算して表示する
            guard let formulaText = outputLabel.text else {
                return
            }
            let formula: String = formatFormula(formulaText)
            outputLabel.text = evalFormula(formula)
        default:
            outputLabel.text = ""
        }
        //        //数字が表示されていた場合の処理
        //        if sender.tag != 11 && sender.tag != 12 && sender.tag != 18{
        //            previousNumber = Double(outputLabel.text!)!
        //            switch sender.tag{
        //            case 14: // ÷ボタン
        //                outputLabel.text = "÷";
        //            case 15: // ×ボタン
        //                outputLabel.text = "×";
        //            case 16: // -ボタン
        //                outputLabel.text = "-";
        //            case 17: // +ボタン
        //                outputLabel.text = "+";
        //            default:
        //                outputLabel.text = "0"
        //                previousNumber = 0;
        //                numberOnScreen = 0;
        //                operation = 0;
        //            }
        //            operation = sender.tag
        //            performingMath = true;
        //        }
        //        else if sender.tag == 18 {// = が押された時の処理
        //            if operation == 14 { // ÷ボタン
        //                outputLabel.text = String(previousNumber / numberOnScreen)
        //            }
        //            else if operation == 15 { // ×ボタン
        //                outputLabel.text = String(previousNumber * numberOnScreen)
        //            }
        //            else if operation == 16{ // -ボタン
        //                outputLabel.text = String(previousNumber - numberOnScreen)
        //            }
        //            else if operation == 17{ // +ボタン
        //                outputLabel.text = String(previousNumber + numberOnScreen)
        //            }
        //        }
        //        else if sender.tag == 11{ // AC が押された時の処理
        //            outputLabel.text = "0"
        //            previousNumber = 0;
        //            numberOnScreen = 0;
        //            operation = 0;
        //        }
        
        //        case 11: // AllClearボタン
        //        outputLabel.text = "0"
        //        previousNumber = 0;
        //        numberOnScreen = 0;
        //        operation = 0;
        
        //        if outputLabel.text != "" && sender.tag != 11 && sender.tag != 16{   //数字が表示されていた場合の処理
        //            previousNumber = Double(outputLabel.text!)!
        //            if sender.tag == 12{ // ÷
        //                outputLabel.text = "÷";
        //            }
        //            else if sender.tag == 13{  // ×
        //                outputLabel.text = "×";
        //            }
        //            else if sender.tag == 14{  // -
        //                outputLabel.text = "-";
        //            }
        //            else if sender.tag == 15{  // +
        //                outputLabel.text = "+";
        //            }
        //            operation = sender.tag
        //            performingMath = true;
        //        }
        //        else if sender.tag == 16 // = が押された時の処理
        //        {
        //            if operation == 12{
        //                outputLabel.text = String(previousNumber / numberOnScreen)
        //            }
        //            else if operation == 13{
        //                outputLabel.text = String(previousNumber * numberOnScreen)
        //            }
        //            else if operation == 14{
        //                outputLabel.text = String(previousNumber - numberOnScreen)
        //            }
        //            else if operation == 15{
        //                outputLabel.text = String(previousNumber + numberOnScreen)
        //            }
        //        }
        //        else if sender.tag == 11{ // C が押された時の処理
        //            outputLabel.text = ""
        //            previousNumber = 0;
        //            numberOnScreen = 0;
        //            operation = 0;
        //        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        outputLabel.adjustsFontSizeToFitWidth = true
        
        // ビューがロードされた時点で式と答えのラベルは空にする
        outputLabel.text = ""
        
        // バナー広告の設定
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"    // サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    private func formatFormula(_ formula: String) -> String {
        // 入力された整数には`.0`を追加して小数として評価する
        // また`÷`を`/`に、`×`を`*`に置換する
        let formattedFormula: String = formula.replacingOccurrences(
            of: "(?<=^|[÷×\\+\\-\\(])([0-9]+)(?=[÷×\\+\\-\\)]|$)",
            with: "$1.0",
            options: NSString.CompareOptions.regularExpression,
            range: nil
            ).replacingOccurrences(of: "÷", with: "/").replacingOccurrences(of: "×", with: "*")
        return formattedFormula
    }
    
    private func evalFormula(_ formula: String) -> String {
        do {
            // Expressionで文字列の計算式を評価して答えを求める
            let expression = Expression(formula)
            let answer = try expression.evaluate()
            return formatAnswer(String(answer))
        } catch {
            // 計算式が不当だった場合
            return "式を正しく入力してください"
        }
    }
    
    private func formatAnswer(_ answer: String) -> String {
        // 答えの小数点以下が`.0`だった場合は、`.0`を削除して答えを整数で表示する
        let formattedAnswer: String = answer.replacingOccurrences(
            of: "\\.0$",
            with: "",
            options: NSString.CompareOptions.regularExpression,
            range: nil)
        return formattedAnswer
    }
    
}

