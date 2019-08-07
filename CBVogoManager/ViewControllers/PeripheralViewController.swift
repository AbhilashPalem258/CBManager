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
final class PeripheralViewController: RUIViewController {

    //MARK: IBOutlet Member Declarations
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var advertisementIsConnectableLabel: UILabel!
    @IBOutlet weak var serviceUUIDLabel: UILabel!
    @IBOutlet weak var sevicesNavButton: UIButton!
    @IBOutlet weak var servicesButton: RUIButton!
    
    //MARK: fileprivate Member Declarations
    fileprivate let CBManagerInstance = CBManager.shared
    fileprivate let bag = DisposeBag()
    fileprivate lazy var servicesVC = ServicesTableViewController.init(style: .plain)
    fileprivate var model: PeripheralModel!
    
    //MARK:  Member Declarations
    var peripheralIndex: Int?
   
    //MARK: IBAction Methods Implementation
    @IBAction func servicesNavAction(_ sender: Any) {
        servicesVC.peripheralIndex = peripheralIndex
        if (self.navigationController?.topViewController?.isKind(of: PeripheralViewController.self))! {
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }
    
    //MARK: ViewLifeCycle Methods Implementation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let index = peripheralIndex, peripheralIndex! < CBManager.shared.peripherals.value.count  else {
            return
        }
        model = CBManager.shared.peripherals.value[index]
        self.title = model.peripheral.name ?? AppConstants.display.unnamedService
        showPeripheralData()
        subscribeToCBManagerCallBacks()
        self.showOrHideservicesButton()
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
    
    fileprivate func showPeripheralData() {
        self.peripheralNameLabel.text = "Name: " + (model.peripheral.name ?? AppConstants.display.unnamedService)
        self.uuidLabel.text = "UUID: " + model.peripheral.identifier.uuidString
        self.statusLabel.text =  "Status: " + CBManager.shared.decodePeripheralState(peripheralState: model.peripheral.state)
        if let uuids = model.advertisementData[PeripheralVCConstants.string.kCBAdvDataServiceUUIDsKey] as? [CBUUID], let uniqueID = uuids.first?.uuidString {
            self.serviceUUIDLabel.text = "Service  UUID: " + uniqueID
        }
        else {
            self.serviceUUIDLabel.text = "Service  UUID: UnAvailable"
        }
        
        if let isConnectable = model.advertisementData[PeripheralVCConstants.string.kCBAdvDataIsConnectableKey] as? Bool {
            self.advertisementIsConnectableLabel.text = isConnectable ? PeripheralVCConstants.display.connectableMsg : PeripheralVCConstants.display.connectableMsg
        }
        self.showOrHideConnectButton(model.peripheral.state == CBPeripheralState.disconnected)
    }
    
    fileprivate func showOrHideConnectButton(_ shouldShow: Bool){
        self.navigationItem.rightBarButtonItem = shouldShow ? UIBarButtonItem.init(title: PeripheralVCConstants.display.connect, style: .done, target: self, action: #selector(connectToPeripheral)) : nil
    }
    
    fileprivate func  subscribeToCBManagerCallBacks() {
        CBManagerInstance.onConnectionCallBack
            .subscribe(onNext: {[unowned self] (peripheral, error) in
                
                guard error == nil else {
                    UIAlertController.displayAlert(message: "\(AppConstants.errMsgs.failedToConnect): \(error!.localizedDescription)", title: AppConstants.display.Error, inViewController: self)
                    return
                }
                
                if peripheral.identifier.uuidString == self.model.peripheral.identifier.uuidString {
                    self.showOrHideConnectButton(self.model.peripheral.state == CBPeripheralState.disconnected)
                    self.statusLabel.text =  "Status: " + self.CBManagerInstance.decodePeripheralState(peripheralState: self.model.peripheral.state)
                }
            })
            .disposed(by: bag)
        
        CBManagerInstance.didDiscoveredServicesCallBack
            .subscribe(onNext: {[unowned self] (uuid, error) in
                guard error == nil, self.model.peripheral.identifier.uuidString == uuid else {
                    self.servicesButton.setTitle("No Services", for: .normal)
                    self.servicesButton.isEnabled = false
                    return
                }
                
                self.showOrHideservicesButton()
            })
            .disposed(by: bag)
    }
    
    fileprivate func showOrHideservicesButton(){
        self.servicesButton.setTitle((self.model.peripheral.services?.count == 0 ? "No Services" : "Services"), for: .normal)
        self.servicesButton.isEnabled = self.model.peripheral.services?.count != 0
        self.servicesButton.isHidden = model.peripheral.state == CBPeripheralState.disconnected
    }
}
