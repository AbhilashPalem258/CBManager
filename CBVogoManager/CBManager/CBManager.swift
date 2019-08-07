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

//MARK: - CBManagementProtocol
protocol CBManagementProtocol {
    var onDataWritten: PublishSubject<(isWriteSuccessful: Bool, characteristic: CBCharacteristic, error: Error?)> { get set }
    var onReadData: PublishSubject<(isReadSuccessful: Bool, characteristic: CBCharacteristic, readText: String?)> { get set }
    var onConnectionCallBack: PublishSubject<(peripheral: CBPeripheral, error: Error?)> { get set }
    var didDiscoveredServicesCallBack: PublishSubject<(uuid: String, error: Error?)>  { get set }
    var navController: UINavigationController? { get set }
    var isScanning: Bool { get }
    var peripherals: BehaviorRelay<[PeripheralModel]> { get set }
    
    func toggleBluetoothOnOffState(isOn: Bool)
    func connectToPheripheral(deviceIndex: Int)
    func sendDataToPeripheralWithIndex(data: Data?, peripheralIndex: Int?, characteristic: CBCharacteristic?)
    func readDataFromPerpheralWithIndex(peripheralIndex: Int?, characteristic: CBCharacteristic?)
    func stopScanning()
    func decodePeripheralState(peripheralState: CBPeripheralState) -> String
}

//MARK: - CBManager
final class CBManager: NSObject {
    
    //MARK: Static Member Declarations
    static let shared = CBManager.init()
    
    //MARK: FilePrivate Member Declarations
    fileprivate var centralManager: CBCentralManager?

    //MARK: Member Declarations
    var peripherals = BehaviorRelay<[PeripheralModel]>(value: [])
    var navController: UINavigationController?
    var onDataWritten: PublishSubject<(isWriteSuccessful: Bool, characteristic: CBCharacteristic, error: Error?)> = PublishSubject.init()
    var onReadData: PublishSubject<(isReadSuccessful: Bool, characteristic: CBCharacteristic, readText: String?)> = PublishSubject.init()
    var onConnectionCallBack: PublishSubject<(peripheral: CBPeripheral, error: Error?)> = PublishSubject.init()
    var didDiscoveredServicesCallBack: PublishSubject<(uuid: String, error: Error?)> = PublishSubject.init()

    //MARK: Computed Member Declarations
    var isScanning: Bool {
        return centralManager!.isScanning
    }
    
    //MARK: Initialization
    private override init() {
        super.init()
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager =  CBCentralManager.init(delegate: self, queue: centralQueue)
    }
}
//MARK: - CBManager: CBManagementProtocol Methods Implementation
extension CBManager: CBManagementProtocol {
    func toggleBluetoothOnOffState(isOn: Bool) {
        guard let manager = centralManager else {
            return
        }
        
        if manager.state == CBManagerState.poweredOn {
            if !isOn {
                peripherals.accept([])
                manager.stopScan()
            }
            else{
                manager.scanForPeripherals(withServices: nil, options: nil)
            }
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
    
    func stopScanning(){
        guard let manager = centralManager else {
            return
        }
        
        if manager.isScanning {
            manager.stopScan()
        }
    }
    
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
//MARK: - CBManager: CBCentralManagerDelegate Methods Implementation
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
        guard !self.isPeripheralAlreadyPresent(withUUID: peripheral.identifier.uuidString) else {
            return
        }
        
       let peripheralObj = PeripheralModel.init(peripheral: peripheral, rssiVal: RSSI, advertisementData: advertisementData)

       var devices = peripherals.value
        devices.append(peripheralObj)
        DispatchQueue.main.async {[unowned self]  in
            self.peripherals.accept(devices)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {[unowned self]  in
            self.onConnectionCallBack.onNext((peripheral: peripheral, error: nil))
        }
        let connectedPeripheralmodel = peripherals.value.filter { (model) -> Bool in
            return model.peripheral.identifier.uuidString == peripheral.identifier.uuidString
        }.first
        
        peripheral.delegate = self
        peripheral.discoverServices(connectedPeripheralmodel!.advertisementData[PeripheralVCConstants.string.kCBAdvDataServiceUUIDsKey] as? [CBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {[unowned self]  in
            self.navController?.popToRootViewController(animated: true)
            self.showAlertWithTitle(title: "Perpheral Disconnect", message: nil)
        }
    }
    
}
//MARK: - CBManager: CBPeripheralDelegate Methods Implementation
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
        else {
            DispatchQueue.main.async {[unowned self]  in
                self.showAlertWithTitle(title: "Characteristic value is nil. please try again", message: nil)
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

//MARK: - CBManager: Custom Methods Implementation
extension CBManager {
    fileprivate func showAlertWithTitle(title: String?, message: String?) {
        let latestVc = self.navController?.viewControllers.last
        UIAlertController.displayAlert(message: message, title: title ?? "", inViewController: latestVc)
    }
    
    fileprivate func isPeripheralAlreadyPresent(withUUID peripheralId: String!) -> Bool {
        var isAlreadyPresent = false
        peripherals.value.forEach({ (model) in
            if model.peripheral.identifier.uuidString == peripheralId {
                isAlreadyPresent = true
            }
        })
        return isAlreadyPresent
    }
}
