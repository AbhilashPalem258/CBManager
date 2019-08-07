//
//  Colors.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

extension UIColor {
    static var TextBlack: UIColor {
        return UIColor(red: 45/255.0, green: 45/255.0, blue: 43/255.0, alpha: 1)
    }
    static var TextWhite: UIColor {
        return UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
    }
    static var ShadowBlack: UIColor {
        return UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.15)
    }
    static var BGBlue: UIColor {
        return UIColor(red: 0/255.0, green: 88/255.0, blue: 99/255.0, alpha: 1)
    }
    
    
    static func getColorFromString(colorInString: String?) -> UIColor{
        var actualColor: UIColor! = UIColor.clear
        
        let colorInStr = colorInString ?? ColorConstants.clear
        
        if(colorInStr.caseInsensitiveCompare(ColorConstants.textBlack) == ComparisonResult.orderedSame){
            actualColor = UIColor.TextBlack
        }
        else if (colorInStr.caseInsensitiveCompare(ColorConstants.textWhite) == ComparisonResult.orderedSame){
            actualColor = UIColor.TextWhite
        }
        else if (colorInStr.caseInsensitiveCompare(ColorConstants.clear) == ComparisonResult.orderedSame){
            actualColor = UIColor.clear
        }
        else if(colorInStr.caseInsensitiveCompare(ColorConstants.shadowBlack) == ComparisonResult.orderedSame){
            actualColor = UIColor.ShadowBlack
        }
        else if(colorInStr.caseInsensitiveCompare(ColorConstants.bgBlue) == ComparisonResult.orderedSame){
            actualColor = UIColor.BGBlue
        }
        
        return actualColor
    }
}
