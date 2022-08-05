//
//  ConnectedWalletModel.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import ConnectCommon

struct ConnectWalletModel: Codable, Equatable, DefaultsSerializable {
    let publicAddress: String
    let name: String?
    let url: String?
    let icons: [String]
    let description: String?

    let walletType: WalletType
    var chainId: Int

    public static var _defaults: DefaultsCodableBridge<ConnectWalletModel>
    { return DefaultsCodableBridge<ConnectWalletModel>() }

    public static var _defaultsArray: DefaultsCodableBridge<[ConnectWalletModel]>
    { return DefaultsCodableBridge<[ConnectWalletModel]>() }

    static func == (lhs: ConnectWalletModel, rhs: ConnectWalletModel) -> Bool {
        return lhs.publicAddress == rhs.publicAddress && lhs.walletType == rhs.walletType
    }
}
