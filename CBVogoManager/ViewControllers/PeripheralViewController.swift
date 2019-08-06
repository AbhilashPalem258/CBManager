//
//  peripheralViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

//MARK: - PeripheralViewController
final class PeripheralViewController: UIViewController {

    //MARK: IBOutlet Member Declarations
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var advertisementIsConnectableLabel: UILabel!
    @IBOutlet weak var serviceUUIDLabel: UILabel!
    @IBOutlet weak var sevicesNavButton: UIButton!
    
    //MARK: fileprivate Member Declarations
    fileprivate let CBManagerInstance = CBManager.shared
    fileprivate let bag = DisposeBag()
    fileprivate lazy var characteristicsVC = ServicesTableViewController.init(style: .plain)
    
    //MARK:  Member Declarations
    var peripheralIndex: Int?
   
    //MARK: IBAction Methods Implementation
    @IBAction func servicesNavAction(_ sender: Any) {
         characteristicsVC.peripheralIndex = peripheralIndex
        self.navigationController?.pushViewController(characteristicsVC, animated: true)
    }
    
    //MARK: ViewLifeCycle Methods Implementation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.peripherals.value[index]
        
        showPeripheralData(model: model)
        subscribeToCBManagerCallBacks(model: model)
    }
}

//MARK: - PeripheralViewController: Fileprivate Methods Implementaion
extension PeripheralViewController {
    @objc fileprivate func connectToPeripheral() {
        guard let index = peripheralIndex else {
            return
        }

        CBManager.shared.connectToPheripheral(deviceIndex: index)
    }
    
    fileprivate func showPeripheralData(model : PeripheralModel) {
        self.peripheralNameLabel.text = "Name: " + (model.peripheral.name ?? "Unnamed service")
        self.uuidLabel.text = "UUID: " + model.peripheral.identifier.uuidString
        self.statusLabel.text =  "Status: " + CBManager.shared.decodePeripheralState(peripheralState: model.peripheral.state)
        if let uuids = model.advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID], let uniqueID = uuids.first?.uuidString {
            self.serviceUUIDLabel.text = "Service  UUID: " + uniqueID
        }
        else {
            self.serviceUUIDLabel.text = "Service  UUID: UnAvailable"
        }
        
        if let isConnectable = model.advertisementData["kCBAdvDataIsConnectable"] as? Bool {
            self.advertisementIsConnectableLabel.text = isConnectable ? "Yes.. is connectable" : "No.. not connectable"
        }
        self.showOrHideConnectButton(model.peripheral.state == CBPeripheralState.disconnected)
    }
    
    fileprivate func showOrHideConnectButton(_ shouldShow: Bool){
        self.navigationItem.rightBarButtonItem = shouldShow ? UIBarButtonItem.init(title: "Connect", style: .done, target: self, action: #selector(connectToPeripheral)) : nil
    }
    
    fileprivate func  subscribeToCBManagerCallBacks(model : PeripheralModel) {
        CBManagerInstance.onConnectionCallBack
            .subscribe(onNext: {[unowned self] (peripheral, error) in
                
                guard error == nil else {
                    UIAlertController.displayAlert(message: "Failed to connect to peripheral with error: \(error!.localizedDescription)", title: "Error", inViewController: self)
                    return
                }
                
                if peripheral.identifier.uuidString == model.peripheral.identifier.uuidString {
                    self.showOrHideConnectButton(model.peripheral.state == CBPeripheralState.disconnected)
                    self.statusLabel.text =  "Status: " + self.CBManagerInstance.decodePeripheralState(peripheralState: model.peripheral.state)
                }
            })
            .disposed(by: bag)
    }
}
