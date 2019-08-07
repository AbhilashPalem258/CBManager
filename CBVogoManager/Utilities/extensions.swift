//
//  extensions.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

//MARK: - UIAlertController Extension
extension UIAlertController {
    @discardableResult static func displayAlert(message: String?, title: String, actionsArr:[(title: String, actionBlock:() -> ()?)]! = [], inViewController: UIViewController?, completionBlock : (() -> ())? = nil) -> UIAlertController? {
        
        guard let vc = inViewController else {
            return nil
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if !actionsArr.isEmpty {
            for btnTuple in actionsArr! {
                let title: String? = btnTuple.title
                alert.addAction(UIAlertAction(title: title ?? "", style: UIAlertAction.Style.default, handler: { alertAction in
                    btnTuple.actionBlock()
                }))
            }
        }
        else {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil))
        }
        vc.present(alert, animated: true, completion: completionBlock)
        return alert
    }
}

//MARK: - UIStoryboard Extension
extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
}

//MARK: - String Extension
extension String {
    func toCGFloat() -> CGFloat? {
        var float: CGFloat? = nil
        if let n = NumberFormatter().number(from: self) {
            float = CGFloat(truncating: n)
        }
        return float
    }
}

