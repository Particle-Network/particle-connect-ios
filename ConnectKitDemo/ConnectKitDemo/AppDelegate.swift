//
//  AppDelegate.swift
//  ConnectKitDemo
//
//  Created by link on 31/05/2024.
//

import AuthCoreAdapter
import ConnectCommon
import ConnectPhantomAdapter
import ConnectWalletConnectAdapter
import ParticleConnect
import ParticleNetworkBase
import ParticleNetworkChains
import ParticleWalletConnect
import ParticleWalletGUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let adapters: [ConnectAdapter] = [
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
            OKXConnectAdapter()
        ]

        ParticleConnect.initialize(env: .debug, chainInfo: .ethereum, dAppData: .standard, adapters: adapters)
        ParticleConnect.setWalletConnectV2SupportChainInfos([.ethereum, .bnbChain])
        let walletConnectProjectId = "75ac08814504606fc06126541ace9df6"
        ParticleConnect.setWalletConnectV2ProjectId(walletConnectProjectId)
        ParticleWalletConnect.initialize(
            WalletMetaData(name: "Particle Wallet",
                           icon: URL(string: "https://connect.particle.network/icons/512.png")!,
                           url: URL(string: "https://particle.network")!,
                           description: "Particle Connect is a decentralized wallet connection protocol that makes it easy for users to connect their wallets to your DApp.", redirectUniversalLink: nil)
        )
        ParticleWalletConnect.setWalletConnectV2ProjectId(walletConnectProjectId)
        ParticleWalletGUI.setAdapters(adapters)

        ParticleWalletGUI.setShowLanguageSetting(true)
        ParticleWalletGUI.setShowTestNetwork(true)
        ParticleWalletGUI.setShowAppearanceSetting(true)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

