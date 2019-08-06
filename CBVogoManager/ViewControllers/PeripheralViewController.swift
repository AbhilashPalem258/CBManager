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

class PeripheralViewController: UIViewController {

    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var advertisementIsConnectableLabel: UILabel!
    @IBOutlet weak var serviceUUIDLabel: UILabel!
    @IBOutlet weak var sevicesNavButton: UIButton!
    
    fileprivate let CBManagerInstance = CBManager.shared
    var connectBarbuttonItem: UIBarButtonItem!
    
    var peripheralIndex: Int?
    fileprivate let bag = DisposeBag()
    fileprivate lazy var characteristicsVC = ServicesTableViewController.init(style: .plain)
    
    @IBAction func servicesNavAction(_ sender: Any) {
         characteristicsVC.peripheralIndex = peripheralIndex
        self.navigationController?.pushViewController(characteristicsVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectBarbuttonItem = UIBarButtonItem.init(title: "", style: .done, target: self, action: #selector(connectOrDisconnectToPeripheral))
        self.navigationItem.rightBarButtonItem = connectBarbuttonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.peripherals.value[index]
        
        connectBarbuttonItem.title = model.peripheral.state == CBPeripheralState.disconnected ? "Connect" : "Disconnect"
        CBManagerInstance.onConnectionCallBack
            .subscribe(onNext: {[unowned self] (peripheral) in
            if peripheral.identifier.uuidString == model.peripheral.identifier.uuidString {
                self.connectBarbuttonItem.title = model.peripheral.state == CBPeripheralState.disconnected ? "Connect" : "Disconnect"
                self.statusLabel.text =  "Status: " + self.CBManagerInstance.decodePeripheralState(peripheralState: model.peripheral.state)
            }
        })
        .disposed(by: bag)
        
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
    }
}
extension PeripheralViewController {
    @objc func connectOrDisconnectToPeripheral() {
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.peripherals.value[index]
        
        if model.peripheral.state.rawValue == 0 {
            CBManager.shared.connectToPheripheral(deviceIndex: index) 
        }
        else {
            self.connectBarbuttonItem.title = "Connect"
        }
    }
    
    
}
