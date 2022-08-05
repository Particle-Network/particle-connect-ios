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

        ParticleConnect.initialize(env: .debug, chainName: .ethereum(.mainnet), dAppData: DAppMetaData(name: "Test", icon: URL(string: "https://static.particle.network/wallet-icons/Particle.png")!, url: URL(string: "https://static.particle.network")!)) {
            [ParticleConnectAdapter(),
             WalletConnectAdapter(),
             MetaMaskConnectAdapter(),
             PhantomConnectAdapter(),
             EVMConnectAdapter(),
             SolanaConnectAdapter(),
             ImtokenConnectAdapter(),
             BitkeepConnectAdapter(),
             RainbowConnectAdapter(),
             TrustConnectAdapter()]
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if ParticleConnect.handleUrl(url) {
            return true
        }

        return true
    }
}
