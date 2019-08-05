//
//  AWLoaderView.swift
//  AdviseWealth-iOS
//
//  Created by Abhilash Palem on 14/03/19.
//  Copyright © 2019 planarin. All rights reserved.
//

import UIKit
import GradientCircularProgress

class LoaderView: RUICustomNIbView {
    var progressTag = 101
    var descriptionlTag = 102
    
    var title: String? {
        didSet {
            (viewWithTag(descriptionlTag) as? RUILabel)?.text = title
        }
    }
    
    override func initialConfiguration() {
        super.initialConfiguration()
        
        backgroundColor = UIColor.clear
        
        let progressView = viewWithTag(progressTag)
        let progress = GradientCircularProgress.init()
        
        var progressStyle = BlueIndicatorStyle.init()
        progressStyle.arcLineWidth = 5.0
        progressStyle.progressSize = 38.0
        
        let pView = progress.show(frame: progressView!.bounds.insetBy(dx: -5, dy: -5), message: "", style: progressStyle)
        progressView!.addSubview(pView!)
    }

}
