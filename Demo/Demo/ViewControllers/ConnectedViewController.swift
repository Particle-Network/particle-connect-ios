//
//  ConnectedViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectEVMAdapter
import ConnectSolanaAdapter
import Foundation
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import SDWebImage
import SwiftUI
import UIKit

class ConnectedViewController: UITableViewController {
    let bag = DisposeBag()
    
    var data: [ConnectWalletModel] = []
    
    @IBOutlet var titleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectWalletCell.self, forCellReuseIdentifier: NSStringFromClass(SelectWalletCell.self))
        tableView.rowHeight = 62
        loadData()
        
        
        
        let evmAdapter = ParticleConnect.getAllAdapters().filter {
            $0.walletType == .evmPrivateKey
        }.first! as! EVMConnectAdapter
        let evmAccounts = evmAdapter.getAccounts()
        if let account = evmAccounts.first {
            evmAdapter.exportWalletPrivateKey(publicAddress: account.publicAddress).subscribe { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let privateKey):
                    print("evm private key = \(privateKey)")
                }
            }.disposed(by: bag)
        }
        
        let solanaAdapter = ParticleConnect.getAllAdapters().filter {
            $0.walletType == .solanaPrivateKey
        }.first! as! SolanaConnectAdapter
        let solanaAccounts = solanaAdapter.getAccounts()
        if let account = solanaAccounts.first {
            solanaAdapter.exportWalletPrivateKey(publicAddress: account.publicAddress).subscribe { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let privateKey):
                    print("solana private key = \(privateKey)")
                }
            }.disposed(by: bag)
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
           
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                
                let vc = UIAlertController(title: "Delete Wallet", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let model = self.data[indexPath.row]
                    let adapters = ParticleConnect.getAdapterByAddress(publicAddress: model.publicAddress).filter {
                        $0.walletType == model.walletType
                    }
                    
                    let adapter = adapters.first!
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
                }
                
                vc.addAction(cancel)
                vc.addAction(delete)
            
                present(vc, animated: true)
            }
        }
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
        let name = ParticleNetwork.getChainInfo().name
        let network = ParticleNetwork.getChainInfo().network
        
        titleButton.setTitle("\(name) \n \(network.lowercased())", for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectWalletCell.self), for: indexPath) as! SelectWalletCell
        let model = data[indexPath.row]
        if let imageUrl = URL(string: model.walletType.imageName) {
            cell.iconImageView.sd_setImage(with: imageUrl)
        }
        
        cell.nameLabel.text = model.walletType.name
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
                $0.publicAddress == connectWalletModel.publicAddress && element.walletType == connectWalletModel.walletType
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
        data = WalletManager.shared.getWallets().filter { connectWalletModel in
            let adapters = ParticleConnect.getAdapterByAddress(publicAddress: connectWalletModel.publicAddress).filter {
                $0.isConnected(publicAddress: connectWalletModel.publicAddress) && $0.walletType == connectWalletModel.walletType
            }
            return !adapters.isEmpty
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        let model = data[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Disconnect", handler: { _, _,
                _ in
            let adapters = ParticleConnect.getAdapterByAddress(publicAddress: model.publicAddress).filter {
                $0.walletType == model.walletType
            }
            
            let adapter = adapters.first
            // when wallet remove this connected session, local session cache should remove, and the adapter is nil
            if adapter != nil {
                adapter!.disconnect(publicAddress: model.publicAddress).subscribe { [weak self] result in
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
            } else {
                WalletManager.shared.removeWallet(model)
                self.loadData()
            }
            
        })
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy Address", handler: { _, _,
                _ in
            UIPasteboard.general.string = model.publicAddress
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, copyAction])
        return configuration
    }
    
    
}
