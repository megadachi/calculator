//
//  AdmobManager.swift
//  calculator
//
//  Created by M A on 19/12/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency

class AdmobManager: UIView, GADBannerViewDelegate{
    // クラスのインスタンス化
    static let shared  = AdmobManager()
    
/* サンプル広告ID ->リリース前に実際のadunitIDに変更adunitする！ */
     let bannerID = "ca-app-pub-9368270017677505/5618856710" // 本番広告ユニット ID
//    let bannerID = "ca-app-pub-3940256099942544/2934735716" // サンプル広告ユニット ID
    // バナー広告View
    var contentView: GADBannerView!
    // 広告設定
    public func showBanner(_ viewController: UIViewController) -> GADBannerView {
        contentView = GADBannerView(adSize: kGADAdSizeBanner)
        contentView.adUnitID = bannerID
        contentView.rootViewController = viewController
        contentView.delegate = self
        // 本番UP前に消す ↓↓
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "daff28f8c384095c9925eb79fbfa3d7e" ]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "5a6863fc5cfa243810c111816bf0e881" ]
        // 本番UP前に消す ↑↑
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
    func showMessage(){
        let requestTitle = "Our free application uses advertising"
        let requestMessage = "If you allow tracking, track data helps advertisers to deliver customized advertising relevant to you (without revealing personal information).\n\nWould you like to disable ads? You can remove ads by making a purchase."
        if let window = UIApplication.shared.delegate?.window {
            let ac = UIAlertController(title: requestTitle.localized, message: requestMessage.localized, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Next", style: .default, handler: {(action: UIAlertAction!) in
                print("show att message")
                self.showTrackingAuthorizationAlert()
            }))
            window!.rootViewController?.present(ac, animated: true, completion: nil)
            return
        }
    }
    func checkTrackingAuthorizationStatus() {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied, .restricted:
                print("not to show message")
            case .notDetermined:
                showMessage()
            @unknown default:
                break
            }
        } else { // iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            }
        }
    }
    // Alert表示
    private func showTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("not to track")
                @unknown default:
                    break
                }
            })
        }
    }
}
