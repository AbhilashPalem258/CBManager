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

//MARK: - ServicesTableViewController
final class ServicesTableViewController: RUITableViewController {
    
    //MARK: Member Declarations
    var peripheralIndex: Int?
    
    //MARK: Fileprivate Member Declarations
    fileprivate let bag = DisposeBag()
    fileprivate lazy var characteristicsVC = CharcteristicsTableViewController.init(style: .plain)
    fileprivate var services: BehaviorRelay<[CBService]>!
    
    //MARK: ViewLifeCycle Methods Implementations
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = AppConstants.VCTitles.serviceVC
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let index = peripheralIndex else {
            return
        }
        
        let model = CBManager.shared.peripherals.value[index]
        
        services = BehaviorRelay<[CBService]>(value: model.peripheral.services ?? [])
        configureTableView()
        handleTableView(services: services)
    }
}

//MARK: - ServicesTableViewController: Private Method Implementation
extension ServicesTableViewController {
    fileprivate func handleTableView(services: BehaviorRelay<[CBService]>) {
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
