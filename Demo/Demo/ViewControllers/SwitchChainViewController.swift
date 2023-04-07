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
typealias OasisEmeraldNetwork = ParticleNetwork.OasisEmeraldNetwork
typealias GnosisNetwork = ParticleNetwork.GnosisNetwork
typealias CeloNetwork = ParticleNetwork.CeloNetwork
typealias KlaytnNetwork = ParticleNetwork.KlaytnNetwork
typealias ScrollNetwork = ParticleNetwork.ScrollNetwork
typealias ZkSyncNetwork = ParticleNetwork.ZkSyncNetwork
typealias MetisNetwork = ParticleNetwork.MetisNetwork
typealias ConfluxESpaceNetwork = ParticleNetwork.ConfluxESpaceNetwork
typealias MapoNetwork = ParticleNetwork.MapoNetwork
typealias PolygonZkEVMNetwork = ParticleNetwork.PolygonZkEVMNetwork
typealias BaseNetwork = ParticleNetwork.BaseNetwork

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
        data.append([Chain.solana(.mainnet).uiName: [
            SolanaNetwork.mainnet.rawValue, SolanaNetwork.testnet.rawValue, SolanaNetwork.devnet.rawValue
        ]])
        data.append([Chain.ethereum(.mainnet).uiName: [
            EthereumNetwork.mainnet.rawValue, EthereumNetwork.goerli.rawValue, EthereumNetwork.sepolia.rawValue
        ]])
        data.append([Chain.bsc(.mainnet).uiName: [
            BscNetwork.mainnet.rawValue, BscNetwork.testnet.rawValue
        ]])
        data.append([Chain.polygon(.mainnet).uiName: [
            PolygonNetwork.mainnet.rawValue, PolygonNetwork.mumbai.rawValue
        ]])
        data.append([Chain.avalanche(.mainnet).uiName: [
            AvalancheNetwork.mainnet.rawValue, AvalancheNetwork.testnet.rawValue
        ]])
        data.append([Chain.fantom(.mainnet).uiName: [
            FantomNetwork.mainnet.rawValue, FantomNetwork.testnet.rawValue
        ]])
        data.append([Chain.arbitrum(.one).uiName: [
            ArbitrumNetwork.one.rawValue, ArbitrumNetwork.nova.rawValue, ArbitrumNetwork.goerli.rawValue
        ]])
        data.append([Chain.moonbeam(.mainnet).uiName: [
            MoonbeamNetwork.mainnet.rawValue, MoonbeamNetwork.testnet.rawValue
        ]])
        data.append([Chain.moonriver(.mainnet).uiName: [
            MoonriverNetwork.mainnet.rawValue, MoonriverNetwork.testnet.rawValue
        ]])
        data.append([Chain.heco(.mainnet).uiName: [
            HecoNetwork.mainnet.rawValue, HecoNetwork.testnet.rawValue
        ]])
        data.append([Chain.aurora(.mainnet).uiName: [
            AuroraNetwork.mainnet.rawValue, AuroraNetwork.testnet.rawValue
        ]])
        data.append([Chain.harmony(.mainnet).uiName: [
            HarmonyNetwork.mainnet.rawValue, HarmonyNetwork.testnet.rawValue
        ]])
        data.append([Chain.kcc(.mainnet).uiName: [
            KccNetwork.mainnet.rawValue, KccNetwork.testnet.rawValue
        ]])
        data.append([Chain.optimism(.mainnet).uiName: [
            OptimismNetwork.mainnet.rawValue, OptimismNetwork.goerli.rawValue
        ]])
        data.append([Chain.platON(.mainnet).uiName: [
            PlatONNetwork.mainnet.rawValue, PlatONNetwork.testnet.rawValue
        ]])
        data.append([Chain.tron(.mainnet).uiName: [
            TronNetwork.mainnet.rawValue, TronNetwork.shasta.rawValue, TronNetwork.nile.rawValue
        ]])
        data.append([Chain.okc(.mainnet).uiName: [
            OKCNetwork.mainnet.rawValue, OKCNetwork.testnet.rawValue
        ]])
        data.append([Chain.thunderCore(.mainnet).uiName: [
            ThunderCoreNetwork.mainnet.rawValue, ThunderCoreNetwork.testnet.rawValue
        ]])
        data.append([Chain.cronos(.mainnet).uiName: [
            CronosNetwork.mainnet.rawValue, CronosNetwork.testnet.rawValue
        ]])

        data.append([Chain.gnosis(.mainnet).uiName: [
            GnosisNetwork.mainnet.rawValue, GnosisNetwork.testnet.rawValue
        ]])

        data.append([Chain.celo(.mainnet).uiName: [
            CeloNetwork.mainnet.rawValue, CeloNetwork.testnet.rawValue
        ]])

        data.append([Chain.klaytn(.mainnet).uiName: [
            KlaytnNetwork.mainnet.rawValue, KlaytnNetwork.testnet.rawValue
        ]])

        data.append([Chain.scroll(.testnet).uiName: [
            ScrollNetwork.testnet.rawValue
        ]])

        data.append([Chain.zkSync(.mainnet).uiName: [
            ZkSyncNetwork.mainnet.rawValue, ZkSyncNetwork.testnet.rawValue
        ]])

        data.append([Chain.metis(.mainnet).uiName: [
            MetisNetwork.mainnet.rawValue, MetisNetwork.goerli.rawValue
        ]])

        data.append([Chain.confluxESpace(.mainnet).uiName: [
            ConfluxESpaceNetwork.mainnet.rawValue, ConfluxESpaceNetwork.testnet.rawValue
        ]])

        data.append([Chain.mapo(.mainnet).uiName: [
            MapoNetwork.mainnet.rawValue, MapoNetwork.testnet.rawValue
        ]])

        data.append([Chain.polygonZkEVM(.mainnet).uiName: [
            PolygonZkEVMNetwork.mainnet.rawValue, PolygonZkEVMNetwork.testnet.rawValue
        ]])

        data.append([Chain.base(.testnet).uiName: [
            BaseNetwork.testnet.rawValue
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
        case Chain.solana(.mainnet).uiName:
            chainInfo = .solana(SolanaNetwork(rawValue: network)!)
        case Chain.ethereum(.mainnet).uiName:
            chainInfo = .ethereum(EthereumNetwork(rawValue: network)!)
        case Chain.bsc(.mainnet).uiName:
            chainInfo = .bsc(BscNetwork(rawValue: network)!)
        case Chain.polygon(.mainnet).uiName:
            chainInfo = .polygon(PolygonNetwork(rawValue: network)!)
        case Chain.avalanche(.mainnet).uiName:
            chainInfo = .avalanche(AvalancheNetwork(rawValue: network)!)
        case Chain.fantom(.mainnet).uiName:
            chainInfo = .fantom(FantomNetwork(rawValue: network)!)
        case Chain.arbitrum(.one).uiName:
            chainInfo = .arbitrum(ArbitrumNetwork(rawValue: network)!)
        case Chain.moonbeam(.mainnet).uiName:
            chainInfo = .moonbeam(MoonbeamNetwork(rawValue: network)!)
        case Chain.moonriver(.mainnet).uiName:
            chainInfo = .moonriver(MoonriverNetwork(rawValue: network)!)
        case Chain.heco(.mainnet).uiName:
            chainInfo = .heco(HecoNetwork(rawValue: network)!)
        case Chain.aurora(.mainnet).uiName:
            chainInfo = .aurora(AuroraNetwork(rawValue: network)!)
        case Chain.harmony(.mainnet).uiName:
            chainInfo = .harmony(HarmonyNetwork(rawValue: network)!)
        case Chain.kcc(.mainnet).uiName:
            chainInfo = .kcc(KccNetwork(rawValue: network)!)
        case Chain.optimism(.mainnet).uiName:
            chainInfo = .optimism(OptimismNetwork(rawValue: network)!)
        case Chain.platON(.mainnet).uiName:
            chainInfo = .platON(PlatONNetwork(rawValue: network)!)
        case Chain.tron(.mainnet).uiName:
            chainInfo = .tron(TronNetwork(rawValue: network)!)
        case Chain.okc(.mainnet).uiName:
            chainInfo = .okc(OKCNetwork(rawValue: network)!)
        case Chain.thunderCore(.mainnet).uiName:
            chainInfo = .thunderCore(ThunderCoreNetwork(rawValue: network)!)
        case Chain.cronos(.mainnet).uiName:
            chainInfo = .cronos(CronosNetwork(rawValue: network)!)
        case Chain.klaytn(.mainnet).uiName:
            chainInfo = .klaytn(KlaytnNetwork(rawValue: network)!)
        case Chain.scroll(.testnet).uiName:
            chainInfo = .scroll(ScrollNetwork(rawValue: network)!)
        case Chain.zkSync(.mainnet).uiName:
            chainInfo = .zkSync(ZkSyncNetwork(rawValue: network)!)
        case Chain.metis(.mainnet).uiName:
            chainInfo = .metis(MetisNetwork(rawValue: network)!)
        case Chain.confluxESpace(.mainnet).uiName:
            chainInfo = .confluxESpace(ConfluxESpaceNetwork(rawValue: network)!)
        case Chain.mapo(.mainnet).uiName:
            chainInfo = .mapo(MapoNetwork(rawValue: network)!)
        case Chain.polygonZkEVM(.mainnet).uiName:
            chainInfo = .polygonZkEVM(PolygonZkEVMNetwork(rawValue: network)!)
        case Chain.base(.testnet).uiName:
            chainInfo = .base(BaseNetwork(rawValue: network)!)
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

