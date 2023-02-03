//
//  ImportPrivateKeyViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectEVMAdapter
import ConnectSolanaAdapter
import Foundation
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit

class ImportPrivateKeyViewController: UIViewController {
    let bag = DisposeBag()
    
    var chainType: ChainType = .evm
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    
    @IBAction func importPrivateKey() {
        let privateKey = textView.text ?? ""
//        guard !privateKey.isEmpty else { return }
        
        var adapter: ConnectAdapter
        if chainType == .solana {
            adapter = ParticleConnect.getAdapters(chainType: .solana).first {
                $0 is SolanaConnectAdapter
            }!
        } else {
            adapter = ParticleConnect.getAdapters(chainType: .evm).first {
                $0 is EVMConnectAdapter
            }!
        }
        
        var single: Single<Account?>
        if privateKey.split(separator: " ").count > 4 {
            single = (adapter as! LocalAdapter).importWalletFromMnemonic(privateKey)
        } else {
            single = (adapter as! LocalAdapter).importWalletFromPrivateKey(privateKey)
        }
        
        single.subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                self.showToast(title: "Error", message: "\(error)")
            case .success(let account):
                print(account)
                if let account = account {
                    var chainId = 1
                    if self.chainType == .solana {
                        chainId = 101
                    } else {
                        chainId = 1
                    }
                    let walletType: WalletType = self.chainType == .solana ? WalletType.solanaPrivateKey : WalletType.evmPrivateKey
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
