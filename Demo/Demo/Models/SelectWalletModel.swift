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
        return [.particle, .metaMask, .rainbow, .trust, .imtoken, .bitkeep, .walletConnect, .phantom, .evmPrivateKey, .solanaPrivateKey]
    }

    var name: String {
        return info.name
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
        case .custom:
            return "walletconnect"
        }
    }
}

struct SelectWalletModel {
    let name: String
    let image: UIImage
}
