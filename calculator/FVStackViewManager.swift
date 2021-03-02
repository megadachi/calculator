//
//  FVManager.swift
//  calculator
//
//  Created by M A on 25/12/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import Photos
import ColorPickerRow

class FVManager: UIViewController {
    // クラスのインスタンス化
    static let shared  = FVManager()
/* ジェスチャ管理 */
    // ピンチ倍率、最大値、最小値
    var pinchScale:CGFloat = 1
    var maxScale:CGFloat = 1
    var minScale:CGFloat = 0.7
    // パン移動範囲管理用
    var savedPoint:[CGFloat] = []
    
    let uds = UserDefaults.standard
/* View生成 */
    func setUPStackView() -> UIStackView{
        let view = UIStackView()
        return view
    }
/* 画面設定 */
    // 文字色設定変更
    func changeTextColor(label:UILabel){
        if let archiveData = uds.data(forKey: "textColorData") { // 旧保存形式(データ型)
            let textColor = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).tintColor = textColor
            label.textColor = textColor
        }
        if let archiveHexData = uds.string(forKey: "textColorHexData") { // 新保存形式(文字型)
            if let archiveNameData = uds.string(forKey: "textColorNameData"){
                let txtColor = ColorSpec(hex: archiveHexData, name: archiveNameData).color
                UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).tintColor = txtColor
                label.textColor = txtColor
            }
        }
    }
    // 文字背景色設定変更
    func changeTextBackColor(label: UILabel){
        // 旧保存形式(データ型)
        if let archiveData = uds.data(forKey: "textBackColorData") {
            let textBackColor = try! (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor)!
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).backgroundColor = textBackColor
            label.backgroundColor = textBackColor
        }
        // 新保存形式(文字型)
        if let archiveHexData = uds.string(forKey: "textBackColorHexData") {
            if let archiveNameData = uds.string(forKey: "textBackColorNameData") {
                let textBackColor = ColorSpec(hex: archiveHexData, name: archiveNameData).color
                UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).backgroundColor = textBackColor
                label.backgroundColor = textBackColor
                if textBackColor == UIColor(red: 0, green: 0, blue: 0, alpha: 0){
                    UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).setTitleShadowColor(.black, for: .normal)
                    label.shadowColor = UIColor.black
                } else {
                    UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).setTitleShadowColor(.none, for: .normal)
                    label.shadowColor = UIColor.clear
                }
            }
        }
        if uds.data(forKey: "backColorData") == nil || uds.string(forKey: "backColorNameData") == nil {
            UIButton.appearance(whenContainedInInstancesOf: [FirstViewController.self]).alpha = 0.8
            label.alpha = 0.8
        }
    }
    //文字フォント設定変更
    func changeFont(btns: [UIButton]){
        if let textFont = uds.object(forKey: "fontData") as? String{
            UILabel.appearance(whenContainedInInstancesOf: [FirstViewController.self]).font = UIFont(name: textFont, size: 30)
            UILabel.appearance(whenContainedInInstancesOf: [FirstViewController.self]).adjustsFontSizeToFitWidth = true
            for btn in btns{
                btn.contentEdgeInsets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
                btn.titleLabel!.font = UIFont(name: textFont, size: 100)
                btn.titleLabel!.adjustsFontSizeToFitWidth = true
            }
        }
    }
    // 背景設定変更
    func changeBackground(backImg: UIImageView)  {
        // 背景色の設定
        if let archiveData = uds.data(forKey: "backColorData") { // 旧保存形式(データ型)
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIColor
            backImg.image = nil
            backImg.backgroundColor = backImgImage
        }
        if let archiveHexData = uds.string(forKey: "backColorHexData") { // 新保存形式(文字型)
            if let archiveNameData = uds.string(forKey: "backColorNameData"){
                backImg.image = nil
                backImg.backgroundColor = ColorSpec(hex: archiveHexData, name: archiveNameData).color
            }
        }
        
        // 背景画像の設定
        if let archiveData = uds.data(forKey: "backPhotoData") {
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? UIImage
            backImg.backgroundColor = nil
            backImg.image = backImgImage
            backImg.contentMode = UIView.ContentMode.scaleAspectFill
        }
        // 背景パターンの設定
        if let archiveData = uds.data(forKey: "backPatternData") { // 旧保存形式(データ)
            let backImgImage = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData) as? String
            backImg.backgroundColor = nil
            backImg.image = UIImage(named: backImgImage!)
            backImg.contentMode = UIView.ContentMode.scaleAspectFill
        } else if let archiveData = uds.string(forKey: "backPatternData"){ // 現形式文字で保存
            backImg.backgroundColor = nil
            backImg.image = UIImage(named: archiveData)
            backImg.contentMode = UIView.ContentMode.scaleAspectFill
        }
    }
/* ジェスチャ */
    // サイズ変更
    func onPinch(view: UIStackView, range: CGRect) {
        view.pinch { [self] (gesture) in
        switch (gesture.state) {
            case .began:
                gestureOn(view: view)
            case .changed:
                // 前回の拡大縮小も含めて初期値からの拡大縮小比率を計算
                let rate = gesture.scale - 1 + pinchScale
                switch rate {
                case 0..<minScale:
                    // 最小率に達すると比率を最小に固定しピンチ比率に代入
                    pinchScale = minScale
                case minScale...maxScale:
                    // 最小〜最大率間の場合はそのままの比率に
                    pinchScale = rate
                default:
                    // 最大率に達すると比率を最大に固定しピンチ比率に代入
                    pinchScale = maxScale
                }
                // 比率を代入したイメージのRect作成
                var scaledImage = CGRect()
                scaledImage.size = CGSize(width: view.frame.width * pinchScale, height: view.frame.height * pinchScale)
                scaledImage.origin = CGPoint(x: view.frame.midX - scaledImage.size.width / 2.0, y: view.frame.midY - scaledImage.size.height / 2.0)
                if checkRange(view: scaledImage, range: range) == true {
                    // Viewサイズをピンチ比率に変更
                    view.transform = CGAffineTransform(scaleX: pinchScale, y: pinchScale)
                    if pinchScale != maxScale {
                        //終了時に拡大・縮小率を保存しておいて次回に使いまわす
                        uds.set(pinchScale, forKey: "PinchScale")
                    } else {
                        if uds.object(forKey: "PinchScale") != nil {
                            uds.removeObject(forKey: "PinchScale")
                        }
                    }
                }
            case .ended, .cancelled:
                gestureOff(view: view)
            default:
                break
            }
            if range.contains(view.frame) == false {
                view.frame = range
            }
        }
    }
    // 移動
    func onPan(view: UIStackView, range: CGRect) {
        view.pan { [self] (gesture) in
            switch (gesture.state) {
            case .began:
                gestureOn(view: view)
            case .changed:
                // ドラッグ量を取得
                let point: CGPoint = gesture.translation(in: view)
                // 元の位置＋ドラッグ量＝移動後の位置イメージ作成
                let movedImage = CGRect(x: view.frame.minX + point.x, y: view.frame.minY + point.y, width: view.frame.width, height: view.frame.height)
                if checkRange(view: movedImage, range: range) == true {
                    view.center = CGPoint(x: movedImage.midX, y: movedImage.midY)
                }
            case .ended, .cancelled:
                gestureOff(view: view)
                // デフォルト位置でなければ座標を保存
                getPoint(view: view, range: range)
                // ドラッグで移動した距離をリセット
                gesture.setTranslation(CGPoint.zero, in: view)
            default:
                break
            }
        }
    }
    // 可動域内かチェック
    func checkRange(view: CGRect, range: CGRect) -> Bool {
        if view.minX >= range.minX && view.minY >= range.minY && view.maxX <= range.maxX && view.maxY <= range.maxY {
            return true
        } else {
            return false
        }
    }
    // 現座標計算
    func getPoint(view: UIStackView, range: CGRect) {
        // 中心座標が背景中心とずれていれば(＝ジェスチャあり)座標比を計算し保存
//        if view.frame.midX != range.midX || view.frame.midY != range.midY {
//            print("view.frame.midX",view.frame.midX,"range.midX",range.midX)
//            print("view.frame.midY",view.frame.midY,"range.midY",range.midY)
            // 前回の保存座標があれば削除
            if savedPoint.count > 0 {
                savedPoint.removeAll()
            }
            savedPoint.append(view.frame.minX / range.maxX)
            savedPoint.append(view.frame.minY / range.maxY)
            uds.set(savedPoint, forKey: "savedPoint")
            print("GetPoint",savedPoint[0]*range.maxX,savedPoint[1]*range.maxY)
//        } else {
//            print("GetPoint",savedPoint[0]*range.maxX,savedPoint[1]*range.maxY)
//            // デフォルト座標であれば保存データを削除
//            if uds.object(forKey: "savedPoint") != nil {
//                savedPoint.removeAll()
//                uds.removeObject(forKey: "savedPoint")
//            }
//        }
    }
    // ジェスチャ中の枠色設定
    func gestureOn(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 5
    }
    func gestureOff(view: UIView) {
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 0
    }
}
/* ジェスチャ設定 */
class GestureClosureSleeve<T: UIGestureRecognizer> {
    let closure: (_ gesture: T)->()

    init(_ closure: @escaping (_ gesture: T)->()) {
        self.closure = closure
    }
    @objc func invoke(_ gesture: Any) {
        guard let gesture = gesture as? T else { return }
        closure(gesture)
    }
}
extension UIStackView {
    func pan(_ closure: @escaping (_ gesture: UIPanGestureRecognizer)->()) {
        let sleeve = GestureClosureSleeve<UIPanGestureRecognizer>(closure)
        let recognizer = UIPanGestureRecognizer(target: sleeve, action: #selector(GestureClosureSleeve.invoke(_:)))
        self.addGestureRecognizer(recognizer)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    func pinch(_ closure: @escaping (_ gesture: UIPinchGestureRecognizer)->()) {
        let sleeve = GestureClosureSleeve<UIPinchGestureRecognizer>(closure)
        let recognizer = UIPinchGestureRecognizer(target: sleeve, action: #selector(GestureClosureSleeve.invoke(_:)))
        self.addGestureRecognizer(recognizer)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
