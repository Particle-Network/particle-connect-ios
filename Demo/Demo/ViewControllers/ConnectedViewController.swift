//
//  ConnectedViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import ParticleConnect
import ParticleNetworkBase
import UIKit
import RxSwift


class ConnectedViewController: UITableViewController {
    let bag = DisposeBag()
    
    var data: [ConnectWalletModel] = []
    
    @IBOutlet var titleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectWalletCell.self, forCellReuseIdentifier: NSStringFromClass(SelectWalletCell.self))
        tableView.rowHeight = 62
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updateUI()
    }
    
    @IBAction func switchChain() {
        let vc = SwitchChainViewController()
        vc.selectHandler = { [weak self] in
            self?.updateUI()
        }
        present(vc, animated: true)
    }
    
    @IBAction func addNewWallet() {
        let vc = SelectWalletViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateUI() {
        let name = ParticleNetwork.getChainName().nameString
        let network = ParticleNetwork.getChainName().network
        
        titleButton.setTitle("\(name) \n \(network.lowercased())", for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectWalletCell.self), for: indexPath) as! SelectWalletCell
        let model = data[indexPath.row]
        cell.imageView?.image = UIImage(named: model.walletType.imageName)
        cell.textLabel?.text = model.walletType.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let connectWalletModel = data[indexPath.row]
        let adapters = ParticleConnect.getAdapters(chainType: .evm) + ParticleConnect.getAdapters(chainType: .solana)
        
        let adapter = adapters.first { element in
            let accounts = element.getAccounts()
            let account = accounts.first {
                $0.publicAddress == connectWalletModel.publicAddress
            }
            if account != nil {
                return true
            } else {
                return false
            }
        }
        
        if adapter != nil {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ActionViewController") as! ActionViewController
            vc.adapter = adapter
            vc.connectWalletModel = connectWalletModel
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loadData() {
        data = WalletManager.shared.getWallets()
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        let model = data[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Disconnect", handler: { _, _,
                _ in
            let adapter = ParticleConnect.getAdapterByAddress(publicAddress: model.publicAddress)!
            adapter.disconnect(publicAddress: model.publicAddress).subscribe { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let string):
                    print(string)
                    WalletManager.shared.removeWallet(model)
                }
                
                self.loadData()
            }.disposed(by: self.bag)
        })
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy Address", handler: { _, _,
                _ in
            UIPasteboard.general.string = model.publicAddress
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, copyAction])
        return configuration
    }
}
