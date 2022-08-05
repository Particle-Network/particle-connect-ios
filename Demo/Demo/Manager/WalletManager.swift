//
//  WalletManager.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import ConnectCommon

extension DefaultsKeys {
    var connectedWallets: DefaultsKey<[ConnectWalletModel]> {.init(#function, defaultValue: [])}
}

    
class WalletManager {
    static let shared: WalletManager = .init()
        
    func getWallets() -> [ConnectWalletModel] {
        Defaults.connectedWallets
    }
        
    func getWallets(walletType: WalletType) -> [ConnectWalletModel] {
        Defaults.connectedWallets.filter {
            $0.walletType == walletType
        }
    }
        
    func updateWallet(_ model: ConnectWalletModel) {
        Defaults.connectedWallets.appendOrReplace(model)
    }
        
    func removeWallet(_ model: ConnectWalletModel) {
        Defaults.connectedWallets.removeAll {
            $0 == model
        }
    }
}
