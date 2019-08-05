//
//  peripheralViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {

    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var advertisementIsConnectableLabel: UILabel!
    @IBOutlet weak var serviceUUIDLabel: UILabel!
    
    var peripheralIndex: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.segments.value[index]
        
        self.peripheralNameLabel.text = "Name: " + (model.peripheral.name ?? "Unnamed service")
        
        self.uuidLabel.text = "UUID: " + model.peripheral.identifier.uuidString
        self.statusLabel.text =  "Status: " + CBManager.shared.decodePeripheralState(peripheralState: model.peripheral.state)
        if let uuids = model.advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID], let uniqueID = uuids.first?.uuidString {
            self.serviceUUIDLabel.text = "Service  UUID: " + uniqueID
        }

        if let isConnectable = model.advertisementData["kCBAdvDataIsConnectable"] as? Bool {
            self.advertisementIsConnectableLabel.text = isConnectable ? "Yes.. is connectable" : "No.. not connectable"
        }
    }
}
