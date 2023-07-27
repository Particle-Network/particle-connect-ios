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
    
    var data: [WalletType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectWalletCell.self, forCellReuseIdentifier: NSStringFromClass(SelectWalletCell.self))
        tableView.rowHeight = 62
        loadData()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectWalletCell.self), for: indexPath) as! SelectWalletCell
        let wallet = data[indexPath.row]
        if let imageUrl = URL(string: wallet.imageName) {
            cell.iconImageView.sd_setImage(with: imageUrl)
        }
        
        cell.nameLabel.text = wallet.name
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
       
        case .custom(let adapterInfo):
            adapter = adapters.first {
                $0.walletType == .custom(info: adapterInfo)
            }!
        
        default:
            break
        }
        
        if adapter.readyState == .notDetected {
            showToast(title: "Error", message: "You haven't installed this wallet.")
            return
        }
        
        if adapter.readyState == .unsupported {
            showToast(title: "Error", message: "The wallet is not support current chain")
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
            } else if walletType == .particle {
                single = adapter.connect(ParticleAuthConfig(loginType: .phone))
            } else {
                single = adapter.connect(ConnectConfig.none)
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
                        // though before walletType value is walletConnect
                        // user also can login from metamask, rainbow and so on.
                        // the account.walletType is the real from
                        
                        let connectWalletModel = ConnectWalletModel(publicAddress: account.publicAddress, name: account.name, url: account.url, icons: account.icons, description: account.description, walletType: account.walletType, chainId: ConnectManager.getChainId())
                                            
                        WalletManager.shared.updateWallet(connectWalletModel)
                        
                        self.showToast(title: "Success", message: nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }.disposed(by: bag)
        }
    }
    
    func loadData() {
        data = WalletType.allCases
    }
}
