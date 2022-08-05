//
//  SelectWalletModel.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit
import ConnectCommon

extension WalletType: CaseIterable {
    public static var allCases: [WalletType] {
        return [.particle, .metaMask, .rainbow, .trust, .imtoken, .bitkeep, .walletConnect, .phantom, .evmPrivateKey, .solanaPrivateKey]
    }
    
    var name: String {
        switch self {
        case .particle:
            return "Particle"
        case .metaMask:
            return "MetaMask"
        case .rainbow:
            return "Rainbow"
        case .trust:
            return "Trust"
        case .imtoken:
            return "ImToken"
        case .bitkeep:
            return "BitKeep"
        case .walletConnect:
            return "WalletConnect"
        case .phantom:
            return "Phantom"
        case .evmPrivateKey:
            return "EVM Connect"
        case .solanaPrivateKey:
            return "Solana Connect"
        case .custom(let info):
            return info.name
        }
    }
    
    var imageName: String {
        switch self {
        case .particle:
            return "particle"
        case .metaMask:
            return "metamask"
        case .rainbow:
            return "rainbow"
        case .trust:
            return "trust"
        case .imtoken:
            return "imtoken"
        case .bitkeep:
            return "bitkeep"
        case .walletConnect:
            return "walletconnect"
        case .phantom:
            return "phantom"
        case .evmPrivateKey:
            return "ethereum"
        case .solanaPrivateKey:
            return "solana"
        case .custom(_):
            return "walletconnect"
        }
    }
}
  


struct SelectWalletModel {
    let name: String
    let image: UIImage
}
