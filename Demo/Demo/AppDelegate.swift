//
//  AppDelegate.swift
//  ParticleConnect
//
//  Created by link on 2022/7/13.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectEVMAdapter
import ConnectPhantomAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import ParticleAuthService
import ParticleConnect
import ParticleNetworkBase
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()

        var adapters: [ConnectAdapter] = [
            EVMConnectAdapter(),
            SolanaConnectAdapter(),
            MetaMaskConnectAdapter(),
            ParticleConnectAdapter(),
            PhantomConnectAdapter(),
            WalletConnectAdapter(),
            RainbowConnectAdapter(),
            BitkeepConnectAdapter(),
            ImtokenConnectAdapter(),
            TrustConnectAdapter()
        ]

        let moreAdapterClasses: [WalletConnectAdapter.Type] =
            [ZerionConnectAdapter.self,
             MathConnectAdapter.self,
             OmniConnectAdapter.self,
             Inch1ConnectAdapter.self,
             ZengoConnectAdapter.self,
             AlphaConnectAdapter.self,
             BitpieConnectAdapter.self]

        adapters.append(contentsOf: moreAdapterClasses.map {
            $0.init()
        })

        ParticleConnect.initialize(env: .debug, chainInfo: .ethereum(.mainnet), dAppData: .standard) {
            adapters
        }
        
        ParticleConnect.setWalletConnectV2ProjectId("75ac08814504606fc06126541ace9df6")
        // Set the required chains for WalletConnect v2. If not set, the current chain will be used.
//        ParticleConnect.setWalletConnectV2SupportChainInfos([.ethereum(.mainnet)])

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if ParticleConnect.handleUrl(url) {
            return true
        }

        return true
    }
}
