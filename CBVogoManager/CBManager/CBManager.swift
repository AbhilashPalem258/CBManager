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
    func toggleBluetoothOnOffState(isOn: Bool)
    func connectToPheripheral(deviceIndex: Int)
    func sendDataToPeripheralWithIndex(data: Data?, peripheralIndex: Int?, characteristic: CBCharacteristic?)
    func readDataFromPerpheralWithIndex(peripheralIndex: Int?, characteristic: CBCharacteristic?)
}

final class CBManager: NSObject {
    static let shared = CBManager.init()
    
    let peripherals = BehaviorRelay<[PeripheralModel]>(value: [])
    
    fileprivate var centralManager: CBCentralManager?
    weak var navController: UINavigationController?
    
    let onDataWritten: PublishSubject<(isWriteSuccessful: Bool, characteristic: CBCharacteristic, error: Error?)> = PublishSubject.init()
    let onReadData: PublishSubject<(isReadSuccessful: Bool, characteristic: CBCharacteristic, readText: String?)> = PublishSubject.init()
    let onConnectionCallBack: PublishSubject<(peripheral: CBPeripheral, error: Error?)> = PublishSubject.init()
    let didDiscoveredServicesCallBack: PublishSubject<(uuid: String, error: Error?)> = PublishSubject.init()

    var isScanning: Bool {
        return centralManager!.isScanning
    }
    
    private override init() {
        super.init()
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager =  CBCentralManager.init(delegate: self, queue: centralQueue)
    }
}
extension CBManager: CBManagementProtocol {
    func toggleBluetoothOnOffState(isOn: Bool) {
        guard let manager = centralManager else {
            return
        }
        
        if !isOn {
            peripherals.accept([])
            manager.stopScan()
        }
        else{
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func connectToPheripheral(deviceIndex: Int) {
         centralManager?.connect(peripherals.value[deviceIndex].peripheral, options: nil)
    }
    
    func sendDataToPeripheralWithIndex(data: Data?, peripheralIndex: Int?, characteristic: CBCharacteristic?) {
        
        guard let index = peripheralIndex, let dataToSend = data, let mainCharacteristic = characteristic  else {
            return
        }
        
        let peripheral = peripherals.value[index].peripheral
        peripheral.writeValue(dataToSend, for: mainCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func readDataFromPerpheralWithIndex(peripheralIndex: Int?, characteristic: CBCharacteristic?) {
        guard let index = peripheralIndex, let mainCharacteristic = characteristic  else {
            return
        }
        
        let peripheral = peripherals.value[index].peripheral
        peripheral.readValue(for: mainCharacteristic)
    }
}
extension CBManager: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {[unowned self]  in
            self.onConnectionCallBack.onNext((peripheral: peripheral, error: error))
        }
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
            let latestVc = self.navController?.viewControllers.last
            UIAlertController.displayAlert(message: nil, title: statusMsg, inViewController: latestVc)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let peripheralObj = PeripheralModel.init(peripheral: peripheral, rssiVal: RSSI, advertisementData: advertisementData)
        
        var devices = peripherals.value
        devices.append(peripheralObj)
        peripherals.accept(devices)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {[unowned self]  in
            self.onConnectionCallBack.onNext((peripheral: peripheral, error: nil))
        }
        let connectedPeripheralmodel = peripherals.value.filter { (model) -> Bool in
            return model.peripheral.identifier.uuidString == peripheral.identifier.uuidString
        }.first
    peripheral.discoverServices(connectedPeripheralmodel!.advertisementData[PeripheralVCConstants.string.kCBAdvDataServiceUUIDsKey] as? [CBUUID])
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {[unowned self]  in
            self.navController?.popToRootViewController(animated: true)
            self.showAlertWithTitle(title: "Perpheral Disconnect", message: nil)
        }
    }
    
}
extension CBManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        DispatchQueue.main.async {[unowned self]  in
            self.didDiscoveredServicesCallBack.onNext((uuid: peripheral.identifier.uuidString, error: error))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Characteristics discovered.")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(characteristic.value != nil) {
            let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            let isSuceessful = (error == nil)
            DispatchQueue.main.async {[unowned self]  in
                self.onReadData.onNext((isReadSuccessful: isSuceessful, characteristic: characteristic, readText: stringValue))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let isSuceessful = (error == nil)
        DispatchQueue.main.async {[unowned self]  in
            self.onDataWritten.onNext((isWriteSuccessful: isSuceessful, characteristic: characteristic, error: error))
        }
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
    
    func showAlertWithTitle(title: String?, message: String?) {
        let latestVc = self.navController?.viewControllers.last
        UIAlertController.displayAlert(message: message, title: title ?? "", inViewController: latestVc)
    }
}
