//
//  TestViewController.swift
//  calculator
//
//  Created by M A on 24/11/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TestViewController: UIViewController {

    // Containerサイズ管理に利用
    @IBOutlet weak var containerView: UIStackView!
    // 背景View
    @IBOutlet weak var bgView: UIImageView!
    // ボタン
    @IBOutlet var btns: [UIButton]!
    // ラベル
    @IBOutlet weak var outputLabel: UILabel!
    // バナー
    @IBOutlet weak var bannerView: GADBannerView!
    // ピンチサイズ管理用
    var pinchScale:CGFloat = 1
    var maxScale:CGFloat = 1
    var minScale:CGFloat = 0.5
    let uds = UserDefaults.standard
    // パン移動範囲管理用
    var rectRange = CGRect()
    var lastPoint:[CGFloat] = []
    // レイアウトロック管理
    var layoutLock = false
    // iPhone/iPodを識別する
    let deviceName = String(UIDevice.current.localizedModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 倍率が保存されていれば代入し使用
        if let rate = uds.object(forKey: "PinchScale"){
            pinchScale = rate as! CGFloat
        }
        // 座標が保存されていれば代入し使用
        if let point = uds.object(forKey: "LastPoint"){
            lastPoint = point as! [CGFloat]
        }
        // ピンチジェスチャ登録
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchAction(_:) ) )
        containerView.addGestureRecognizer(pinchGesture)
        // パンジェスチャー（ドラッグ）登録
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(panAction(_:)))
        containerView.addGestureRecognizer(panGesture)
        // レイアウトセット
        distributedPosition()
    }
    // 画面遷移の際に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // レイアウトロックの設定を代入
        if let locked = uds.object(forKey: "LayoutLock"){
            layoutLock = locked as! Bool
        }
    }

    // レイアウトが変更(回転、画面遷移)のたび呼ばれる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 可動域設定
        getRange()
        adjustPoint()
    }
    
    // ピンチ動作の設定
    @objc func pinchAction(_ gesture: UIPinchGestureRecognizer ){
        // ロックされていなければジェスチャー可能に
        if layoutLock == false {
            // 前回の拡大縮小も含めて初期値からの拡大縮小比率を計算
            let rate = gesture.scale - 1 + pinchScale
            // 可動域内にcontainerがあれば操作可能に
            if rectRange.contains(containerView.frame) == true {
                // 最大率に達すると比率を最大に固定しピンチ比率に代入
                if rate >= maxScale {
                    pinchScale = maxScale
                } else {
                    // 最小率に達すると比率を最小に固定しピンチ比率に代入
                    if rate <= minScale {
                        pinchScale = minScale
                    } else {
                        // 最小〜最大率間の場合はそのままの比率に
                        pinchScale = rate
                    }
                }
                // containerサイズをピンチ比率に変更
                containerView.transform = CGAffineTransform(scaleX: pinchScale, y: pinchScale)
                // ジェスチャ終了時に比率がデフォルト値であれば削除、異なれば保存
                if(gesture.state == .ended) {
                    if pinchScale != maxScale {
                        //終了時に拡大・縮小率を保存しておいて次回に使いまわす
                        uds.set(pinchScale, forKey: "PinchScale")
                    } else {
                        if uds.object(forKey: "PinchScale") != nil {
                            uds.removeObject(forKey: "PinchScale")
                        }
                    }
                    // 回転時用に画面比率を取得
                    getPoint()
                }
            } else {
                // 可動域を出たらデフォルトにセットし直す
                containerView.frame = rectRange
            }
            fitToRange()
        }
    }
    // パン動作の設定
    @objc func panAction(_ gesture: UIPanGestureRecognizer) {
        // ロックされていなければジェスチャ可能に
        if layoutLock == false {
            //View移動中に影を表示
            if gesture.state == .began {
                self.containerView.layer.borderColor = UIColor.lightGray.cgColor
                self.containerView.layer.borderWidth = 5
            } else if gesture.state == .ended {
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.containerView.layer.borderWidth = 0
            }
            // ドラッグ量を取得
            let point: CGPoint = gesture.translation(in: self.containerView )
            // 可動域内であれば移動させる
            if containerView.frame.minX + point.x >= rectRange.minX && containerView.frame.minY + point.y >= rectRange.minY && containerView.frame.maxX + point.x <= rectRange.maxX && containerView.frame.maxY + point.y <= rectRange.maxY{
                // 元の位置＋ドラッグ量＝移動後の位置
                let movedPoint = CGPoint(x: self.containerView.center.x + point.x, y: self.containerView.center.y + point.y)
                self.containerView.center = movedPoint
            }
            if gesture.state == .ended {
                // ドラッグで移動した距離をリセット
                gesture.setTranslation(CGPoint.zero, in: self.containerView)
                // 移動位置を保存し次回に使いまわす
                getPoint()
            }
        }
    }
    
/* レイアウト */
    // 均等配置
    func distributedPosition() {
        // コンテナサイズ調整
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier: 1, constant: -20).isActive = true
        containerView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10).isActive = true
        containerView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
        // ボタンサイズ調整
        let btnsSpaceHeight = containerView.frame.height
        let btnSpaceHeight = btnsSpaceHeight / 8
        let btnHeightRatio = btnSpaceHeight / btnsSpaceHeight
        let ratio = containerView.frame.height / 8 / containerView.frame.height
        print("HeightRatio",btnHeightRatio,"ratio",ratio)
        for btn in btns {
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: btnHeightRatio).isActive = true
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        // ラベルサイズ調整
        outputLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: btnHeightRatio * 2).isActive = true
        UIButton.appearance(whenContainedInInstancesOf: [TestViewController.self]).backgroundColor = UIColor.lightGray
        // 倍率設定があれば代入
        if pinchScale < 1 {
            // 倍率の反映
            containerView.transform = CGAffineTransform(scaleX: pinchScale, y: pinchScale)
        }
       adjustPoint()
    }
    // 可動域計算
    func getRange() {
        let originX = bgView.frame.minX + 10
        let originY = bannerView.frame.maxY + 10
        rectRange.origin = CGPoint(x: originX, y: originY)
        rectRange.size = CGSize(width: bgView.frame.maxX - 10 - originX, height: bgView.frame.maxY - 10 - originY)
    }
    // 現座標計算
    func getPoint() {
        // 中心座標がずれていれば座標比を計算し保存
        if containerView.frame.midX != rectRange.midX || containerView.frame.midY != rectRange.midY {
            // 前回の保存座標があれば削除
            if lastPoint.count > 0 {
                lastPoint.removeAll()
            }
            lastPoint.append(containerView.frame.minX / rectRange.maxX)
            lastPoint.append(containerView.frame.minY / rectRange.maxY)
            uds.set(lastPoint, forKey: "LastPoint")
        } else {
            // デフォルト座標であれば保存データを削除
            if uds.object(forKey: "LastPoint") != nil {
                lastPoint.removeAll()
                uds.removeObject(forKey: "LastPoint")
            }
        }
    }
    // 画面回転時の座標を計算
    func adjustPoint() {
        if lastPoint.count > 0 {
            containerView.frame.origin.x = lastPoint[0] * rectRange.maxX
            containerView.frame.origin.y = lastPoint[1] * rectRange.maxY
            fitToRange()
        }
    }
    // 可動域を超える場合に可動域限に配置
    func fitToRange() {
            if containerView.frame.maxX > rectRange.maxX {
                containerView.frame.origin.x = rectRange.maxX - containerView.frame.width - 1
                print("-x",containerView.frame.origin)
            }
            if containerView.frame.maxY > rectRange.maxY {
                containerView.frame.origin.y = rectRange.maxY - containerView.frame.height - 1
                print("-y",containerView.frame.origin)
            }
            if containerView.frame.minX < rectRange.minX {
                containerView.frame.origin.x = rectRange.minX
                print("+x",containerView.frame.origin)
            }
            if containerView.frame.minY < rectRange.minY {
                containerView.frame.origin.y = rectRange.minY
                print("+y",containerView.frame.origin)
            }
    }
    func rotationRecognition() {
        let ifo = UIApplication.shared.statusBarOrientation
        if ifo == UIInterfaceOrientation.landscapeLeft || ifo == UIInterfaceOrientation.landscapeRight{
            print("landscape")
        } else {
            print("portrait")
        }
    }

}
