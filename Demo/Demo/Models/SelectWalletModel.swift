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
        return [
            WalletType.authCore,
            WalletType.evmPrivateKey,
            WalletType.solanaPrivateKey,
            WalletType.metaMask,
            WalletType.rainbow,
            WalletType.walletConnect,
            WalletType.trust,
            WalletType.phantom,
            WalletType.imtoken,
            WalletType.bitget,
            WalletType.zerion,
            WalletType.math,
            WalletType.inch1,
            WalletType.zengo,
            WalletType.alpha,
            WalletType.okx
        ]
    }

    var name: String {
        return info.name
    }

    var imageName: String {
        return info.icon
    }
}

struct SelectWalletModel {
    let name: String
    let image: UIImage
}

