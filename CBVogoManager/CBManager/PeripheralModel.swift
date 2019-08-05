//
//  PeripheralModel.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralModel {
    var peripheral: CBPeripheral
    var rssiValue: NSNumber
    var advertisementData: [String : Any]
    
    init(peripheral: CBPeripheral, rssiVal: NSNumber, advertisementData: [String : Any]) {
        self.peripheral = peripheral
        self.rssiValue = rssiVal
        self.advertisementData = advertisementData
    }
}
