//
//  ViewController.swift
//  ConnectKitDemo
//
//  Created by link on 09/08/2024.
//

import Foundation
import ParticleAA
import ParticleConnectKit
import ParticleNetworkBase
import ParticleNetworkChains
import ParticleWalletGUI
import UIKit

class ViewController: UIViewController {
    @IBOutlet var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func connectParticle() {
        /// language, theme, fiatCoin
        let languageWebString = "en-US"
        let language = Language.allCases.first {
            $0.webString == languageWebString
        }
        ParticleNetwork.setLanguage(language ?? Language.en)

        let fiatCoinString = "USD".lowercased()
        let fiatCoin = FiatCoin.allCases.first {
            $0.rawValue.lowercased() == fiatCoinString
        }
        ParticleNetwork.setFiatCoin(fiatCoin ?? FiatCoin.usd)

        let theme = "light"
        var appearance: UIUserInterfaceStyle
        if theme.lowercased() == "light" {
            appearance = .light
        } else if theme.lowercased() == "dark" {
            appearance = .dark
        } else {
            appearance = .unspecified
        }
        ParticleNetwork.setAppearance(appearance)

        /// prompt config
        let promptPaymentPassword = 1
        let promptMasterPassword = 1

        ParticleNetwork.setSecurityAccountConfig(config: SecurityAccountConfig(promptSettingWhenSign: promptPaymentPassword, promptMasterPasswordSettingWhenLogin: promptMasterPassword))

        let evmChainIds: [Int] = [1, 101, 8453, 42161, 43114, 59144, 56, 10, 137]
        let evmChainInfos = evmChainIds.compactMap {
            ChainInfo.getEvmChain(chainId: $0)
        }
        let solanaChainIds: [Int] = []
        let solanaChainInfos = solanaChainIds.compactMap {
            ChainInfo.getSolanaChain(chainId: $0)
        }

        ParticleWalletGUI.setSupportChain(Set(evmChainInfos + solanaChainInfos))

        /// testnet
        ParticleWalletGUI.setShowTestNetwork(true)

        /// connectOptions
        let connectOptions: [ConnectOption] = [.email, .phone, .social, .wallet]

        /// socialProviders
        let socialProviders: [EnableSocialProvider] = [.google, .apple, .github, .facebook, .twitter, .microsoft, .discord, .twitch, .linkedin]

        /// walletProviders
        let walletProviders: [EnableWalletProvider] = [EnableWalletProvider(name: "metamask", state: .recommended), EnableWalletProvider(name: "phantom", state: .none)]

        /// additionalLayoutOptions
        let additionalLayoutOptions = AdditionalLayoutOptions(isCollapseWalletList: false, isSplitEmailAndSocial: false, isSplitEmailAndPhone: false, isHideContinueButton: false)

        /// designOptions
        let designOptions = DesignOptions(icon: nil)

        let config = ConnectKitConfig(connectOptions: connectOptions, socialProviders: socialProviders, walletProviders: walletProviders, additionalLayoutOptions: additionalLayoutOptions, designOptions: designOptions)

        Task {
            do {
                let account = try await ParticleConnectUI.connect(config: config).value
                // show EOA address
                addressLabel.text = account.publicAddress
                // show smart account address

                let smartAccountAddress = account.smartAccount?.smartAccountAddress

                print("get account \(account)")
                print("eoa address \(account.publicAddress)")
                print("smart account address \(smartAccountAddress)")
            } catch {
                print("get error \(error)")
            }
        }
    }

    @IBAction func openWallet() {
        PNRouter.navigatorWallet(hiddenBackButton: false)
    }
}
