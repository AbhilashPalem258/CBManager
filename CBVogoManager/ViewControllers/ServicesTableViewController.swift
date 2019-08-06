//
//  ServicesTableViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class ServicesTableViewController: UITableViewController {
    
    var peripheralIndex: Int?
    
    fileprivate let bag = DisposeBag()
    
    fileprivate lazy var characteristicsVC = CharcteristicsTableViewController.init(style: .plain)
    
    fileprivate var services: BehaviorRelay<[CBService]>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.peripherals.value[index]
        
        services = BehaviorRelay<[CBService]>(value: model.peripheral.services ?? [])
        
        tableView.tableFooterView = UIView.init()
        tableView.delegate = nil
        tableView.dataSource = nil
        
        self.tableView.register(UINib.init(nibName: String(describing: PheripheralTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PheripheralTableViewCell.self))

        services
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PheripheralTableViewCell.self), for: IndexPath(row: row, section: 0)) as! PheripheralTableViewCell
                cell.nameLabel.text = element.uuid.uuidString
                return cell
            }
            .disposed(by: bag)
        
        tableView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                
                self.characteristicsVC.service = self.services.value[indexPath.row]
                self.characteristicsVC.peripheralIndex = self.peripheralIndex
                self.navigationController?.pushViewController(self.characteristicsVC, animated: true)
                
            }).disposed(by: bag)
    }
}
