//
//  SwitchChainViewController.swift
//  Demo
//
//  Created by link on 2022/6/6.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import ParticleAuthService
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit

typealias Chain = ParticleNetwork.ChainInfo
typealias SolanaNetwork = ParticleNetwork.SolanaNetwork
typealias EthereumNetwork = ParticleNetwork.EthereumNetwork
typealias BscNetwork = ParticleNetwork.BscNetwork
typealias PolygonNetwork = ParticleNetwork.PolygonNetwork
typealias AvalancheNetwork = ParticleNetwork.AvalancheNetwork
typealias FantomNetwork = ParticleNetwork.FantomNetwork
typealias ArbitrumNetwork = ParticleNetwork.ArbitrumNetwork
typealias MoonbeamNetwork = ParticleNetwork.MoonbeamNetwork
typealias MoonriverNetwork = ParticleNetwork.MoonriverNetwork
typealias HecoNetwork = ParticleNetwork.HecoNetwork
typealias AuroraNetwork = ParticleNetwork.AuroraNetwork
typealias HarmonyNetwork = ParticleNetwork.HarmonyNetwork
typealias KccNetwork = ParticleNetwork.KccNetwork
typealias OptimismNetwork = ParticleNetwork.OptimismNetwork
typealias PlatONNetwork = ParticleNetwork.PlatONNetwork
typealias TronNetwork = ParticleNetwork.TronNetwork
typealias OKCNetwork = ParticleNetwork.OKCNetwork
typealias ThunderCoreNetwork = ParticleNetwork.ThunderCoreNetwork
typealias CronosNetwork = ParticleNetwork.CronosNetwork

class SwitchChainViewController: UIViewController {
    let bag = DisposeBag()

    var selectHandler: (() -> Void)?
    let tableView = UITableView(frame: .zero, style: .grouped)

    var data: [[String: [String]]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        configureTableView()
    }

    func configureData() {
        data.append([Chain.solana(.mainnet).name: [
            SolanaNetwork.mainnet.rawValue, SolanaNetwork.testnet.rawValue, SolanaNetwork.devnet.rawValue
        ]])
        data.append([Chain.ethereum(.mainnet).name: [
            EthereumNetwork.mainnet.rawValue, EthereumNetwork.goerli.rawValue
        ]])
        data.append([Chain.bsc(.mainnet).name: [
            BscNetwork.mainnet.rawValue, BscNetwork.testnet.rawValue
        ]])
        data.append([Chain.polygon(.mainnet).name: [
            PolygonNetwork.mainnet.rawValue, PolygonNetwork.mumbai.rawValue
        ]])
        data.append([Chain.avalanche(.mainnet).name: [
            AvalancheNetwork.mainnet.rawValue, AvalancheNetwork.testnet.rawValue
        ]])
        data.append([Chain.fantom(.mainnet).name: [
            FantomNetwork.mainnet.rawValue, FantomNetwork.testnet.rawValue
        ]])
        data.append([Chain.arbitrum(.mainnet).name: [
            ArbitrumNetwork.mainnet.rawValue, ArbitrumNetwork.goerli.rawValue
        ]])
        data.append([Chain.moonbeam(.mainnet).name: [
            MoonbeamNetwork.mainnet.rawValue, MoonbeamNetwork.testnet.rawValue
        ]])
        data.append([Chain.moonriver(.mainnet).name: [
            MoonriverNetwork.mainnet.rawValue, MoonriverNetwork.testnet.rawValue
        ]])
        data.append([Chain.heco(.mainnet).name: [
            HecoNetwork.mainnet.rawValue, HecoNetwork.testnet.rawValue
        ]])
        data.append([Chain.aurora(.mainnet).name: [
            AuroraNetwork.mainnet.rawValue, AuroraNetwork.testnet.rawValue
        ]])
        data.append([Chain.harmony(.mainnet).name: [
            HarmonyNetwork.mainnet.rawValue, HarmonyNetwork.testnet.rawValue
        ]])
        data.append([Chain.kcc(.mainnet).name: [
            KccNetwork.mainnet.rawValue, KccNetwork.testnet.rawValue
        ]])
        data.append([Chain.optimism(.mainnet).name: [
            OptimismNetwork.mainnet.rawValue, OptimismNetwork.goerli.rawValue
        ]])
        data.append([Chain.platON(.mainnet).name: [
            PlatONNetwork.mainnet.rawValue, PlatONNetwork.testnet.rawValue
        ]])
        data.append([Chain.tron(.mainnet).name: [
            TronNetwork.mainnet.rawValue, TronNetwork.shasta.rawValue, TronNetwork.nile.rawValue
        ]])
        data.append([Chain.okc(.mainnet).name: [
            OKCNetwork.mainnet.rawValue, OKCNetwork.testnet.rawValue
        ]])
        data.append([Chain.thunderCore(.mainnet).name: [
            ThunderCoreNetwork.mainnet.rawValue, ThunderCoreNetwork.testnet.rawValue
        ]])
        data.append([Chain.cronos(.mainnet).name: [
            CronosNetwork.mainnet.rawValue, CronosNetwork.testnet.rawValue
        ]])
    }

    func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SwitchChainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].values.first?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        let network = data[indexPath.section].values.first?[indexPath.row] ?? ""
        cell.textLabel?.text = network
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        data[section].keys.first
    }
}

extension SwitchChainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let network = data[indexPath.section].values.first?[indexPath.row] ?? ""
        let name = data[indexPath.section].keys.first ?? ""

        var chainInfo: Chain
        switch name {
        case Chain.solana(.mainnet).name:
            chainInfo = .solana(SolanaNetwork(rawValue: network)!)
        case Chain.ethereum(.mainnet).name:
            chainInfo = .ethereum(EthereumNetwork(rawValue: network)!)
        case Chain.bsc(.mainnet).name:
            chainInfo = .bsc(BscNetwork(rawValue: network)!)
        case Chain.polygon(.mainnet).name:
            chainInfo = .polygon(PolygonNetwork(rawValue: network)!)
        case Chain.avalanche(.mainnet).name:
            chainInfo = .avalanche(AvalancheNetwork(rawValue: network)!)
        case Chain.fantom(.mainnet).name:
            chainInfo = .fantom(FantomNetwork(rawValue: network)!)
        case Chain.arbitrum(.mainnet).name:
            chainInfo = .arbitrum(ArbitrumNetwork(rawValue: network)!)
        case Chain.moonbeam(.mainnet).name:
            chainInfo = .moonbeam(MoonbeamNetwork(rawValue: network)!)
        case Chain.moonriver(.mainnet).name:
            chainInfo = .moonriver(MoonriverNetwork(rawValue: network)!)
        case Chain.heco(.mainnet).name:
            chainInfo = .heco(HecoNetwork(rawValue: network)!)
        case Chain.aurora(.mainnet).name:
            chainInfo = .aurora(AuroraNetwork(rawValue: network)!)
        case Chain.harmony(.mainnet).name:
            chainInfo = .harmony(HarmonyNetwork(rawValue: network)!)
        case Chain.kcc(.mainnet).name:
            chainInfo = .kcc(KccNetwork(rawValue: network)!)
        case Chain.optimism(.mainnet).name:
            chainInfo = .optimism(OptimismNetwork(rawValue: network)!)
        case Chain.platON(.mainnet).name:
            chainInfo = .platON(PlatONNetwork(rawValue: network)!)
        case Chain.tron(.mainnet).name:
            chainInfo = .tron(TronNetwork(rawValue: network)!)
        case Chain.okc(.mainnet).name:
            chainInfo = .okc(OKCNetwork(rawValue: network)!)
        case Chain.thunderCore(.mainnet).name:
            chainInfo = .thunderCore(ThunderCoreNetwork(rawValue: network)!)
        case Chain.cronos(.mainnet).name:
            chainInfo = .cronos(CronosNetwork(rawValue: network)!)
        default:
            chainInfo = .ethereum(.mainnet)
        }

        ParticleNetwork.setChainInfo(chainInfo)

        let alert = UIAlertController(title: "Switch network", message: "current network is \(name) - \(network)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in

            if let selectHandler = self.selectHandler {
                selectHandler()
            }
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
//        }
    }
}

