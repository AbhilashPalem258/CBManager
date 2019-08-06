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

class BLEDevicesVC: UIViewController {
    
   @IBOutlet weak var bleDevicesTableView: UITableView!
    
   fileprivate let bag = DisposeBag()
   fileprivate let CBManagerInstance = CBManager.shared
   let peripheralVc = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: PeripheralViewController.self)) as? PeripheralViewController
    
   lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.init()
        activity.style = UIActivityIndicatorView.Style.white
    
        return activity
    }()
    
    lazy var noPeripheralsMsgLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.bleDevicesTableView.bounds.size.width, height: self.bleDevicesTableView.bounds.size.height))
        label.text = "Please switch on to scan for bluetooth devices"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.init(name: "Palatino-Italic", size: 20.0)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var scanSwitch: UISwitch = {
        let scanSwitch = UISwitch.init()
        scanSwitch.isOn = false
        scanSwitch.addTarget(self, action: #selector(scanAction), for: UIControl.Event.valueChanged)
        
        return scanSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.bleDevicesTableView.register(UINib.init(nibName: String(describing: PheripheralTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PheripheralTableViewCell.self))

        CBManagerInstance.vc = self
        bleDevicesTableView.tableFooterView = UIView.init()
        CBManagerInstance.segments
            .bind(to: bleDevicesTableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PheripheralTableViewCell.self), for: IndexPath(row: row, section: 0)) as! PheripheralTableViewCell
                cell.nameLabel.text = element.peripheral.name ?? "Unnamed Service"
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
            self.navigationController?.pushViewController(destinationVc, animated: true)
            
        }).disposed(by: bag)
        
        CBManagerInstance.segments.asObservable().subscribe(onNext: {[unowned self] (devices) in
            self.bleDevicesTableView.backgroundView =  (devices.count == 0) ? self.noPeripheralsMsgLabel : UIView.init()
            self.bleDevicesTableView.separatorStyle = (devices.count == 0) ? .none : .singleLine
        })
        .disposed(by: bag)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: scanSwitch)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}
extension BLEDevicesVC {
    @objc func scanAction(_ sender: Any) {
        CBManager.shared.toggleBluetoothOnOffState()
        CBManager.shared.isScanning ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
