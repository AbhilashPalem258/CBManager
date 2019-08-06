//
//  CharcteristicsTableViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 06/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class CharcteristicsTableViewController: UITableViewController {
    
    weak var service: CBService?
    fileprivate let bag = DisposeBag()
    
    var peripheralIndex: Int?
    
    fileprivate lazy var characteristicsVC = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: CharacteristicViewController.self)) as! CharacteristicViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let service = service else {
            return
        }
                
        let charcteristics = BehaviorRelay<[CBCharacteristic]>(value: service.characteristics ?? [])
        
        tableView.tableFooterView = UIView.init()
        tableView.delegate = nil
        tableView.dataSource = nil
        
        self.tableView.register(UINib.init(nibName: String(describing: PheripheralTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PheripheralTableViewCell.self))

        
        charcteristics
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
                self.characteristicsVC.characteristic = charcteristics.value[indexPath.row]
                self.characteristicsVC.peripheralIndex = self.peripheralIndex
                self.navigationController?.pushViewController(self.characteristicsVC, animated: true)
                
            }).disposed(by: bag)
    }
}
