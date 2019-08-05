//
//  RUICardView.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUICardView: UIView {
    @IBInspectable var borderColor: String?
    @IBInspectable var borderWidth: String?
    @IBInspectable var cornerRadius: String?
    @IBInspectable var bgColor: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor.getColorFromString(colorInString: borderColor).cgColor
        layer.borderWidth = borderWidth?.toCGFloat() ?? 0
        if let radius = cornerRadius {
            if !radius.isEmpty {
                layer.cornerRadius = radius.toCGFloat() ?? 0.0
            }
        }
        self.backgroundColor = ((self.bgColor != nil) &&  !self.bgColor!.isEmpty) ? UIColor.getColorFromString(colorInString: bgColor) : self.backgroundColor
    }
}
