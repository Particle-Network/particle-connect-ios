//
//  SwitchChainViewController.swift
//  ConnectKitDemo
//
//  Created by link on 31/07/2024.
//

import Foundation
import ParticleConnect
import ParticleNetworkBase
import ParticleNetworkChains
import RxSwift
import UIKit

class SwitchChainViewController: UIViewController {
    let bag = DisposeBag()

    var selectHandler: (() -> Void)?
    let tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SwitchChainViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChainInfo.allNetworks.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        let chainInfo = ChainInfo.allNetworks[indexPath.row]
        let network = chainInfo.uiName + " " + String(chainInfo.chainId)
        cell.textLabel?.text = network
        cell.selectionStyle = .none
        return cell
    }
}

extension SwitchChainViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chainInfo = ChainInfo.allNetworks[indexPath.row]

        ParticleNetwork.setChainInfo(chainInfo)

        let network = chainInfo.uiName + " " + String(chainInfo.chainId)
        let alert = UIAlertController(title: "Switch chain", message: "current chain is \(network)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in

            if let selectHandler = self.selectHandler {
                selectHandler()
            }
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }
}


