//
//  RUILabel.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUILabel: UILabel {
    
    @IBInspectable var LabelTextColor: String?
    @IBInspectable var bgColor: String?
    
    override func layoutSubviews() {
        self.textColor = !( self.LabelTextColor == nil || self.LabelTextColor!.isEmpty) ?UIColor.getColorFromString(colorInString: LabelTextColor) : self.textColor
        self.backgroundColor = !( self.bgColor == nil || self.bgColor!.isEmpty) ? UIColor.getColorFromString(colorInString: bgColor) : self.backgroundColor
        super.layoutSubviews()
    }
}
class RUIAllBorderedLabel: RUILabel {
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
