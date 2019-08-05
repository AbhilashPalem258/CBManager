//
//  CBManager.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa

protocol CBManagementProtocol {
    func toggleBluetoothOnOffState()
    func connectToPheripheral(deviceIndex: Int, completionHandler: @escaping (_ status: Bool) -> ())
}

class CBManager: NSObject {
    static let shared = CBManager.init()
    
    var bleDevices: [CBPeripheral] = []
    let segments = BehaviorRelay<[PeripheralModel]>(value: [])
    
    fileprivate var centralManager: CBCentralManager?
    var connectionCompletionHandler: ((_ status: Bool) -> ())?
    weak var vc: UIViewController?
    
    var isScanning: Bool {
        return centralManager!.isScanning
    }
    
    private override init() {
        super.init()
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager =  CBCentralManager.init(delegate: self, queue: nil)
    }
}
extension CBManager: CBManagementProtocol {
    func toggleBluetoothOnOffState() {
        guard let manager = centralManager else {
            return
        }
        
        if manager.isScanning {
            segments.accept([])
            centralManager?.stopScan()
        }
        else{
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func connectToPheripheral(deviceIndex: Int, completionHandler: @escaping (_ status: Bool) -> ()) {
         connectionCompletionHandler = completionHandler
         centralManager?.connect(segments.value[deviceIndex].peripheral, options: nil)
    }
}
extension CBManager: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let block = connectionCompletionHandler { block(false) }
        UIAlertController.displayAlert(message: nil, title: "didFailToConnect", inViewController: vc)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var statusMsg: String!
        switch central.state {
        case .unknown:
            statusMsg = "Bluetooth status is UNKNOWN"
        case .resetting:
            statusMsg = "Bluetooth status is RESETTING"
        case .unsupported:
            statusMsg = "Bluetooth status is UNSUPPORTED"
        case .unauthorized:
            statusMsg = "Bluetooth status is UNAUTHORIZED"
        case .poweredOff:
            statusMsg = "Bluetooth status is POWERED OFF"
        case .poweredOn:
            statusMsg = "Bluetooth status is POWERED ON"
        }
        
        DispatchQueue.main.async {[unowned self]  in
            UIAlertController.displayAlert(message: nil, title: statusMsg, inViewController: self.vc)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let peripheralObj = PeripheralModel.init(peripheral: peripheral, rssiVal: RSSI, advertisementData: advertisementData)
        
        var devices = segments.value
        devices.append(peripheralObj)
        segments.accept(devices)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let block = connectionCompletionHandler { block(true) }
        UIAlertController.displayAlert(message: nil, title: "Connection Successful", inViewController: vc)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        UIAlertController.displayAlert(message: nil, title: "didDisconnect", inViewController: vc)
    }
    
}
extension CBManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        UIAlertController.displayAlert(message: nil, title: "didDiscoverServices", inViewController: vc)
    }
    
}
extension CBManager {
    func decodePeripheralState(peripheralState: CBPeripheralState) -> String {
        switch peripheralState {
        case .disconnected:
            return "Disconnected"
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        }
    }
}
