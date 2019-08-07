//
//  RUIButton.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 07/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUIButton: UIButton {
    
    @IBInspectable var FontSizeType: String?
    @IBInspectable var FontStyleType: String?
    @IBInspectable var textColor: String?
    @IBInspectable var backGroundColor: String?
    @IBInspectable var cornerradius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let color = !( self.textColor == nil || self.textColor!.isEmpty) ?UIColor.getColorFromString(colorInString: textColor) : self.titleLabel?.textColor
        setTitleColor(color, for: .normal)
        self.titleLabel?.textColor = color
        backgroundColor = UIColor.getColorFromString(colorInString: backGroundColor)
//        self.titleLabel?.font = UIFont.getFontAndFontSizeInString(fontSizeType: FontSizeType, fontStyle: FontStyleType)
        self.layer.cornerRadius = cornerradius
    }
}
