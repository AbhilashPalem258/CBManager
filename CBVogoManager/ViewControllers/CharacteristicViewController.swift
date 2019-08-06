//
//  CharacteristicViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

final class CharacteristicViewController: UIViewController {
    
    @IBOutlet weak var characteristicPropertieslabel: UILabel!
    weak var characteristic: CBCharacteristic?
    var peripheralIndex: Int?
    
    let CBManagerInstance = CBManager.shared
    let bag = DisposeBag.init()

    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var writeDataTF: UITextField!
    @IBAction func read(_ sender: Any) {
        CBManagerInstance.readDataFromPerpheralWithIndex(peripheralIndex: peripheralIndex, characteristic: characteristic)
    }
    
    @IBAction func writeBtnAction(_ sender: Any) {
        guard let index = peripheralIndex else {
            return
        }
        
        self.writeDataTF.endEditing(true)
        let data = self.writeDataTF.text!.data(using: .utf8)
        CBManagerInstance.sendDataToPeripheralWithIndex(data: data, peripheralIndex: index, characteristic: characteristic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CBManagerInstance.onReadData
            .asObservable()
            .subscribe(onNext: {[unowned self] (isReadSuccessful: Bool, characteristic: CBCharacteristic, readText: String?) in
                if isReadSuccessful {
                    self.readLabel.text = readText
                }
                else {
                    UIAlertController.displayAlert(message: "Issue in reading data. please try again", title: "Error", inViewController: self)
                }
            })
            .disposed(by: bag)
        
        CBManagerInstance.onDataWritten
            .asObservable()
            .subscribe(onNext: {[unowned self]  (isWriteSuccessful: Bool, characteristic: CBCharacteristic, error: Error?) in
                if isWriteSuccessful {
                    UIAlertController.displayAlert(message: "Data sucessfully written to characteristic", title: "Success", inViewController: self)
                }
                else {
                    UIAlertController.displayAlert(message: "Some issue in reading data. please try again", title: "Error", inViewController: self)
                }
            })
            .disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var propertieslabel = ""
        if characteristic!.properties.contains(CBCharacteristicProperties.write) {
            propertieslabel += "isWritable"
        }
        if characteristic!.properties.contains(CBCharacteristicProperties.read) {
            propertieslabel += ", isReadable"
        }
        self.characteristicPropertieslabel.text = propertieslabel
    }
}
