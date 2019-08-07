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

//MARK: - CharacteristicViewController
final class CharacteristicViewController: UIViewController {
    
    //MARK: Member Declarations
    weak var characteristic: CBCharacteristic?
    var peripheralIndex: Int?
    
    //MARK: Fileprivate Member Declarations
    fileprivate let CBManagerInstance = CBManager.shared
    fileprivate let bag = DisposeBag.init()

    //MARK: IBOutlet Member Declarations
    @IBOutlet weak var writeBtn: RUIButton!
    @IBOutlet weak var readBtn: RUIButton!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var writeDataTF: UITextField!
    @IBOutlet weak var characteristicPropertieslabel: UILabel!
    
    //MARK: IBAction Methods Implementation
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
    
    //MARK: ViewLifeCycle Methods Implementations
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = AppConstants.VCTitles.characteristicVC
        setPropertiesLabel()
        subscribeForCBManagerCallBacks()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(viewTapped)))
    }
}

//MARK: - CharacteristicViewController: FilePrivate Methods implementation
extension CharacteristicViewController {
    fileprivate func setPropertiesLabel() {
        var propertieslabel = ""
        propertieslabel += characteristic!.properties.contains(CBCharacteristicProperties.write) ? "isWritable" : "Not writable"
        propertieslabel += characteristic!.properties.contains(CBCharacteristicProperties.read) ? ", isReadable" : ", Not Readable"
        self.characteristicPropertieslabel.text = propertieslabel
        
        self.writeBtn.isHidden = !characteristic!.properties.contains(CBCharacteristicProperties.write)
        self.writeDataTF.isHidden = !characteristic!.properties.contains(CBCharacteristicProperties.write)

        self.readBtn.isHidden = !characteristic!.properties.contains(CBCharacteristicProperties.read)
        self.readLabel.isHidden = !characteristic!.properties.contains(CBCharacteristicProperties.read)
    }
    
    fileprivate func subscribeForCBManagerCallBacks() {
        CBManagerInstance.onReadData
            .asObservable()
            .subscribe(onNext: {[unowned self] (isReadSuccessful: Bool, characteristic: CBCharacteristic, readText: String?) in
                if isReadSuccessful {
                    self.readLabel.text = readText
                }
                else {
                    UIAlertController.displayAlert(message: AppConstants.errMsgs.failedToReadData, title: AppConstants.display.Error, inViewController: self)
                }
            })
            .disposed(by: bag)
        
        CBManagerInstance.onDataWritten
            .asObservable()
            .subscribe(onNext: {[unowned self]  (isWriteSuccessful: Bool, characteristic: CBCharacteristic, error: Error?) in
                if isWriteSuccessful {
                    UIAlertController.displayAlert(message: AppConstants.successMsgs.dataWrittenSuccessFulMsg, title: AppConstants.display.success, inViewController: self)
                }
                else {
                    UIAlertController.displayAlert(message:error?.localizedDescription, title: AppConstants.display.Error, inViewController: self)
                }
            })
            .disposed(by: bag)
    }
    
    @objc fileprivate func viewTapped() {
        self.view.endEditing(true)
    }
}
