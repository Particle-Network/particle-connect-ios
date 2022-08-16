//
//  SelectWalletViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectEVMAdapter
import ConnectPhantomAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import Foundation
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit

class SelectWalletViewController: UITableViewController {
    let bag = DisposeBag()
    
    var data: [WalletType] = WalletType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectWalletCell.self, forCellReuseIdentifier: NSStringFromClass(SelectWalletCell.self))
        tableView.rowHeight = 62
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectWalletCell.self), for: indexPath) as! SelectWalletCell
        let wallet = data[indexPath.row]
        cell.imageView?.image = UIImage(named: wallet.imageName)
        cell.textLabel?.text = wallet.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adapters = ParticleConnect.getAdapters(chainType: .solana) + ParticleConnect.getAdapters(chainType: .evm)
        let walletType = data[indexPath.row]
        
        var single: Single<Account?>
        var adapter: ConnectAdapter = adapters[0]
        switch walletType {
        case .metaMask:
            adapter = adapters.first {
                $0.walletType == .metaMask
            }!
        case .particle:
            adapter = adapters.first {
                $0.walletType == .particle
            }!
        case .rainbow:
            adapter = adapters.first {
                $0.walletType == .rainbow
            }!
        case .trust:
            adapter = adapters.first {
                $0.walletType == .trust
            }!
        case .imtoken:
            adapter = adapters.first {
                $0.walletType == .imtoken
            }!
        case .bitkeep:
            adapter = adapters.first {
                $0.walletType == .bitkeep
            }!
        case .phantom:
            adapter = adapters.first {
                $0.walletType == .phantom
            }!
        case .walletConnect:
            adapter = adapters.first {
                $0.walletType == .walletConnect
            }!
        default:
            break
        }
        
        if adapter.readyState == .notDetected {
            self.showToast(title: "Error", message: "You haven't installed this wallet.")
            return
        }
        
        if adapter.readyState == .unsupported {
            self.showToast(title: "Error", message: "The wallet is not support current chain")
            return
        }
        
        if walletType == .solanaPrivateKey {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ImportPrivateKeyViewController") as! ImportPrivateKeyViewController
            vc.chainType = .solana
            navigationController?.pushViewController(vc, animated: true)
        } else if walletType == .evmPrivateKey {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ImportPrivateKeyViewController") as! ImportPrivateKeyViewController
            vc.chainType = .evm
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if walletType == .walletConnect {
                single = (adapter as! WalletConnectAdapter).connectWithQrCode(from: self)
            } else {
                single = adapter.connect(.none)
            }
            
            single.subscribe { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                    self.showToast(title: "Error", message: error.localizedDescription)
                case .success(let account):
                    print(account)
                    if let account = account {
                        var chainId = 1
                        if walletType == .particle {
                            chainId = ParticleNetwork.getChainInfo().chainId
                        } else if walletType == .solanaPrivateKey || walletType == .phantom {
                            chainId = 101
                        } else {
                            chainId = 1
                        }
                        let connectWalletModel = ConnectWalletModel(publicAddress: account.publicAddress, name: account.name, url: account.url, icons: account.icons, description: account.description, walletType: walletType, chainId: chainId)
                        
                        WalletManager.shared.updateWallet(connectWalletModel)
                        
                        self.showToast(title: "Success", message: nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }.disposed(by: bag)
        }
    }
}
