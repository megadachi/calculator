//
//  AdmobManager.swift
//  calculator
//
//  Created by M A on 19/12/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdmobManager: UIView, GADBannerViewDelegate{
    // クラスのインスタンス化
    static let shared  = AdmobManager()
    
/* サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！ */
//     let bannerID = "ca-app-pub-9368270017677505/5618856710" // 本番広告ユニット ID
    let bannerID = "ca-app-pub-3940256099942544/2934735716" // サンプル広告ユニット ID
    // バナー広告View
    var contentView: GADBannerView!
    // 広告設定
    public func showBanner(_ viewController: UIViewController) -> GADBannerView {
        contentView = GADBannerView(adSize: kGADAdSizeBanner)
        contentView.adUnitID = bannerID
        contentView.rootViewController = viewController
        contentView.delegate = self
        contentView.load(GADRequest())
        return contentView
    }
    // 広告追加＆配置
    func addBannerToView(_ bannerView: GADBannerView, _ view: UIView, n: CGFloat) {
           bannerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(bannerView)
           view.addConstraints(
               [NSLayoutConstraint(item: bannerView,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: view.safeAreaLayoutGuide,
                                   attribute: .top,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: bannerView,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .centerX,
                                   multiplier: 1,
                                   constant: n)
               ])
       }
}
