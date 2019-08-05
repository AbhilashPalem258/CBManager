//
//  RUICustomNIbView.swift
//  AdviseWealth-iOS
//
//  Created by Abhilash Palem on 20/12/18.
//  Copyright © 2018 planarin. All rights reserved.
//

import UIKit

class RUICustomNIbView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame);
        initialConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initialConfiguration()
    }
}
extension RUICustomNIbView {
    @objc func initialConfiguration() {
        let view = loadNib()
        view.frame = bounds
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
    }
}
