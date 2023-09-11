//
//  LoginMoreViewController.swift
//  Demo
//
//  Created by link on 2022/8/15.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectWalletConnectAdapter
import Foundation
import ParticleAuthService
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit

class LoginListViewController: UIViewController {
    private let bag = DisposeBag()
    
    private let titleLabel = UILabel()
    
    private let closeButton = UIButton()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private lazy var data: [[LoginDataModel]] = [
        [LoginDataModel(imageName: .login_email, name: "login with".localized(para: "email".localized())),
         LoginDataModel(imageName: .login_phone, name: "login with".localized(para: "phone number".localized())),
         LoginDataModel(imageName: .login_google, name: "login with".localized(para: "Google")),
         LoginDataModel(imageName: .login_facebook, name: "login with".localized(para: "Facebook")),
         LoginDataModel(imageName: .login_apple, name: "login with".localized(para: "Apple")),
         LoginDataModel(imageName: .login_discord, name: "login with".localized(para: "Discord")),
         LoginDataModel(imageName: .login_github, name: "login with".localized(para: "Github")),
         LoginDataModel(imageName: .login_twitch, name: "login with".localized(para: "Twitch")),
         LoginDataModel(imageName: .login_microsoft, name: "login with".localized(para: "Microsoft")),
         LoginDataModel(imageName: .login_linkedin, name: "login with".localized(para: "Linkedin"))],
        [LoginDataModel(imageName: .login_private_key, name: "login with".localized(para: "private key".localized())),
         LoginDataModel(imageName: .login_metamask, name: "login with".localized(para: "MetaMask")),
         LoginDataModel(imageName: .login_rainbow, name: "login with".localized(para: "Rainbow")),
         LoginDataModel(imageName: .login_trust, name: "login with".localized(para: "Trust")),
         LoginDataModel(imageName: .login_imtoken, name: "login with".localized(para: "imToken")),
         LoginDataModel(imageName: .login_bitkeep, name: "login with".localized(para: "BitKeep")),
         LoginDataModel(imageName: .login_wallet_connect, name: "login with".localized(para: "Wallet Connect")),
         LoginDataModel(imageName: .login_phantom, name: "login with".localized(para: "Phantom"))]
    ]
    
    var successHandler: (((WalletType, Account?)) -> Void)?
    var failureHandler: ((Error) -> Void)?
    
    deinit {
        debugPrint("\(String(describing: self)) deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.bottom.left.right.equalToSuperview()
        }

        closeButton.imageEdgeInsets = .init(top: 0, left: 25, bottom: 25, right: 0)
        
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(19)
            make.centerX.equalToSuperview()
        }
        
        tableView.register(LoginCell.self, forCellReuseIdentifier: NSStringFromClass(LoginCell.self))
        tableView.register(LoginHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(LoginHeaderView.self))
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 62
        tableView.separatorStyle = .none
        tableView.bounces = false
        
        titleLabel.text = "login methods".localized()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        
        closeButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
            }
        }.disposed(by: bag)
    }
}

extension LoginListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LoginCell.self), for: indexPath) as! LoginCell
        let model = data[indexPath.section][indexPath.row]
        
        cell.setName(model.name, image: UIImage(named: model.imageName.rawValue))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(LoginHeaderView.self)) as! LoginHeaderView
            
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension LoginListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = data[indexPath.section][indexPath.row]
        let loginType = model.imageName
        
        switch loginType {
        case .login_email:
            login(type: .email)
        case .login_phone:
            login(type: .phone)
        case .login_google:
            login(type: .google)
        case .login_facebook:
            login(type: .facebook)
        case .login_apple:
            login(type: .apple)
        case .login_discord:
            login(type: .discord)
        case .login_github:
            login(type: .github)
        case .login_twitch:
            login(type: .twitch)
        case .login_microsoft:
            login(type: .microsoft)
        case .login_linkedin:
            login(type: .linkedin)
        case .login_private_key:
            switch ParticleNetwork.getChainInfo().chain {
            case .solana:
                dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ImportPrivateKeyViewController") as! ImportPrivateKeyViewController
                    vc.chainType = .solana
                    UIViewController.topMost?.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ImportPrivateKeyViewController") as! ImportPrivateKeyViewController
                    vc.chainType = .evm
                    UIViewController.topMost?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .login_metamask:
            connect(walletType: .metaMask)
        case .login_rainbow:
            connect(walletType: .rainbow)
        case .login_trust:
            connect(walletType: .trust)
        case .login_imtoken:
            connect(walletType: .imtoken)
        case .login_bitkeep:
            connect(walletType: .bitkeep)
        case .login_wallet_connect:
            connect(walletType: .walletConnect)
        case .login_phantom:
            connect(walletType: .phantom)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension LoginListViewController {
    private func login(type: LoginType, supportAuthType: [SupportAuthType] = [SupportAuthType.all], loginFormMode: Bool = false) {
        let adapter = ParticleConnect.getAllAdapters().filter {
            $0.walletType == .particle
        }.first!
        let config = ParticleAuthConfig(loginType: type, supportAuthType: supportAuthType, phoneOrEmailAccount: nil)
        adapter.connect(config).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    if let failureHandler = self.failureHandler {
                        failureHandler(error)
                    }
                }
            case .success(let account):
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    if let successHandler = self.successHandler {
                        successHandler((adapter.walletType, account))
                    }
                }
            }
        }.disposed(by: bag)
    }

    private func connect(walletType: WalletType) {
        let adapter = ParticleConnect.getAllAdapters().filter {
            $0.walletType == walletType
        }.first!
        
        var single: Single<Account?>
        if adapter.walletType == .walletConnect {
            single = (adapter as! WalletConnectAdapter).connectWithQrCode(from: self)
        } else {
            single = adapter.connect(.none)
        }
        single.subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    if let failureHandler = self.failureHandler {
                        failureHandler(error)
                    }
                }
            case .success(let account):
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    if let successHandler = self.successHandler {
                        successHandler((adapter.walletType, account))
                    }
                }
            }
        }.disposed(by: bag)
    }
}
