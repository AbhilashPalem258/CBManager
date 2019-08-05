//
//  RUILabel.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUILabel: UILabel {
    
    @IBInspectable var FontSizeType: String?
    @IBInspectable var FontStyleType: String?
    @IBInspectable var LabelTextColor: String?
    @IBInspectable var bgColor: String?
    
    override func layoutSubviews() {
        self.textColor = !( self.LabelTextColor == nil || self.LabelTextColor!.isEmpty) ?UIColor.getColorFromString(colorInString: LabelTextColor) : self.textColor
        self.backgroundColor = !( self.bgColor == nil || self.bgColor!.isEmpty) ? UIColor.getColorFromString(colorInString: bgColor) : self.backgroundColor
//        self.font = UIFont.getFontAndFontSizeInString(fontSizeType: FontSizeType, fontStyle: FontStyleType)
        //        self.sizeToFit()
        super.layoutSubviews()
    }
}
