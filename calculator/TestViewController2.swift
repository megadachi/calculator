//
//  TestViewController2.swift
//  calculator
//
//  Created by M A on 15/12/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TestViewController2: UIViewController {
    // 広告表示View
    @IBOutlet weak var bannerView: GADBannerView!
    // 背景表示View
    @IBOutlet weak var bgView: UIImageView!
    
    @IBOutlet weak var firstViewItems: FirstViewItems!
    
    // ピンチサイズ管理用
    var pinchScale:CGFloat = 1
    var maxScale:CGFloat = 1
    var minScale:CGFloat = 0.5
    // パン移動範囲管理用
    var rectRange = CGRect()
    var lastPoint:[CGFloat] = []
    // レイアウトロック管理
    var layoutLock = false
    
    let uds = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // レイアウト変更(回転、画面遷移)のたび呼ばれる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
