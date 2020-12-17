//
//  FirstViewItems.swift
//  calculator
//
//  Created by M A on 17/12/2020.
//  Copyright © 2020 AnnApp. All rights reserved.
//

import UIKit

class FirstViewItems: UIView {
    
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        // load xib by name from memory
        Bundle.main.loadNibNamed("FirstViewItems", owner: self, options: nil)
        // add contentView as a subview of the view
        addSubview(contentView)
        // position contentView to take up the entire view's appearance
        contentView.frame = self.bounds
    }
}
