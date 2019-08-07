//
//  ViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 05/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: - BLEDevicesVC
final class BLEDevicesVC: RUIViewController {
    
   //MARK: IBOutlet Member Declarations
   @IBOutlet weak var bleDevicesTableView: UITableView!

   //MARK: FilePrivate Member Declarations
   fileprivate let bag = DisposeBag()
   fileprivate let CBManagerInstance = CBManager.shared
   fileprivate let peripheralVc = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: PeripheralViewController.self)) as? PeripheralViewController
    
   //MARK: FilePrivate Computed Member Declarations
   fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.init()
        activity.style = UIActivityIndicatorView.Style.white
    
        return activity
    }()
    
    fileprivate lazy var noPeripheralsMsgLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.bleDevicesTableView.bounds.size.width, height: self.bleDevicesTableView.bounds.size.height))
        label.text =  BLEDevicesVCConstants.switchOnMsg
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = BLEDevicesVCConstants.switchOnMsgFont
        label.sizeToFit()
        
        return label
    }()
    
    fileprivate lazy var scanSwitch: UISwitch = {
        let scanSwitch = UISwitch.init()
        scanSwitch.isOn = false
        scanSwitch.addTarget(self, action: #selector(scanAction), for: UIControl.Event.valueChanged)
        
        return scanSwitch
    }()
    
    //MARK: ViewLifeCycle Methods Implementation
    override func viewDidLoad() {
        super.viewDidLoad()

        CBManagerInstance.navController = self.navigationController
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: scanSwitch)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: activityIndicator)
        
        configuretableView()
        handleTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CBManagerInstance.peripherals.accept([])
        CBManager.shared.toggleBluetoothOnOffState(isOn: scanSwitch.isOn)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        CBManager.shared.toggleBluetoothOnOffState(isOn: false)
    }
    
}
//MARK: - BLEDevicesVC: FilePrivate Methods Implementation
extension BLEDevicesVC {
    @objc fileprivate func scanAction(_ sender: Any) {
        CBManager.shared.toggleBluetoothOnOffState(isOn: scanSwitch.isOn)
        CBManager.shared.isScanning ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    fileprivate func configuretableView() {
        bleDevicesTableView.register(UINib.init(nibName: String(describing: PheripheralTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PheripheralTableViewCell.self))
        bleDevicesTableView.tableFooterView = UIView.init()
    }
    
    fileprivate func handleTableView() {
        CBManagerInstance.peripherals
            .bind(to: bleDevicesTableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PheripheralTableViewCell.self), for: IndexPath(row: row, section: 0)) as! PheripheralTableViewCell
                cell.nameLabel.text = element.peripheral.name ?? AppConstants.display.unnamedService
                return cell
            }
            .disposed(by: bag)
        
        bleDevicesTableView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                
                guard let destinationVc = self.peripheralVc else {
                    return
                }
                
                destinationVc.peripheralIndex = indexPath.row
    
                if (self.navigationController?.topViewController?.isKind(of: BLEDevicesVC.self))! {
                    self.navigationController?.pushViewController(destinationVc, animated: true)
                }
                
            }).disposed(by: bag)
        
        CBManagerInstance.peripherals.asObservable().subscribe(onNext: {[unowned self] (devices) in
            self.bleDevicesTableView.backgroundView =  (devices.count == 0) ? self.noPeripheralsMsgLabel : UIView.init()
            self.bleDevicesTableView.separatorStyle = (devices.count == 0) ? .none : .singleLine
        })
            .disposed(by: bag)

    }
}
