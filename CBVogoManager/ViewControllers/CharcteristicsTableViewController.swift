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

//MARK: - CharcteristicsTableViewController
final class CharcteristicsTableViewController: RUITableViewController {
    
    //MARK: Member Declarations
    weak var service: CBService?
    var peripheralIndex: Int?
    
    //MARK: Fileprivate Member Declarations
    fileprivate let bag = DisposeBag()

    //MARK: ViewLifeCycle Methods Implementations
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = AppConstants.VCTitles.characteristicsVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let service = service else {
            return
        }
        
        let charcteristics = BehaviorRelay<[CBCharacteristic]>(value: service.characteristics ?? [])
        configureTableView()
        handleTableView(charcteristics: charcteristics)
    }
}

//MARK: - CharcteristicsTableViewController: FilePrivate Methods implementation
extension CharcteristicsTableViewController {
    fileprivate func handleTableView(charcteristics: BehaviorRelay<[CBCharacteristic]>) {
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
                guard indexPath.row < charcteristics.value.count else {
                    print("invalid execution.")
                    return
                }
                
                let characteristicsVC = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: CharacteristicViewController.self)) as! CharacteristicViewController
                characteristicsVC.characteristic = charcteristics.value[indexPath.row]
                characteristicsVC.peripheralIndex = self.peripheralIndex
                if (self.navigationController?.topViewController?.isKind(of: CharcteristicsTableViewController.self))! {
                    self.navigationController?.pushViewController(characteristicsVC, animated: true)
                }                
            }).disposed(by: bag)
    }
}
