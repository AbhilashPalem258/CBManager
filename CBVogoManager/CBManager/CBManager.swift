//
//  CBManager.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol CBManagementProtocol {
    func discoverAdvertisedDevices()
}

class CBManager: NSObject {
    static let shared = CBManager.init()
    
    var bleDevices: [CBPeripheral] = []
    
    fileprivate var centralManager: CBCentralManager?
    
    private override init() {
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager =  CBCentralManager.init(delegate: self, queue: centralQueue)
    }
}
extension CBManager: CBManagementProtocol {
    func discoverAdvertisedDevices() {
        
    }
}
extension CBManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            
            DispatchQueue.main.async { () -> Void in
               
            }
           centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral.name!)
        bleDevices.append(peripheral)
        decodePeripheralState(peripheralState: peripheral.state)
//        centralManager?.stopScan()
        
        // STEP 6: connect to the discovered peripheral of interest
//        centralManager?.connect(peripheralHeartRateMonitor!)
        
    } // END func centralManager(... didDiscover peripheral
    
}
extension CBManager {
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
    }
}
