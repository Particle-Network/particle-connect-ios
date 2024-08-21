//
//  AppDelegate.swift
//  ParticleConnect
//
//  Created by link on 2022/7/13.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import AuthCoreAdapter
import Base58_swift
import ConnectCommon
import ConnectEVMAdapter
import ConnectPhantomAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import ParticleConnect
import ParticleNetworkBase
import ParticleNetworkChains
import TweetNacl
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()

        var adapters: [ConnectAdapter] = [
            AuthCoreAdapter(),
            MetaMaskConnectAdapter(),
            PhantomConnectAdapter(),
            WalletConnectAdapter(),
            RainbowConnectAdapter(),
            BitgetConnectAdapter(),
            ImtokenConnectAdapter(),
            TrustConnectAdapter(),
            ZerionConnectAdapter(),
            MathConnectAdapter(),
            Inch1ConnectAdapter(),
            ZengoConnectAdapter(),
            AlphaConnectAdapter(),
            OKXConnectAdapter(),
            EVMConnectAdapter(),
            SolanaConnectAdapter()
        ]

        let env: ParticleNetwork.DevEnvironment = .debug

//        ParticleConnect.setWalletConnectV2SupportChainInfos([.ethereum, .polygon])

        ParticleConnect.initialize(env: env, chainInfo: .ethereum, dAppData: .standard, adapters: adapters)

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if ParticleConnect.handleUrl(url) {
            return true
        }

        return true
    }
}
