//
//  AppConstants.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

//MARK: - AppConstants
struct AppConstants {
    struct display {
        static let unnamedService = "Unnamed Service"
        static let Error = "Error"
        static let success = "Success"
    }
    
    struct errMsgs {
        static let failedToConnect = "Failed to connect to peripheral with error"
        static let failedToReadData = "Issue in reading data. please try again"
    }
    
    struct successMsgs {
        static let dataWrittenSuccessFulMsg = "Data sucessfully written to characteristic"
    }
    
    struct VCTitles {
        static let serviceVC = "Services"
        static let characteristicsVC = "Characteristics"
        static let characteristicVC = "Play Around"
    }
}

//MARK: - BLEDevicesVCConstants
struct BLEDevicesVCConstants {
    static let switchOnMsg = "Please switch on to scan for bluetooth devices"
    static let switchOnMsgFont = UIFont.init(name: "Palatino-Italic", size: 20.0)
}

//MARK: - PeripheralVCConstants
struct PeripheralVCConstants {
    struct display {
        static let connect = "Connect"
        static let connectableMsg = "Yes.. is connectable"
        static let notConnectableMsg = "No.. not connectable"
    }
    
    struct string {
        static let kCBAdvDataServiceUUIDsKey = "kCBAdvDataServiceUUIDs"
        static let kCBAdvDataIsConnectableKey = "kCBAdvDataIsConnectable"
    }
}
