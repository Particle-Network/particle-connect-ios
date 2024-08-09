//
//  ConnectedWalletModel.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import Foundation
import SwiftyUserDefaults

struct ConnectWalletModel: Codable, Equatable, DefaultsSerializable {
    let publicAddress: String
    let name: String?
    let url: String?
    let icons: [String]
    let description: String?

    let walletType: WalletType

    public static var _defaults: DefaultsCodableBridge<ConnectWalletModel>
    { return DefaultsCodableBridge<ConnectWalletModel>() }

    public static var _defaultsArray: DefaultsCodableBridge<[ConnectWalletModel]>
    { return DefaultsCodableBridge<[ConnectWalletModel]>() }

    static func == (lhs: ConnectWalletModel, rhs: ConnectWalletModel) -> Bool {
        if lhs.walletType == .authCore, rhs.walletType == .authCore {
            return true
        } else {
            return lhs.publicAddress.lowercased() == rhs.publicAddress.lowercased() && lhs.walletType == rhs.walletType
        }
    }
}
