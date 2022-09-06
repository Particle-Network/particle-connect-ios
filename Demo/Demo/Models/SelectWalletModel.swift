//
//  SelectWalletModel.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import Foundation
import UIKit

extension WalletType: CaseIterable {
    public static var allCases: [WalletType] {
        return [.particle, .metaMask, .rainbow, .trust, .imtoken, .bitkeep, .walletConnect, .phantom, .evmPrivateKey, .solanaPrivateKey, .gnosis]
    }

    var name: String {
        return info.name
    }

    var imageName: String {
        switch self {
        case .particle:
            return "particle"
        case .metaMask:
            return "login_metamask"
        case .rainbow:
            return "login_rainbow"
        case .trust:
            return "login_trust"
        case .imtoken:
            return "login_imtoken"
        case .bitkeep:
            return "login_bitkeep"
        case .walletConnect:
            return "login_wallet_connect"
        case .phantom:
            return "login_phantom"
        case .evmPrivateKey:
            return "ethereum"
        case .solanaPrivateKey:
            return "solana"
        case .gnosis:
            return "login_gnosis"
        case .custom:
            return "login_wallet_connect"
        }
    }
}

struct SelectWalletModel {
    let name: String
    let image: UIImage
}
