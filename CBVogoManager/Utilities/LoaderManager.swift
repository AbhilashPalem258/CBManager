//
//  LoaderManager.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class LoaderManager {
    static let shared = LoaderManager.init()
    
    lazy var blurView: UIView! = {
        let blurView = UIView.init()
        blurView.frame = appWindow.bounds
        blurView.backgroundColor = UIColor.ShadowBlack
        return blurView
    }()
    
    lazy var appWindow: UIWindow = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.window!
    }()
    
    lazy var loaderView: LoaderView = {
        return LoaderView.init(frame: CGRect.init(x: 0, y: blurView.frame.size.height - 200, width: blurView.frame.size.width, height: 70))
    }()
    
    func show(title: String = AppConstants.display.connecting) {
        loaderView.title = title
        blurView.addSubview(loaderView);
        appWindow.addSubview(blurView)
    }
    
    func dismiss() {
        loaderView.removeFromSuperview()
        blurView.removeFromSuperview()
    }
}
