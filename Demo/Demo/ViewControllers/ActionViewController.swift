//
//  ActionViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import Foundation
import ParticleAuthService
import ParticleWalletAPI
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit
import SwiftyJSON

class ActionViewController: UIViewController {
    let bag = DisposeBag()
    
    lazy var api = APIService(rpcUrl: RpcUrl.solana)
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var resultLabel: UILabel!
    
    var adapter: ConnectAdapter!
    var connectWalletModel: ConnectWalletModel!
    var siweMessage: SiweMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTextView.layer.cornerRadius = 10
        sourceTextView.layer.masksToBounds = true
        sourceTextView.layer.borderWidth = 1
        sourceTextView.layer.borderColor = UIColor.lightGray.cgColor
        sourceTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        addressLabel.text = "Address:" + " " + getSender()
        
        // Wallet Connect Adapter need reconnect after app launch
        // other sub adapter as MetaMaskConnectAdapter, RainConnectAdaper ... also need reconnect after app launch
        // call reconnectIfNeeded after app launch, or before call other sign methods.
        (adapter as? WalletConnectAdapter)?.reconnectIfNeeded(publicAddress: getSender())
    }
    
    @IBAction func signAndSendTransaction() {
        getTransaction().flatMap { [weak self] transaction in
            guard let self = self else { return .just("") }
            self.sourceTextView.text = transaction
            return self.adapter.signAndSendTransaction(publicAddress: self.getSender(), transaction: transaction)
        }.subscribe { [weak self] (signature: String) in
            guard let self = self else { return }
            print(signature)
            self.resultLabel.text = signature
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else {
                self.resultLabel.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTransaction() {
        getTransaction().flatMap { [weak self] transaction in
            guard let self = self else { return .just("") }
            self.sourceTextView.text = transaction
            return self.adapter.signTransaction(publicAddress: self.getSender(), transaction: transaction)
        }.subscribe { [weak self] (signature: String) in
            guard let self = self else { return }
            print(signature)
            self.resultLabel.text = signature
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else {
                self.resultLabel.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signAllTransactions() {
        Single.zip(getTransaction(), getTransaction()).flatMap { [weak self] transaction1, transaciton2 in
            guard let self = self else { return .just([]) }
            self.sourceTextView.text = transaction1 + "\n" + transaciton2
            return self.adapter.signAllTransactions(publicAddress: self.getSender(), transactions: [transaction1, transaciton2])
        }.subscribe { [weak self] (signatures: [String]) in
            guard let self = self else { return }
            print(signatures)
            self.resultLabel.text = signatures.joined(separator: ",")
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else {
                self.resultLabel.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signMessage() {
        let messgae = getMessage()
        sourceTextView.text = messgae
        adapter.signMessage(publicAddress: getSender(), message: getMessage()).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                self.resultLabel.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTypedData() {
        let typedData = getTypedData()
        sourceTextView.text = typedData
        adapter.signTypeData(publicAddress: getSender(), data: typedData).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                self.resultLabel.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func loginSignInWithEthereum() {
        let message = try! getSiweMessage()
        self.siweMessage = message
        print("message = \(message.description)")
        adapter.login(config: message, publicAddress: getSender()).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let (sourceMessage, signedMessage)):
                print("sourceMessage = \(sourceMessage), \n\nsignedMessage = \(signedMessage)")
                self.resultLabel.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func verify() {
        guard let message = siweMessage else {
            return
        }
        let against = resultLabel.text ?? ""
        adapter.verify(message: message, against: against).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultLabel.text = flag ? "True" : "False"
            }
        }.disposed(by: bag)
    }
    
    @IBAction func switchEthereumChain() {
        let publicAddress = getSender()
        let chainInfo = ParticleNetwork.ChainInfo.polygon(.mainnet)
        let chainId: Int = chainInfo.chainId
        adapter.switchEthereumChain(publicAddress: publicAddress, chainId: chainId).subscribe { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultLabel.text = flag
                ParticleConnect.setChain(chainInfo: chainInfo)
            }
            
        }.disposed(by: bag)
    }
    
    @IBAction func addEthereumChain() {
        // test add polygon testnet
        let publicAddress = getSender()
        
        let chainInfo = ParticleNetwork.ChainInfo.bsc(.mainnet)
        let chainId: Int = chainInfo.chainId
        
        adapter.addEthereumChain(publicAddress: publicAddress, chainId: chainId, chainName: nil, nativeCurrency: nil, rpcUrl: nil, blockExplorerUrl: nil).subscribe { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultLabel.text = flag
                ParticleConnect.setChain(chainInfo: chainInfo)
            }
            
        }.disposed(by: bag)
    }
    
    @IBAction func customRequest() {
        testEthChainId()
//        testEthGetBalance()
//        testEthCall()
    }
    
    func testEthChainId() {
        let publicAddress = getSender()
        let method = "eth_chainId"
        let parameters: [Encodable] = []
        adapter.request(publicAddress: publicAddress, method: method, parameters: parameters).subscribe { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultLabel.text = json?.rawString()
            }
            
        }.disposed(by: bag)
    }
    
    func testEthCall() {
        let publicAddress = getSender()
        let method = "eth_call"
        let contractAddress = "0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1"
        ParticleWalletAPI.getEvmService().abiEncodeFunctionCall(contractAddress: contractAddress, methodName: "balanceOf", params: [publicAddress]).flatMap { json -> Single<SwiftyJSON.JSON?> in
            let data = json.stringValue
            let call = CallParams(from: publicAddress, to: contractAddress, value: nil, data: data, gas: nil, gasPrice: nil)
            return self.adapter.request(publicAddress: publicAddress, method: method, parameters: [call, "latest"])
        }.subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultLabel.text = json?.rawString()
            }
        }.disposed(by: bag)
    }
    
    func testEthGetBalance() {
        let publicAddress = getSender()
        let method = "eth_getBalance"
        self.adapter.request(publicAddress: publicAddress, method: method, parameters: [publicAddress, "latest"]).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultLabel.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultLabel.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultLabel.text = json?.rawString()
            }
        }.disposed(by: bag)
    }
}

extension ActionViewController {
    private func isSolana() -> Bool {
        if (connectWalletModel.walletType == .particle && ConnectManager.getChainType() == .solana) || connectWalletModel.walletType == .solanaPrivateKey || connectWalletModel.walletType == .phantom {
            return true
        } else {
            return false
        }
    }
    
    private func getSender() -> String {
        // since Particle Auth support both solana and evm, get address from Particle Auth is right.
        if connectWalletModel.walletType == .particle {
            return ParticleAuthService.getAddress()
        } else {
            return connectWalletModel.publicAddress
        }
    }
    
    private func getReceiver() -> String {
        var receiver = ""
        if isSolana() {
            receiver = "BBBsMq9cEgRf9jeuXqd6QFueyRDhNwykYz63s1vwSCBZ"
        } else {
            receiver = "0x2d2164e5d004c804c47fb39c97e67fd447a49c0d"
        }
       
        return receiver
    }
    
    private func getTransaction() -> Single<String> {
        if isSolana() {
            return getRecentBlockHash().map { [weak self] blockhash in
                guard let self = self else { return "" }
                let instruction = SystemProgram.transferInstruction(from: try! PublicKey(string: self.getSender()), to: try! PublicKey(string: self.getReceiver()), lamports: 100000)
                
                var solanaTransaction = SolanaTransaction(instructions: [instruction], recentBlockhash: blockhash, feePayer: try! PublicKey(string: self.getSender()))
                let transtion = Base58.encode(try! solanaTransaction.serialize(requiredAllSignatures: false, verifySignatures: false))
                return transtion
            }
        } else {
            let chainId = ConnectManager.getChainId().toHexString()
            let txData = TxData(gasPrice: "0x2AB6AC5F2", gasLimit: "0x5208", from: getSender(), to: getReceiver(), value: "0xE8D4A51000", data: "0x", chainId: chainId)
            let transaction = try! txData.serialize()
            return .just(transaction)
        }
    }
    
    private func getMessage() -> String {
        if isSolana() {
            return Base58.encode("hello world".data(using: .utf8)!)
        } else {
            return "hello world"
        }
    }
    
    private func getTypedData() -> String {
        let typedData = """
        {
            "types": {
                "EIP712Domain": [
                    {
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "name": "version",
                        "type": "string"
                    },
                    {
                        "name": "chainId",
                        "type": "uint256"
                    },
                    {
                        "name": "verifyingContract",
                        "type": "address"
                    }
                ],
                "Person": [
                    {
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "name": "wallet",
                        "type": "address"
                    }
                ],
                "Mail": [
                    {
                        "name": "from",
                        "type": "Person"
                    },
                    {
                        "name": "to",
                        "type": "Person"
                    },
                    {
                        "name": "contents",
                        "type": "string"
                    }
                ]
            },
            "primaryType": "Mail",
            "domain": {
                "name": "Ether Mail",
                "version": "1",
                "chainId": 42,
                "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
            },
            "message": {
                "from": {
                    "name": "Cow",
                    "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
                },
                "to": {
                    "name": "Bob",
                    "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
                },
                "contents": "Hello, Bob!"
            }
        }
        """
        
        return typedData
    }
    
    private func getSiweMessage() throws -> SiweMessage {
        // Example siwe message
        // You should update these values for your application.
        
        let message1 = try SiweMessage(
            domain: "login.xyz",
            address: "\(getSender())",
            uri: URL(string: "https://login.xyz/demo#login")!
        )
        
        return message1
    }
}

extension ActionViewController {
    func getRecentBlockHash() -> Single<String> {
        let request: Single<ConnectCommon.Response<RecentBlockHash>> = api.request(path: "", method: "getRecentBlockhash")
        return request.map {
            $0.result!.value.blockhash
        }
    }
}
