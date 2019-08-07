//
//  RUITableViewController.swift
//  CBVogoManager
//
//  Created by Abhilash Palem on 07/08/19.
//  Copyright © 2019 Abhilash Palem. All rights reserved.
//

import UIKit

class RUITableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
     func configureTableView() {
        tableView.tableFooterView = UIView.init()
        tableView.rowHeight = 60
        tableView.delegate = nil
        tableView.dataSource = nil
        self.tableView.register(UINib.init(nibName: String(describing: PheripheralTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PheripheralTableViewCell.self))
    }
}
