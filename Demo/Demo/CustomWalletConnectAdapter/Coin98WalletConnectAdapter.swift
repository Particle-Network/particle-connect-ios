//
//  Coin98WalletConnectAdapter.swift
//  Demo
//
//  Created by link on 2023-02-03.
//

import ConnectCommon
import ConnectWalletConnectAdapter
import Foundation

/// How to define a custom wallet connect adapter
/// for examle coin98 wallet
/// 1. subclass from WalletConnectAdapter
/// 2. override walletType, provide a AdapterInfo object
/// don't use teh same redirectUrlHost with other connect adapters
/// if the app has a universal link, like metamask's is "https://metamask.app.link/"
/// set it to deeplink
/// if the app doesn't have a universal link, set scheme as the deeplink
/// if the app has neither universal link nor scheme,
/// it is not ready for wallet connect.
public class Coin98WalletConnectAdapter: WalletConnectAdapter {
    public override var walletType: WalletType {
        return WalletType.custom(info: AdapterInfo.init(name: "Coin98",
                     url: "https://coin98.com/",
                     icon: "https://registry.walletconnect.com/v2/logo/md/dee547be-936a-4c92-9e3f-7a2350a62e00",
                     redirectUrlHost: "coin98",
                     supportChains: [.evm],
                     deepLink: "coin98://",
                     scheme: "coin98://"))
    }
}
