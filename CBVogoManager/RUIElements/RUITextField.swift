//
//  RUITextField.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 07/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUITextField: UITextField {
    
    @IBInspectable var LabelTextColor: String?
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textColor = UIColor.getColorFromString(colorInString: LabelTextColor)
    }
    
}

class RUIBorderedTF: RUITextField {
    @IBInspectable var borderColor: String?
    @IBInspectable var borderWidth: String?
    @IBInspectable var radius: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if  self.borderColor != nil  && !self.borderColor!.isEmpty {
            layer.borderColor = UIColor.getColorFromString(colorInString: borderColor).cgColor
        }
        
        layer.borderWidth = borderWidth?.toCGFloat() ?? 0.0
        layer.cornerRadius = radius?.toCGFloat() ?? 0.0
        layer.masksToBounds = true
    }
}
