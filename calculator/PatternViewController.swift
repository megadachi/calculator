//
//  PatternViewController.swift
//  calculator
//
//  Created by M A on 2019/09/26.
//  Copyright © 2019 M A. All rights reserved.
//

import UIKit

class PatternViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // 戻るボタン
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    // コレクションビュー変数宣言
    @IBOutlet var collectionView: UICollectionView!
   
    // 画像patterns
    var patterns = ["wallpaperImg1", "wallpaperImg2", "wallpaperImg3", "wallpaperImg4", "wallpaperImg5", "wallpaperImg6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //セルの登録
        let nib = UINib(nibName: "CollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        //ファイル内処理
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
        
    }
    
    //セクションの数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //セルの総数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return patterns.count;
    }
    //セルの値設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! CollectionViewCell
        
        cell.imageView.image = UIImage(named: patterns[indexPath.row])
        return cell
    }
    //    セクションに値を設定します。
    //    まずは、ヘッダーを宣言して、そのヘッダーを複数生成するコードを書き返します。
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Section", for: indexPath)
        
        //ヘッダーの色
        headerView.backgroundColor = UIColor.lightGray
        return headerView
    }
    
    // Cellの大きさや隙間を調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルをタップした時に呼ばれる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 選択された時の保存処理を書く
        let patternChosen = patterns[indexPath.row]
        UserDefaults.standard.set(patternChosen, forKey: "backPatternData")
        UserDefaults.standard.removeObject(forKey: "backImgData")
        UserDefaults.standard.removeObject(forKey: "backColorHexData")
        UserDefaults.standard.removeObject(forKey: "backColorNameData")
        // ページ遷移
        dismiss(animated: true, completion: nil)
    }

}

