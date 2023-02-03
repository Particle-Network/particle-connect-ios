//
//  ActionViewController.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import ConnectCommon
import ConnectEVMAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import Foundation
import ParticleAuthService
import ParticleConnect
import ParticleNetworkBase
import ParticleWalletAPI
import RxSwift
import SwiftyJSON
import UIKit

class ActionViewController: UIViewController {
    let bag = DisposeBag()
    
    var api: APIService!
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var resultTextView: UITextView!
    
    var adapter: ConnectAdapter!
    var connectWalletModel: ConnectWalletModel!
    var siweMessage: SiweMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ParticleNetwork.getDevEnv() == .debug {
            api = APIService(rpcUrl: "https://rpc-debug.particle.network/solana/")
        } else {
            api = APIService(rpcUrl: RpcUrl.solana)
        }
        
        sourceTextView.layer.cornerRadius = 10
        sourceTextView.layer.masksToBounds = true
        sourceTextView.layer.borderWidth = 1
        sourceTextView.layer.borderColor = UIColor.lightGray.cgColor
        sourceTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        resultTextView.layer.cornerRadius = 10
        resultTextView.layer.masksToBounds = true
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        addressLabel.text = "Address:" + " " + getSender()
        
        (adapter as? WalletConnectAdapter)?.reconnectIfNeeded(publicAddress: getSender())
        
       
    }
    
    @IBAction func signAndSendTransactionNative() {
        getTransactionNative().flatMap { [weak self] transaction in
            guard let self = self else { return .just("") }
            self.sourceTextView.text = transaction
            return self.adapter.signAndSendTransaction(publicAddress: self.getSender(), transaction: transaction)
        }.subscribe { [weak self] (signature: String) in
            guard let self = self else { return }
            print(signature)
            self.resultTextView.text = signature
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else if let responseError = error as? ParticleNetwork.ResponseError {
                self.resultTextView.text = "code = \(String(describing: responseError.code)), message = \(String(describing: responseError.message))"
            } else {
                self.resultTextView.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signAndSendTransactionToken() {
        getTransactionToken().flatMap { [weak self] transaction in
            guard let self = self else { return .just("") }
            self.sourceTextView.text = transaction
            return self.adapter.signAndSendTransaction(publicAddress: self.getSender(), transaction: transaction)
        }.subscribe { [weak self] (signature: String) in
            guard let self = self else { return }
            print(signature)
            self.resultTextView.text = signature
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else if let responseError = error as? ParticleNetwork.ResponseError {
                self.resultTextView.text = "code = \(String(describing: responseError.code)), message = \(String(describing: responseError.message))"
            } else {
                self.resultTextView.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTransaction() {
        getTransactionNative().flatMap { [weak self] transaction in
            guard let self = self else { return .just("") }
            self.sourceTextView.text = transaction
            return self.adapter.signTransaction(publicAddress: self.getSender(), transaction: transaction)
        }.subscribe { [weak self] (signature: String) in
            guard let self = self else { return }
            
            self.resultTextView.text = signature
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else if let responseError = error as? ParticleNetwork.ResponseError {
                self.resultTextView.text = "code = \(String(describing: responseError.code)), message = \(String(describing: responseError.message))"
            } else {
                self.resultTextView.text = error.localizedDescription
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signAllTransactions() {
        Single.zip(getTransactionNative(), getTransactionToken()).flatMap { [weak self] transaction1, transaciton2 in
            guard let self = self else { return .just([]) }
            self.sourceTextView.text = transaction1 + "\n" + transaciton2
            return self.adapter.signAllTransactions(publicAddress: self.getSender(), transactions: [transaction1, transaciton2])
        }.subscribe { [weak self] (signatures: [String]) in
            guard let self = self else { return }
            print(signatures)
            self.resultTextView.text = signatures.joined(separator: ",")
        } onFailure: { error in
            print(error)
            if let connectError = error as? ConnectError {
                self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
            } else if let responseError = error as? ParticleNetwork.ResponseError {
                self.resultTextView.text = "code = \(String(describing: responseError.code)), message = \(String(describing: responseError.message))"
            } else {
                self.resultTextView.text = error.localizedDescription
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
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                print(Base58.encode(Data(base64Encoded: signedMessage)!))
                self.resultTextView.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTypedData() {
        let typedData = getTypedDataV4()
        sourceTextView.text = typedData
        adapter.signTypeData(publicAddress: getSender(), data: typedData).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                self.resultTextView.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTypedDataV1() {
        let typedData = getTypedDataV1()
        sourceTextView.text = typedData
        if (adapter is ParticleConnectAdapter) == false {
            resultTextView.text = "Not support SignTypedDataV1"
            return
        }
            
        guard let data = typedData.data(using: .utf8) else { return }
        let hexString = "0x" + data.toHexString()
        let message = hexString
        
        ParticleAuthService.signTypedData(message, version: .v1).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                self.resultTextView.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func signTypedDataV3() {
        let typedData = getTypedDataV3()
        sourceTextView.text = typedData
        if (adapter is ParticleConnectAdapter) == false {
            resultTextView.text = "Not support SignTypedDataV3"
            return
        }
            
        guard let data = typedData.data(using: .utf8) else { return }
        let hexString = "0x" + data.toHexString()
        let message = hexString
        
        ParticleAuthService.signTypedData(message, version: .v3).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let signedMessage):
                print(signedMessage)
                self.resultTextView.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func loginSignInWithEthereum() {
        let message = try! getSiweMessage()
        siweMessage = message
        sourceTextView.text = siweMessage?.description
        adapter.login(config: message, publicAddress: getSender()).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let (sourceMessage, signedMessage)):
                print("sourceMessage = \(sourceMessage), \n\nsignedMessage = \(signedMessage)")
                self.resultTextView.text = signedMessage
            }
        }.disposed(by: bag)
    }
    
    @IBAction func verify() {
        guard let message = siweMessage?.description else {
            return
        }
        
        let siwe = try! SiweMessage(message)
        
        var against = resultTextView.text ?? ""
        
        if isSolana() {
            against = Base58.encode(Data(base64Encoded: against)!)
        }
        adapter.verify(message: siwe, against: against).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultTextView.text = flag ? "True" : "False"
            }
        }.disposed(by: bag)
    }
    
    @IBAction func switchEthereumChain() {
        let publicAddress = getSender()
        let chainInfo = ParticleNetwork.getChainInfo()
        let chainId: Int = chainInfo.chainId
        adapter.switchEthereumChain(publicAddress: publicAddress, chainId: chainId).subscribe { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultTextView.text = flag
                ParticleNetwork.setChainInfo(chainInfo)
            }
            
        }.disposed(by: bag)
    }
    
    @IBAction func addEthereumChain() {
        // test add polygon testnet
        let publicAddress = getSender()

        let chainInfo = ParticleNetwork.getChainInfo()
        let chainId: Int = chainInfo.chainId

        adapter.addEthereumChain(publicAddress: publicAddress, chainId: chainId, chainName: nil, nativeCurrency: nil, rpcUrl: nil, blockExplorerUrl: nil).subscribe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let flag):
                print(flag)
                self.resultTextView.text = flag
                ParticleNetwork.setChainInfo(chainInfo)
            }

        }.disposed(by: bag)
    }
    
    @IBAction func customRequest() {
//        deployContract2()
        deployContractAndSendByPrivateKey()
//        testEthChainId()
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
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultTextView.text = json?.rawString()
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
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultTextView.text = json?.rawString()
            }
        }.disposed(by: bag)
    }
    
    func testEthGetBalance() {
        let publicAddress = getSender()
        let method = "eth_getBalance"
        adapter.request(publicAddress: publicAddress, method: method, parameters: [publicAddress, "latest"]).subscribe { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                if let connectError = error as? ConnectError {
                    self.resultTextView.text = "code = \(String(describing: connectError.code)), message = \(String(describing: connectError.message))"
                } else {
                    self.resultTextView.text = error.localizedDescription
                }
            case .success(let json):
                print(json)
                self.resultTextView.text = json?.rawString()
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
    
    private func getTransactionNative() -> Single<String> {
        if isSolana() {
            return getRecentBlockHash().map { [weak self] blockhash in
                guard let self = self else { return "" }
                let instruction = SystemProgram.transferInstruction(from: try! PublicKey(string: self.getSender()), to: try! PublicKey(string: self.getReceiver()), lamports: 100000)

                var solanaTransaction = SolanaTransaction(instructions: [instruction], recentBlockhash: blockhash, feePayer: try! PublicKey(string: self.getSender()))
                let transtion = Base58.encode(try! solanaTransaction.serialize(requiredAllSignatures: false, verifySignatures: false))
                return transtion
            }
        } else {
            return ParticleWalletAPI.getEvmService().createTransaction(from: getSender(), to: "0x16380a03f21e5a5e339c15ba8ebe581d194e0db3", value: BInt(123456).toHexString(), data: "0x")
        }
    }
    
    private func getTransactionToken() -> Single<String> {
        if isSolana() {
            return ParticleWalletAPI.getSolanaService().serializeTransaction(type: .transferToken, sender: getSender(), receiver: "9LR6zGAFB3UJcLg9tWBQJxEJCbZh2UTnSU14RBxsK1ZN", lamports: BInt(1000000000), mintAddress: "GobzzzFQsFAHPvmwT42rLockfUCeV3iutEkK218BxT8K", payer: nil).map {
                return $0.stringValue
            }
        } else {
            if ParticleNetwork.getChainInfo().chain == .tron {
                // send erc20 token
                // This is JST, can get from https://nileex.io/join/getJoinPage
                let params = ContractParams.erc20Transfer(contractAddress: "0x37349aeb75a32f8c4c090daff376cf975f5d2eba", to: "0x0cF3Ffe33E45ad43fcd0aa7016C590b5F629d9AA", amount: 1000000000000000000)
                return ParticleWalletAPI.getEvmService().writeContract(contractParams: params, from: getSender())
            } else {
                // send erc20 token
                // This is token is ChainLink, can get from https://faucets.chain.link/
                let params = ContractParams.erc20Transfer(contractAddress: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB", to: "0x0cF3Ffe33E45ad43fcd0aa7016C590b5F629d9AA", amount: 1000000000000000000)
                return ParticleWalletAPI.getEvmService().writeContract(contractParams: params, from: getSender())
            }
        }
    }
    
    private func getMessage() -> String {
        if isSolana() {
            return "6cTRSLmW2Tbw55uUsJo63DLYtNsNaJSsd2aRQpAFBDL5b84dYBJcNquDuNj9jDcVjofMRuSdXRW6gFjgXtbAGpYfLDBee3NQb641PL3i9bKAsAYSbPh4nbuLXUTHtpfU4V6jzZKAhy3LCVsm56tY83kPe1eb7unub9vyvoYXGKfqcYagccPgDsG7WjfRv1C6HJYeA4oj3hZqhYy48cJmA4FFkm9dWcamYuDDSbynQz9omvZFNRssWoZYQR8A5Q6HxsQxmHSX62qVaMoDJ6XBVnJVjw9MmtgxhGDG2KUd4YL6KuQv9BqLaoSMajbQT7LKSHacSj3wHqW8Ft5Sf8QC6t7wEWyVcFYio9UKzJ3KCVPwGpt1KDRVVMcCPFsWV2ANubaQy46zhKXwr2bQWhb2gHWPs6WojFNAF8ExB7bTc6mxHpEseVopZrCZEHejA6HvRivMDKwzRyoTvBm2ko"
//            return Base58.encode("hello world".data(using: .utf8)!)
        } else {
            return "hello world " + String(Date().timeIntervalSince1970)
        }
    }
    
    private func getTypedDataV4() -> String {
        let typedData = """
        {"types":{"OrderComponents":[{"name":"offerer","type":"address"},{"name":"zone","type":"address"},{"name":"offer","type":"OfferItem[]"},{"name":"consideration","type":"ConsiderationItem[]"},{"name":"orderType","type":"uint8"},{"name":"startTime","type":"uint256"},{"name":"endTime","type":"uint256"},{"name":"zoneHash","type":"bytes32"},{"name":"salt","type":"uint256"},{"name":"conduitKey","type":"bytes32"},{"name":"counter","type":"uint256"}],"OfferItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"}],"ConsiderationItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"},{"name":"recipient","type":"address"}],"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}]},"domain":{"name":"Seaport","version":"1.1","chainId":\(getChainId()),"verifyingContract":"0x00000000006c3852cbef3e08e8df289169ede581"},"primaryType":"OrderComponents","message":{"offerer":"0x6fc702d32e6cb268f7dc68766e6b0fe94520499d","zone":"0x0000000000000000000000000000000000000000","offer":[{"itemType":"2","token":"0xd15b1210187f313ab692013a2544cb8b394e2291","identifierOrCriteria":"33","startAmount":"1","endAmount":"1"}],"consideration":[{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"9750000000000000","endAmount":"9750000000000000","recipient":"0x6fc702d32e6cb268f7dc68766e6b0fe94520499d"},{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"250000000000000","endAmount":"250000000000000","recipient":"0x66682e752d592cbb2f5a1b49dd1c700c9d6bfb32"}],"orderType":"0","startTime":"1669188008","endTime":"115792089237316195423570985008687907853269984665640564039457584007913129639935","zoneHash":"0x3000000000000000000000000000000000000000000000000000000000000000","salt":"48774942683212973027050485287938321229825134327779899253702941089107382707469","conduitKey":"0x0000000000000000000000000000000000000000000000000000000000000000","counter":"0"}}
        """
        
        return typedData
    }
    
    private func getTypedDataV3() -> String {
        let typedData = """
        {\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Person\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"wallet\",\"type\":\"address\"}],\"Mail\":[{\"name\":\"from\",\"type\":\"Person\"},{\"name\":\"to\",\"type\":\"Person\"},{\"name\":\"contents\",\"type\":\"string\"}]},\"primaryType\":\"Mail\",\"domain\":{\"name\":\"Ether Mail\",\"version\":\"1\",\"chainId\":\(getChainId()),\"verifyingContract\":\"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC\"},\"message\":{\"from\":{\"name\":\"Cow\",\"wallet\":\"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826\"},\"to\":{\"name\":\"Bob\",\"wallet\":\"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB\"},\"contents\":\"Hello, Bob!\"}}
        """
        
        return typedData
    }
    
    private func getTypedDataV1() -> String {
        let typedData = """
        [{\"type\":\"string\",\"name\":\"Message\",\"value\":\"Hi, Alice!\"},{\"type\":\"uint32\",\"name\":\"A nunmber\",\"value\":\"1337\"}]
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
    
    private func getChainId() -> Int {
        return ConnectManager.getChainId()
    }
    
    private func isConnected() {
        let publicAddress = getSender()
        let result = adapter.isConnected(publicAddress: publicAddress)
        if result {
            print("publicAddress \(publicAddress) is connected")
        } else {
            print("publicAddress \(publicAddress) is disconnected")
        }
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

extension ActionViewController {
    func getContractData2() -> String {
        return """
        0x611b39600755600a805460ff1916905560e0604052603660808181529062001ee260a03980516200003a9161271b9160209091019062000134565b503480156200004857600080fd5b50604051806040016040528060098152602001682a32b9ba2a37b0b23d60b91b815250604051806040016040528060098152602001682a22a9aa2a27a0a22d60b91b8152508160009080519060200190620000a592919062000134565b508051620000bb90600190602084019062000134565b505050620000d8620000d2620000de60201b60201c565b620000e2565b62000217565b3390565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b8280546200014290620001da565b90600052602060002090601f016020900481019282620001665760008555620001b1565b82601f106200018157805160ff1916838001178555620001b1565b82800160010185558215620001b1579182015b82811115620001b157825182559160200191906001019062000194565b50620001bf929150620001c3565b5090565b5b80821115620001bf5760008155600101620001c4565b600181811c90821680620001ef57607f821691505b602082108114156200021157634e487b7160e01b600052602260045260246000fd5b50919050565b611cbb80620002276000396000f3fe608060405234801561001057600080fd5b50600436106101735760003560e01c8063715018a6116100de578063a22cb46511610097578063dc30158b11610071578063dc30158b14610320578063e831574214610328578063e985e9c514610331578063f2fde38b1461036d57600080fd5b8063a22cb465146102e7578063b88d4fde146102fa578063c87b56dd1461030d57600080fd5b8063715018a614610286578063787faa7f1461028e5780638da5cb5b146102ae57806395d89b41146102bf5780639a7c8e69146102c7578063a0712d68146102d457600080fd5b806323b872dd1161013057806323b872dd14610210578063413ac78d1461022357806342842e0e1461023a57806355f804b31461024d5780636352211e1461026057806370a082311461027357600080fd5b806301ffc9a71461017857806306fd5133146101a057806306fdde03146101aa578063081812fc146101bf578063095ea7b3146101ea5780631f65d743146101fd575b600080fd5b61018b6101863660046118ae565b610380565b60405190151581526020015b60405180910390f35b6101a86103d2565b005b6101b2610414565b6040516101979190611a0b565b6101d26101cd36600461195a565b6104a6565b6040516001600160a01b039091168152602001610197565b6101a86101f83660046117d7565b61053b565b6101a861020b366004611801565b610651565b6101a861021e36600461169f565b610716565b61022c60075481565b604051908152602001610197565b6101a861024836600461169f565b610747565b6101a861025b3660046118e8565b610762565b6101d261026e36600461195a565b610799565b61022c61028136600461164a565b610810565b6101a8610897565b61022c61029c36600461164a565b60086020526000908152604090205481565b6006546001600160a01b03166101d2565b6101b26108cd565b600a5461018b9060ff1681565b6101a86102e236600461195a565b6108dc565b6101a86102f536600461179b565b610b35565b6101a86103083660046116db565b610bfa565b6101b261031b36600461195a565b610c32565b61022c600381565b61022c611b3981565b61018b61033f36600461166c565b6001600160a01b03918216600090815260056020908152604080832093909416825291909152205460ff1690565b6101a861037b36600461164a565b610c89565b60006001600160e01b031982166380ac58cd60e01b14806103b157506001600160e01b03198216635b5e139f60e01b145b806103cc57506301ffc9a760e01b6001600160e01b03198316145b92915050565b6006546001600160a01b031633146104055760405162461bcd60e51b81526004016103fc90611a70565b60405180910390fd5b600a805460ff19166001179055565b60606000805461042390611bad565b80601f016020809104026020016040519081016040528092919081815260200182805461044f90611bad565b801561049c5780601f106104715761010080835404028352916020019161049c565b820191906000526020600020905b81548152906001019060200180831161047f57829003601f168201915b5050505050905090565b6000818152600260205260408120546001600160a01b031661051f5760405162461bcd60e51b815260206004820152602c60248201527f4552433732313a20617070726f76656420717565727920666f72206e6f6e657860448201526b34b9ba32b73a103a37b5b2b760a11b60648201526084016103fc565b506000908152600460205260409020546001600160a01b031690565b600061054682610799565b9050806001600160a01b0316836001600160a01b031614156105b45760405162461bcd60e51b815260206004820152602160248201527f4552433732313a20617070726f76616c20746f2063757272656e74206f776e656044820152603960f91b60648201526084016103fc565b336001600160a01b03821614806105d057506105d0813361033f565b6106425760405162461bcd60e51b815260206004820152603860248201527f4552433732313a20617070726f76652063616c6c6572206973206e6f74206f7760448201527f6e6572206e6f7220617070726f76656420666f7220616c6c000000000000000060648201526084016103fc565b61064c8383610d24565b505050565b6006546001600160a01b0316331461067b5760405162461bcd60e51b81526004016103fc90611a70565b600a5460ff16156106ce5760405162461bcd60e51b815260206004820152601b60248201527f446576204d696e74205065726d616e656e746c79204c6f636b6564000000000060448201526064016103fc565b805160005b8181101561064c5760008382815181106106ef576106ef611c43565b602002602001015190506107033382610d92565b508061070e81611be8565b9150506106d3565b6107203382610db0565b61073c5760405162461bcd60e51b81526004016103fc90611aa5565b61064c838383610ea7565b61064c83838360405180602001604052806000815250610bfa565b6006546001600160a01b0316331461078c5760405162461bcd60e51b81526004016103fc90611a70565b61064c61271b8383611595565b6000818152600260205260408120546001600160a01b0316806103cc5760405162461bcd60e51b815260206004820152602960248201527f4552433732313a206f776e657220717565727920666f72206e6f6e657869737460448201526832b73a103a37b5b2b760b91b60648201526084016103fc565b60006001600160a01b03821661087b5760405162461bcd60e51b815260206004820152602a60248201527f4552433732313a2062616c616e636520717565727920666f7220746865207a65604482015269726f206164647265737360b01b60648201526084016103fc565b506001600160a01b031660009081526003602052604090205490565b6006546001600160a01b031633146108c15760405162461bcd60e51b81526004016103fc90611a70565b6108cb6000611047565b565b60606001805461042390611bad565b600754634fb30ac942101561093f5760405162461bcd60e51b8152602060048201526024808201527f53616c652073746172747320617420776861746576657220746869732074696d6044820152636520697360e01b60648201526084016103fc565b60038211156109a85760405162461bcd60e51b815260206004820152602f60248201527f54686572652069732061206c696d6974206f6e206d696e74696e6720746f6f2060448201526e6d616e7920617420612074696d652160881b60648201526084016103fc565b60006109b48383611b53565b1015610a115760405162461bcd60e51b815260206004820152602660248201527f4d696e74696e672074686973206d616e7920776f756c642065786365656420736044820152657570706c792160d01b60648201526084016103fc565b33600090815260086020526040902054601490610a2f908490611b27565b1115610a7d5760405162461bcd60e51b815260206004820152601c60248201527f43616e2774206f776e206d6f7265207468616e20323020746f61647a0000000060448201526064016103fc565b333214610abc5760405162461bcd60e51b815260206004820152600d60248201526c4e6f20636f6e7472616374732160981b60448201526064016103fc565b60005b82811015610b00576000610ad38483611099565b9050610adf3382610d92565b82610ae981611b96565b935050508080610af890611be8565b915050610abf565b50600781905533600090815260086020526040902054610b21908390611b27565b336000908152600860205260409020555050565b6001600160a01b038216331415610b8e5760405162461bcd60e51b815260206004820152601960248201527f4552433732313a20617070726f766520746f2063616c6c65720000000000000060448201526064016103fc565b3360008181526005602090815260408083206001600160a01b03871680855290835292819020805460ff191686151590811790915590519081529192917f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31910160405180910390a35050565b610c043383610db0565b610c205760405162461bcd60e51b81526004016103fc90611aa5565b610c2c848484846111d2565b50505050565b60606000610c3e611205565b90506000610c4b84611215565b9050815160001415610c5e579392505050565b8181604051602001610c7192919061199f565b60405160208183030381529060405292505050919050565b6006546001600160a01b03163314610cb35760405162461bcd60e51b81526004016103fc90611a70565b6001600160a01b038116610d185760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b60648201526084016103fc565b610d2181611047565b50565b600081815260046020526040902080546001600160a01b0319166001600160a01b0384169081179091558190610d5982610799565b6001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a45050565b610dac828260405180602001604052806000815250611313565b5050565b6000818152600260205260408120546001600160a01b0316610e295760405162461bcd60e51b815260206004820152602c60248201527f4552433732313a206f70657261746f7220717565727920666f72206e6f6e657860448201526b34b9ba32b73a103a37b5b2b760a11b60648201526084016103fc565b6000610e3483610799565b9050806001600160a01b0316846001600160a01b03161480610e6f5750836001600160a01b0316610e64846104a6565b6001600160a01b0316145b80610e9f57506001600160a01b0380821660009081526005602090815260408083209388168352929052205460ff165b949350505050565b826001600160a01b0316610eba82610799565b6001600160a01b031614610f225760405162461bcd60e51b815260206004820152602960248201527f4552433732313a207472616e73666572206f6620746f6b656e2074686174206960448201526839903737ba1037bbb760b91b60648201526084016103fc565b6001600160a01b038216610f845760405162461bcd60e51b8152602060048201526024808201527f4552433732313a207472616e7366657220746f20746865207a65726f206164646044820152637265737360e01b60648201526084016103fc565b610f8f600082610d24565b6001600160a01b0383166000908152600360205260408120805460019290610fb8908490611b53565b90915550506001600160a01b0382166000908152600360205260408120805460019290610fe6908490611b27565b909155505060008181526002602052604080822080546001600160a01b0319166001600160a01b0386811691821790925591518493918716917fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef91a4505050565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b600080333a43426110ab600183611b53565b604080516001600160a01b039096166020870152850193909352606084019190915260808301524060a082015260c0810185905260e08101849052610100016040516020818303038152906040528051906020012060001c90506000600754826111159190611c03565b90506000600b82612710811061112d5761112d611c43565b0154905060008161113f575081611142565b50805b600060016007546111539190611b53565b90508084146111b1576000600b82612710811061117257611172611c43565b01549050806111975781600b86612710811061119057611190611c43565b01556111af565b80600b8661271081106111ac576111ac611c43565b01555b505b600780549060006111c183611b96565b909155509198975050505050505050565b6111dd848484610ea7565b6111e984848484611346565b610c2c5760405162461bcd60e51b81526004016103fc90611a1e565b606061271b805461042390611bad565b6060816112395750506040805180820190915260018152600360fc1b602082015290565b8160005b8115611263578061124d81611be8565b915061125c9050600a83611b3f565b915061123d565b60008167ffffffffffffffff81111561127e5761127e611c59565b6040519080825280601f01601f1916602001820160405280156112a8576020820181803683370190505b5090505b8415610e9f576112bd600183611b53565b91506112ca600a86611c03565b6112d5906030611b27565b60f81b8183815181106112ea576112ea611c43565b60200101906001600160f81b031916908160001a90535061130c600a86611b3f565b94506112ac565b61131d8383611453565b61132a6000848484611346565b61064c5760405162461bcd60e51b81526004016103fc90611a1e565b60006001600160a01b0384163b1561144857604051630a85bd0160e11b81526001600160a01b0385169063150b7a029061138a9033908990889088906004016119ce565b602060405180830381600087803b1580156113a457600080fd5b505af19250505080156113d4575060408051601f3d908101601f191682019092526113d1918101906118cb565b60015b61142e573d808015611402576040519150601f19603f3d011682016040523d82523d6000602084013e611407565b606091505b5080516114265760405162461bcd60e51b81526004016103fc90611a1e565b805181602001fd5b6001600160e01b031916630a85bd0160e11b149050610e9f565b506001949350505050565b6001600160a01b0382166114a95760405162461bcd60e51b815260206004820181905260248201527f4552433732313a206d696e7420746f20746865207a65726f206164647265737360448201526064016103fc565b6000818152600260205260409020546001600160a01b03161561150e5760405162461bcd60e51b815260206004820152601c60248201527f4552433732313a20746f6b656e20616c7265616479206d696e7465640000000060448201526064016103fc565b6001600160a01b0382166000908152600360205260408120805460019290611537908490611b27565b909155505060008181526002602052604080822080546001600160a01b0319166001600160a01b03861690811790915590518392907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef908290a45050565b8280546115a190611bad565b90600052602060002090601f0160209004810192826115c35760008555611609565b82601f106115dc5782800160ff19823516178555611609565b82800160010185558215611609579182015b828111156116095782358255916020019190600101906115ee565b50611615929150611619565b5090565b5b80821115611615576000815560010161161a565b80356001600160a01b038116811461164557600080fd5b919050565b60006020828403121561165c57600080fd5b6116658261162e565b9392505050565b6000806040838503121561167f57600080fd5b6116888361162e565b91506116966020840161162e565b90509250929050565b6000806000606084860312156116b457600080fd5b6116bd8461162e565b92506116cb6020850161162e565b9150604084013590509250925092565b600080600080608085870312156116f157600080fd5b6116fa8561162e565b9350602061170981870161162e565b935060408601359250606086013567ffffffffffffffff8082111561172d57600080fd5b818801915088601f83011261174157600080fd5b81358181111561175357611753611c59565b611765601f8201601f19168501611af6565b9150808252898482850101111561177b57600080fd5b808484018584013760008482840101525080935050505092959194509250565b600080604083850312156117ae57600080fd5b6117b78361162e565b9150602083013580151581146117cc57600080fd5b809150509250929050565b600080604083850312156117ea57600080fd5b6117f38361162e565b946020939093013593505050565b6000602080838503121561181457600080fd5b823567ffffffffffffffff8082111561182c57600080fd5b818501915085601f83011261184057600080fd5b81358181111561185257611852611c59565b8060051b9150611863848301611af6565b8181528481019084860184860187018a101561187e57600080fd5b600095505b838610156118a1578035835260019590950194918601918601611883565b5098975050505050505050565b6000602082840312156118c057600080fd5b813561166581611c6f565b6000602082840312156118dd57600080fd5b815161166581611c6f565b600080602083850312156118fb57600080fd5b823567ffffffffffffffff8082111561191357600080fd5b818501915085601f83011261192757600080fd5b81358181111561193657600080fd5b86602082850101111561194857600080fd5b60209290920196919550909350505050565b60006020828403121561196c57600080fd5b5035919050565b6000815180845261198b816020860160208601611b6a565b601f01601f19169290920160200192915050565b600083516119b1818460208801611b6a565b8351908301906119c5818360208801611b6a565b01949350505050565b6001600160a01b0385811682528416602082015260408101839052608060608201819052600090611a0190830184611973565b9695505050505050565b6020815260006116656020830184611973565b60208082526032908201527f4552433732313a207472616e7366657220746f206e6f6e20455243373231526560408201527131b2b4bb32b91034b6b83632b6b2b73a32b960711b606082015260800190565b6020808252818101527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572604082015260600190565b60208082526031908201527f4552433732313a207472616e736665722063616c6c6572206973206e6f74206f6040820152701ddb995c881b9bdc88185c1c1c9bdd9959607a1b606082015260800190565b604051601f8201601f1916810167ffffffffffffffff81118282101715611b1f57611b1f611c59565b604052919050565b60008219821115611b3a57611b3a611c17565b500190565b600082611b4e57611b4e611c2d565b500490565b600082821015611b6557611b65611c17565b500390565b60005b83811015611b85578181015183820152602001611b6d565b83811115610c2c5750506000910152565b600081611ba557611ba5611c17565b506000190190565b600181811c90821680611bc157607f821691505b60208210811415611be257634e487b7160e01b600052602260045260246000fd5b50919050565b6000600019821415611bfc57611bfc611c17565b5060010190565b600082611c1257611c12611c2d565b500690565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052601260045260246000fd5b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052604160045260246000fd5b6001600160e01b031981168114610d2157600080fdfea2646970667358221220da60eee0405e6d98799b38ea7964b7e5da6b9f7ab284075832bacdecbd4bcbb764736f6c63430008070033697066733a2f2f516d574546534d6b753679474c51395451723636486a5364396b6179385a44594b624245666a4e6934704c7472722f
        """
    }

    func getContractData() -> String {
//        return """
//        0x60606040523415600e57600080fd5b603580601b6000396000f3006060604052600080fd00a165627a7a723058204bf1accefb2526a5077bcdfeaeb8020162814272245a9741cc2fddd89191af1c0029
//        """
        
        return """
        0x6101406040523480156200001257600080fd5b506040518060400160405280601981526020017f44616f696e67436f6d6d756e697479436f6c6c656374696f6e000000000000008152506040518060400160405280600181526020017f31000000000000000000000000000000000000000000000000000000000000008152506040518060400160405280601981526020017f44616f696e67436f6d6d756e697479436f6c6c656374696f6e000000000000008152506040518060400160405280600381526020017f444343000000000000000000000000000000000000000000000000000000000081525081600090805190602001906200010392919062000304565b5080600190805190602001906200011c92919062000304565b5050506200013f62000133620001fa60201b60201c565b6200020260201b60201c565b60008280519060200120905060008280519060200120905060007f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f90508260e081815250508161010081815250504660a08181525050620001a8818484620002c860201b60201c565b608081815250503073ffffffffffffffffffffffffffffffffffffffff1660c08173ffffffffffffffffffffffffffffffffffffffff1660601b815250508061012081815250505050505050620004f1565b600033905090565b6000600760009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905081600760006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b60008383834630604051602001620002e5959493929190620003e7565b6040516020818303038152906040528051906020012090509392505050565b82805462000312906200048c565b90600052602060002090601f01602090048101928262000336576000855562000382565b82601f106200035157805160ff191683800117855562000382565b8280016001018555821562000382579182015b828111156200038157825182559160200191906001019062000364565b5b50905062000391919062000395565b5090565b5b80821115620003b057600081600090555060010162000396565b5090565b620003bf8162000444565b82525050565b620003d08162000458565b82525050565b620003e18162000482565b82525050565b600060a082019050620003fe6000830188620003c5565b6200040d6020830187620003c5565b6200041c6040830186620003c5565b6200042b6060830185620003d6565b6200043a6080830184620003b4565b9695505050505050565b6000620004518262000462565b9050919050565b6000819050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b60006002820490506001821680620004a557607f821691505b60208210811415620004bc57620004bb620004c2565b5b50919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b60805160a05160c05160601c60e0516101005161012051615351620005446000396000611ab601526000611af801526000611ad701526000611a0c01526000611a6201526000611a8b01526153516000f3fe6080604052600436106101c25760003560e01c80636352211e116100f75780639ab24eb011610095578063c3cda52011610064578063c3cda52014610665578063c87b56dd1461068e578063e985e9c5146106cb578063f2fde38b14610708576101c2565b80639ab24eb0146105ad578063a22cb465146105ea578063af30954214610613578063b88d4fde1461063c576101c2565b80637ecebe00116100d15780637ecebe00146104dd5780638da5cb5b1461051a5780638e539e8c1461054557806395d89b4114610582576101c2565b80636352211e1461044c57806370a0823114610489578063715018a6146104c6576101c2565b806340d097c3116101645780634a9e8ac71161013e5780634a9e8ac7146103a1578063587cde1e146103bd5780635c19a95c146103fa5780635d5a92fb14610423576101c2565b806340d097c31461032657806342842e0e1461034f57806342966c6814610378576101c2565b8063095ea7b3116101a0578063095ea7b31461026c57806323b872dd146102955780633644e515146102be5780633a46b1a8146102e9576101c2565b806301ffc9a7146101c757806306fdde0314610204578063081812fc1461022f575b600080fd5b3480156101d357600080fd5b506101ee60048036038101906101e99190613c49565b610731565b6040516101fb9190614349565b60405180910390f35b34801561021057600080fd5b50610219610813565b604051610226919061445c565b60405180910390f35b34801561023b57600080fd5b5061025660048036038101906102519190613c9b565b6108a5565b60405161026391906142b9565b60405180910390f35b34801561027857600080fd5b50610293600480360381019061028e9190613b5b565b6108eb565b005b3480156102a157600080fd5b506102bc60048036038101906102b79190613a55565b610a03565b005b3480156102ca57600080fd5b506102d3610a63565b6040516102e09190614364565b60405180910390f35b3480156102f557600080fd5b50610310600480360381019061030b9190613b5b565b610a72565b60405161031d919061479e565b60405180910390f35b34801561033257600080fd5b5061034d600480360381019061034891906139f0565b610acd565b005b34801561035b57600080fd5b5061037660048036038101906103719190613a55565b610b38565b005b34801561038457600080fd5b5061039f600480360381019061039a9190613c9b565b610b58565b005b6103bb60048036038101906103b69190613b5b565b610bb4565b005b3480156103c957600080fd5b506103e460048036038101906103df91906139f0565b610d31565b6040516103f191906142b9565b60405180910390f35b34801561040657600080fd5b50610421600480360381019061041c91906139f0565b610d9a565b005b34801561042f57600080fd5b5061044a600480360381019061044591906139f0565b610db4565b005b34801561045857600080fd5b50610473600480360381019061046e9190613c9b565b610f6b565b60405161048091906142b9565b60405180910390f35b34801561049557600080fd5b506104b060048036038101906104ab91906139f0565b61101d565b6040516104bd919061479e565b60405180910390f35b3480156104d257600080fd5b506104db6110d5565b005b3480156104e957600080fd5b5061050460048036038101906104ff91906139f0565b6110e9565b604051610511919061479e565b60405180910390f35b34801561052657600080fd5b5061052f611139565b60405161053c91906142b9565b60405180910390f35b34801561055157600080fd5b5061056c60048036038101906105679190613c9b565b611163565b604051610579919061479e565b60405180910390f35b34801561058e57600080fd5b506105976111c2565b6040516105a4919061445c565b60405180910390f35b3480156105b957600080fd5b506105d460048036038101906105cf91906139f0565b611254565b6040516105e1919061479e565b60405180910390f35b3480156105f657600080fd5b50610611600480360381019061060c9190613b1f565b6112a4565b005b34801561061f57600080fd5b5061063a600480360381019061063591906139f0565b6112ba565b005b34801561064857600080fd5b50610663600480360381019061065e9190613aa4565b611306565b005b34801561067157600080fd5b5061068c60048036038101906106879190613b97565b611368565b005b34801561069a57600080fd5b506106b560048036038101906106b09190613c9b565b61146c565b6040516106c2919061445c565b60405180910390f35b3480156106d757600080fd5b506106f260048036038101906106ed9190613a19565b61147e565b6040516106ff9190614349565b60405180910390f35b34801561071457600080fd5b5061072f600480360381019061072a91906139f0565b611512565b005b60007f80ac58cd000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff191614806107fc57507f5b5e139f000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916145b8061080c575061080b82611596565b5b9050919050565b60606000805461082290614a72565b80601f016020809104026020016040519081016040528092919081815260200182805461084e90614a72565b801561089b5780601f106108705761010080835404028352916020019161089b565b820191906000526020600020905b81548152906001019060200180831161087e57829003601f168201915b5050505050905090565b60006108b082611600565b6004600083815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b60006108f682610f6b565b90508073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415610967576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161095e9061471e565b60405180910390fd5b8073ffffffffffffffffffffffffffffffffffffffff1661098661164b565b73ffffffffffffffffffffffffffffffffffffffff1614806109b557506109b4816109af61164b565b61147e565b5b6109f4576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016109eb9061467e565b60405180910390fd5b6109fe8383611653565b505050565b610a14610a0e61164b565b8261170c565b610a53576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610a4a9061477e565b60405180910390fd5b610a5e8383836117a1565b505050565b6000610a6d611a08565b905090565b6000610ac582600960008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020611b2290919063ffffffff16565b905092915050565b610ad5611cc6565b6000610ae1600c611d44565b9050610aed600c611d52565b610af78282611d68565b610b3481610b03611d86565b600e610b0e85611da6565b604051602001610b2093929190614246565b604051602081830303815290604052611f53565b5050565b610b5383838360405180602001604052806000815250611306565b505050565b610b69610b6361164b565b8261170c565b610ba8576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610b9f9061477e565b60405180910390fd5b610bb181611fc7565b50565b600f5481610bc0611fd3565b610bca9190614890565b1115610c0b576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610c029061473e565b60405180910390fd5b60005b81811015610c89576000610c22600c611d44565b9050610c2e600c611d52565b610c388482611d68565b610c7581610c44611d86565b600e610c4f85611da6565b604051602001610c6193929190614246565b604051602081830303815290604052611f53565b508080610c8190614ad5565b915050610c0e565b50610cd6601160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16670de0b6b3a764000060105434610cc79190614917565b610cd191906148e6565b611fe4565b610d2d601260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16670de0b6b3a764000060105434610d139190614917565b610d1d91906148e6565b34610d289190614971565b611fe4565b5050565b6000600860008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b6000610da461164b565b9050610db0818361202f565b5050565b610dbc611cc6565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415610e4457610df961164b565b73ffffffffffffffffffffffffffffffffffffffff166108fc479081150290604051600060405180830381858888f19350505050158015610e3e573d6000803e3d6000fd5b50610f68565b60008190508073ffffffffffffffffffffffffffffffffffffffff1663a9059cbb610e6d61164b565b8373ffffffffffffffffffffffffffffffffffffffff166370a08231306040518263ffffffff1660e01b8152600401610ea691906142b9565b60206040518083038186803b158015610ebe57600080fd5b505afa158015610ed2573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610ef69190613cc4565b6040518363ffffffff1660e01b8152600401610f13929190614320565b602060405180830381600087803b158015610f2d57600080fd5b505af1158015610f41573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610f659190613c20565b50505b50565b6000806002600084815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415611014576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161100b906146fe565b60405180910390fd5b80915050919050565b60008073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16141561108e576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401611085906145de565b60405180910390fd5b600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050919050565b6110dd611cc6565b6110e76000612143565b565b6000611132600b60008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020611d44565b9050919050565b6000600760009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b60004382106111a7576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161119e9061463e565b60405180910390fd5b6111bb82600a611b2290919063ffffffff16565b9050919050565b6060600180546111d190614a72565b80601f01602080910402602001604051908101604052809291908181526020018280546111fd90614a72565b801561124a5780601f1061121f5761010080835404028352916020019161124a565b820191906000526020600020905b81548152906001019060200180831161122d57829003601f168201915b5050505050905090565b600061129d600960008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020612209565b9050919050565b6112b66112af61164b565b83836122ca565b5050565b6112c2611cc6565b80601260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b61131761131161164b565b8361170c565b611356576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161134d9061477e565b60405180910390fd5b61136284848484612437565b50505050565b834211156113ab576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016113a2906145fe565b60405180910390fd5b600061140d6114057fe48329057bfd03d55e49b547132e39cffd9c1820ad7b9d4c5307691425d15adf8989896040516020016113ea949392919061437f565b60405160208183030381529060405280519060200120612493565b8585856124ad565b9050611418816124d8565b8614611459576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016114509061449e565b60405180910390fd5b611463818861202f565b50505050505050565b606061147782612536565b9050919050565b6000600560008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16905092915050565b61151a611cc6565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561158a576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401611581906144fe565b60405180910390fd5b61159381612143565b50565b60007f01ffc9a7000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916149050919050565b61160981612649565b611648576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161163f906146fe565b60405180910390fd5b50565b600033905090565b816004600083815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550808273ffffffffffffffffffffffffffffffffffffffff166116c683610f6b565b73ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a45050565b60008061171883610f6b565b90508073ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff16148061175a5750611759818561147e565b5b8061179857508373ffffffffffffffffffffffffffffffffffffffff16611780846108a5565b73ffffffffffffffffffffffffffffffffffffffff16145b91505092915050565b8273ffffffffffffffffffffffffffffffffffffffff166117c182610f6b565b73ffffffffffffffffffffffffffffffffffffffff1614611817576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161180e9061451e565b60405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff161415611887576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161187e9061455e565b60405180910390fd5b6118928383836126b5565b61189d600082611653565b6001600360008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546118ed9190614971565b925050819055506001600360008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546119449190614890565b92505081905550816002600083815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550808273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4611a038383836126ba565b505050565b60007f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff163073ffffffffffffffffffffffffffffffffffffffff16148015611a8457507f000000000000000000000000000000000000000000000000000000000000000046145b15611ab1577f00000000000000000000000000000000000000000000000000000000000000009050611b1f565b611b1c7f00000000000000000000000000000000000000000000000000000000000000007f00000000000000000000000000000000000000000000000000000000000000007f00000000000000000000000000000000000000000000000000000000000000006126ca565b90505b90565b6000438210611b66576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401611b5d906145be565b60405180910390fd5b60008360000180549050905060005b81811015611c10576000611b898284612704565b905084866000018281548110611bc8577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b9060005260206000200160000160009054906101000a900463ffffffff1663ffffffff161115611bfa57809250611c0a565b600181611c079190614890565b91505b50611b75565b60008214611c9b5784600001600183611c299190614971565b81548110611c60577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b9060005260206000200160000160049054906101000a90047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16611c9e565b60005b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff169250505092915050565b611cce61164b565b73ffffffffffffffffffffffffffffffffffffffff16611cec611139565b73ffffffffffffffffffffffffffffffffffffffff1614611d42576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401611d39906146be565b60405180910390fd5b565b600081600001549050919050565b6001816000016000828254019250508190555050565b611d8282826040518060200160405280600081525061272a565b5050565b60606040518060600160405280602a81526020016152f2602a9139905090565b60606000821415611dee576040518060400160405280600181526020017f30000000000000000000000000000000000000000000000000000000000000008152509050611f4e565b600082905060005b60008214611e20578080611e0990614ad5565b915050600a82611e1991906148e6565b9150611df6565b60008167ffffffffffffffff811115611e62577f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6040519080825280601f01601f191660200182016040528015611e945781602001600182028036833780820191505090505b5090505b60008514611f4757600182611ead9190614971565b9150600a85611ebc9190614b28565b6030611ec89190614890565b60f81b818381518110611f04577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a905350600a85611f4091906148e6565b9450611e98565b8093505050505b919050565b611f5c82612649565b611f9b576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401611f929061461e565b60405180910390fd5b80600660008481526020019081526020016000209080519060200190611fc29291906137e8565b505050565b611fd081612785565b50565b6000611fdf600a612209565b905090565b8173ffffffffffffffffffffffffffffffffffffffff166108fc829081150290604051600060405180830381858888f1935050505015801561202a573d6000803e3d6000fd5b505050565b600061203a83610d31565b905081600860008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167f3134e8a2e6d97e929a7e54011ea5485d7d196dd5f0ba4d4ef95803e8e3fc257f60405160405180910390a461213e8183612139866127d8565b6127ea565b505050565b6000600760009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905081600760006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b60008082600001805490509050600081146122a1578260000160018261222f9190614971565b81548110612266577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b9060005260206000200160000160049054906101000a90047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff166122a4565b60005b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16915050919050565b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415612339576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016123309061457e565b60405180910390fd5b80600560008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055508173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c318360405161242a9190614349565b60405180910390a3505050565b6124428484846117a1565b61244e848484846129f7565b61248d576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612484906144de565b60405180910390fd5b50505050565b60006124a66124a0611a08565b83612b8e565b9050919050565b60008060006124be87878787612bc1565b915091506124cb81612cce565b8192505050949350505050565b600080600b60008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020905061252581611d44565b915061253081611d52565b50919050565b606061254182611600565b600060066000848152602001908152602001600020805461256190614a72565b80601f016020809104026020016040519081016040528092919081815260200182805461258d90614a72565b80156125da5780601f106125af576101008083540402835291602001916125da565b820191906000526020600020905b8154815290600101906020018083116125bd57829003601f168201915b5050505050905060006125eb611d86565b9050600081511415612601578192505050612644565b60008251111561263657808260405160200161261e929190614222565b60405160208183030381529060405292505050612644565b61263f8461301f565b925050505b919050565b60008073ffffffffffffffffffffffffffffffffffffffff166002600084815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614159050919050565b505050565b6126c5838383613087565b505050565b600083838346306040516020016126e59594939291906143c4565b6040516020818303038152906040528051906020012090509392505050565b6000600282841861271591906148e6565b8284166127229190614890565b905092915050565b61273483836130a3565b61274160008484846129f7565b612780576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612777906144de565b60405180910390fd5b505050565b61278e8161327d565b60006006600083815260200190815260200160002080546127ae90614a72565b9050146127d5576006600082815260200190815260200160002060006127d4919061386e565b5b50565b60006127e38261101d565b9050919050565b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16141580156128265750600081115b156129f257600073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161461290e576000806128b761339a84600960008973ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206133b09092919063ffffffff16565b915091508473ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a72483836040516129039291906147b9565b60405180910390a250505b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16146129f15760008061299a6133de84600960008873ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206133b09092919063ffffffff16565b915091508373ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a72483836040516129e69291906147b9565b60405180910390a250505b5b505050565b6000612a188473ffffffffffffffffffffffffffffffffffffffff166133f4565b15612b81578373ffffffffffffffffffffffffffffffffffffffff1663150b7a02612a4161164b565b8786866040518563ffffffff1660e01b8152600401612a6394939291906142d4565b602060405180830381600087803b158015612a7d57600080fd5b505af1925050508015612aae57506040513d601f19601f82011682018060405250810190612aab9190613c72565b60015b612b31573d8060008114612ade576040519150601f19603f3d011682016040523d82523d6000602084013e612ae3565b606091505b50600081511415612b29576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612b20906144de565b60405180910390fd5b805181602001fd5b63150b7a0260e01b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916817bffffffffffffffffffffffffffffffffffffffffffffffffffffffff191614915050612b86565b600190505b949350505050565b60008282604051602001612ba3929190614282565b60405160208183030381529060405280519060200120905092915050565b6000807f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a08360001c1115612bfc576000600391509150612cc5565b601b8560ff1614158015612c145750601c8560ff1614155b15612c26576000600491509150612cc5565b600060018787878760405160008152602001604052604051612c4b9493929190614417565b6020604051602081039080840390855afa158015612c6d573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415612cbc57600060019250925050612cc5565b80600092509250505b94509492505050565b60006004811115612d08577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b816004811115612d41577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b1415612d4c5761301c565b60016004811115612d86577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b816004811115612dbf577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b1415612e00576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612df79061447e565b60405180910390fd5b60026004811115612e3a577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b816004811115612e73577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b1415612eb4576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612eab906144be565b60405180910390fd5b60036004811115612eee577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b816004811115612f27577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b1415612f68576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401612f5f9061459e565b60405180910390fd5b600480811115612fa1577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b816004811115612fda577f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b141561301b576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016130129061465e565b60405180910390fd5b5b50565b606061302a82611600565b6000613034611d86565b90506000815111613054576040518060200160405280600081525061307f565b8061305e84611da6565b60405160200161306f929190614222565b6040516020818303038152906040525b915050919050565b61309383836001613417565b61309e8383836134d7565b505050565b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff161415613113576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161310a9061469e565b60405180910390fd5b61311c81612649565b1561315c576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016131539061453e565b60405180910390fd5b613168600083836126b5565b6001600360008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546131b89190614890565b92505081905550816002600083815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550808273ffffffffffffffffffffffffffffffffffffffff16600073ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4613279600083836126ba565b5050565b600061328882610f6b565b9050613296816000846126b5565b6132a1600083611653565b6001600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546132f19190614971565b925050819055506002600083815260200190815260200160002060006101000a81549073ffffffffffffffffffffffffffffffffffffffff021916905581600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4613396816000846126ba565b5050565b600081836133a89190614971565b905092915050565b6000806133d2856133cd6133c388612209565b868863ffffffff16565b6134dc565b91509150935093915050565b600081836133ec9190614890565b905092915050565b6000808273ffffffffffffffffffffffffffffffffffffffff163b119050919050565b600073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415613467576134646133de82600a6133b09092919063ffffffff16565b50505b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614156134b7576134b461339a82600a6133b09092919063ffffffff16565b50505b6134d26134c384610d31565b6134cc84610d31565b836127ea565b505050565b505050565b60008060008460000180549050905060006134f686612209565b9050600082118015613572575043866000016001846135159190614971565b8154811061354c577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b9060005260206000200160000160009054906101000a900463ffffffff1663ffffffff16145b15613628576135808561372a565b866000016001846135919190614971565b815481106135c8577f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b9060005260206000200160000160046101000a8154817bffffffffffffffffffffffffffffffffffffffffffffffffffffffff02191690837bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555061371b565b85600001604051806040016040528061364043613795565b63ffffffff1681526020016136548861372a565b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff168152509080600181540180825580915050600190039060005260206000200160009091909190915060008201518160000160006101000a81548163ffffffff021916908363ffffffff16021790555060208201518160000160046101000a8154817bffffffffffffffffffffffffffffffffffffffffffffffffffffffff02191690837bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505b80859350935050509250929050565b60007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff801682111561378d576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401613784906146de565b60405180910390fd5b819050919050565b600063ffffffff80168211156137e0576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016137d79061475e565b60405180910390fd5b819050919050565b8280546137f490614a72565b90600052602060002090601f016020900481019282613816576000855561385d565b82601f1061382f57805160ff191683800117855561385d565b8280016001018555821561385d579182015b8281111561385c578251825591602001919060010190613841565b5b50905061386a91906138ae565b5090565b50805461387a90614a72565b6000825580601f1061388c57506138ab565b601f0160209004906000526020600020908101906138aa91906138ae565b5b50565b5b808211156138c75760008160009055506001016138af565b5090565b60006138de6138d984614807565b6147e2565b9050828152602081018484840111156138f657600080fd5b613901848285614a30565b509392505050565b60008135905061391881615267565b92915050565b60008135905061392d8161527e565b92915050565b6000815190506139428161527e565b92915050565b60008135905061395781615295565b92915050565b60008135905061396c816152ac565b92915050565b600081519050613981816152ac565b92915050565b600082601f83011261399857600080fd5b81356139a88482602086016138cb565b91505092915050565b6000813590506139c0816152c3565b92915050565b6000815190506139d5816152c3565b92915050565b6000813590506139ea816152da565b92915050565b600060208284031215613a0257600080fd5b6000613a1084828501613909565b91505092915050565b60008060408385031215613a2c57600080fd5b6000613a3a85828601613909565b9250506020613a4b85828601613909565b9150509250929050565b600080600060608486031215613a6a57600080fd5b6000613a7886828701613909565b9350506020613a8986828701613909565b9250506040613a9a868287016139b1565b9150509250925092565b60008060008060808587031215613aba57600080fd5b6000613ac887828801613909565b9450506020613ad987828801613909565b9350506040613aea878288016139b1565b925050606085013567ffffffffffffffff811115613b0757600080fd5b613b1387828801613987565b91505092959194509250565b60008060408385031215613b3257600080fd5b6000613b4085828601613909565b9250506020613b518582860161391e565b9150509250929050565b60008060408385031215613b6e57600080fd5b6000613b7c85828601613909565b9250506020613b8d858286016139b1565b9150509250929050565b60008060008060008060c08789031215613bb057600080fd5b6000613bbe89828a01613909565b9650506020613bcf89828a016139b1565b9550506040613be089828a016139b1565b9450506060613bf189828a016139db565b9350506080613c0289828a01613948565b92505060a0613c1389828a01613948565b9150509295509295509295565b600060208284031215613c3257600080fd5b6000613c4084828501613933565b91505092915050565b600060208284031215613c5b57600080fd5b6000613c698482850161395d565b91505092915050565b600060208284031215613c8457600080fd5b6000613c9284828501613972565b91505092915050565b600060208284031215613cad57600080fd5b6000613cbb848285016139b1565b91505092915050565b600060208284031215613cd657600080fd5b6000613ce4848285016139c6565b91505092915050565b613cf6816149a5565b82525050565b613d05816149b7565b82525050565b613d14816149c3565b82525050565b613d2b613d26826149c3565b614b1e565b82525050565b6000613d3c8261484d565b613d468185614863565b9350613d56818560208601614a3f565b613d5f81614c15565b840191505092915050565b6000613d7582614858565b613d7f8185614874565b9350613d8f818560208601614a3f565b613d9881614c15565b840191505092915050565b6000613dae82614858565b613db88185614885565b9350613dc8818560208601614a3f565b80840191505092915050565b60008154613de181614a72565b613deb8186614885565b94506001821660008114613e065760018114613e1757613e4a565b60ff19831686528186019350613e4a565b613e2085614838565b60005b83811015613e4257815481890152600182019150602081019050613e23565b838801955050505b50505092915050565b6000613e60601883614874565b9150613e6b82614c26565b602082019050919050565b6000613e83601483614874565b9150613e8e82614c4f565b602082019050919050565b6000613ea6601f83614874565b9150613eb182614c78565b602082019050919050565b6000613ec9603283614874565b9150613ed482614ca1565b604082019050919050565b6000613eec602683614874565b9150613ef782614cf0565b604082019050919050565b6000613f0f602583614874565b9150613f1a82614d3f565b604082019050919050565b6000613f32601c83614874565b9150613f3d82614d8e565b602082019050919050565b6000613f55600283614885565b9150613f6082614db7565b600282019050919050565b6000613f78602483614874565b9150613f8382614de0565b604082019050919050565b6000613f9b601983614874565b9150613fa682614e2f565b602082019050919050565b6000613fbe602283614874565b9150613fc982614e58565b604082019050919050565b6000613fe1602083614874565b9150613fec82614ea7565b602082019050919050565b6000614004602983614874565b915061400f82614ed0565b604082019050919050565b6000614027601883614874565b915061403282614f1f565b602082019050919050565b600061404a602e83614874565b915061405582614f48565b604082019050919050565b600061406d601a83614874565b915061407882614f97565b602082019050919050565b6000614090602283614874565b915061409b82614fc0565b604082019050919050565b60006140b3603e83614874565b91506140be8261500f565b604082019050919050565b60006140d6602083614874565b91506140e18261505e565b602082019050919050565b60006140f9602083614874565b915061410482615087565b602082019050919050565b600061411c602783614874565b9150614127826150b0565b604082019050919050565b600061413f601883614874565b915061414a826150ff565b602082019050919050565b6000614162602183614874565b915061416d82615128565b604082019050919050565b6000614185601b83614874565b915061419082615177565b602082019050919050565b60006141a8602683614874565b91506141b3826151a0565b604082019050919050565b60006141cb602e83614874565b91506141d6826151ef565b604082019050919050565b60006141ee600183614885565b91506141f98261523e565b600182019050919050565b61420d81614a19565b82525050565b61421c81614a23565b82525050565b600061422e8285613da3565b915061423a8284613da3565b91508190509392505050565b60006142528286613da3565b915061425e8285613dd4565b9150614269826141e1565b91506142758284613da3565b9150819050949350505050565b600061428d82613f48565b91506142998285613d1a565b6020820191506142a98284613d1a565b6020820191508190509392505050565b60006020820190506142ce6000830184613ced565b92915050565b60006080820190506142e96000830187613ced565b6142f66020830186613ced565b6143036040830185614204565b81810360608301526143158184613d31565b905095945050505050565b60006040820190506143356000830185613ced565b6143426020830184614204565b9392505050565b600060208201905061435e6000830184613cfc565b92915050565b60006020820190506143796000830184613d0b565b92915050565b60006080820190506143946000830187613d0b565b6143a16020830186613ced565b6143ae6040830185614204565b6143bb6060830184614204565b95945050505050565b600060a0820190506143d96000830188613d0b565b6143e66020830187613d0b565b6143f36040830186613d0b565b6144006060830185614204565b61440d6080830184613ced565b9695505050505050565b600060808201905061442c6000830187613d0b565b6144396020830186614213565b6144466040830185613d0b565b6144536060830184613d0b565b95945050505050565b600060208201905081810360008301526144768184613d6a565b905092915050565b6000602082019050818103600083015261449781613e53565b9050919050565b600060208201905081810360008301526144b781613e76565b9050919050565b600060208201905081810360008301526144d781613e99565b9050919050565b600060208201905081810360008301526144f781613ebc565b9050919050565b6000602082019050818103600083015261451781613edf565b9050919050565b6000602082019050818103600083015261453781613f02565b9050919050565b6000602082019050818103600083015261455781613f25565b9050919050565b6000602082019050818103600083015261457781613f6b565b9050919050565b6000602082019050818103600083015261459781613f8e565b9050919050565b600060208201905081810360008301526145b781613fb1565b9050919050565b600060208201905081810360008301526145d781613fd4565b9050919050565b600060208201905081810360008301526145f781613ff7565b9050919050565b600060208201905081810360008301526146178161401a565b9050919050565b600060208201905081810360008301526146378161403d565b9050919050565b6000602082019050818103600083015261465781614060565b9050919050565b6000602082019050818103600083015261467781614083565b9050919050565b60006020820190508181036000830152614697816140a6565b9050919050565b600060208201905081810360008301526146b7816140c9565b9050919050565b600060208201905081810360008301526146d7816140ec565b9050919050565b600060208201905081810360008301526146f78161410f565b9050919050565b6000602082019050818103600083015261471781614132565b9050919050565b6000602082019050818103600083015261473781614155565b9050919050565b6000602082019050818103600083015261475781614178565b9050919050565b600060208201905081810360008301526147778161419b565b9050919050565b60006020820190508181036000830152614797816141be565b9050919050565b60006020820190506147b36000830184614204565b92915050565b60006040820190506147ce6000830185614204565b6147db6020830184614204565b9392505050565b60006147ec6147fd565b90506147f88282614aa4565b919050565b6000604051905090565b600067ffffffffffffffff82111561482257614821614be6565b5b61482b82614c15565b9050602081019050919050565b60008190508160005260206000209050919050565b600081519050919050565b600081519050919050565b600082825260208201905092915050565b600082825260208201905092915050565b600081905092915050565b600061489b82614a19565b91506148a683614a19565b9250827fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff038211156148db576148da614b59565b5b828201905092915050565b60006148f182614a19565b91506148fc83614a19565b92508261490c5761490b614b88565b5b828204905092915050565b600061492282614a19565b915061492d83614a19565b9250817fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff048311821515161561496657614965614b59565b5b828202905092915050565b600061497c82614a19565b915061498783614a19565b92508282101561499a57614999614b59565b5b828203905092915050565b60006149b0826149f9565b9050919050565b60008115159050919050565b6000819050919050565b60007fffffffff0000000000000000000000000000000000000000000000000000000082169050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b600060ff82169050919050565b82818337600083830152505050565b60005b83811015614a5d578082015181840152602081019050614a42565b83811115614a6c576000848401525b50505050565b60006002820490506001821680614a8a57607f821691505b60208210811415614a9e57614a9d614bb7565b5b50919050565b614aad82614c15565b810181811067ffffffffffffffff82111715614acc57614acb614be6565b5b80604052505050565b6000614ae082614a19565b91507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff821415614b1357614b12614b59565b5b600182019050919050565b6000819050919050565b6000614b3382614a19565b9150614b3e83614a19565b925082614b4e57614b4d614b88565b5b828206905092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6000601f19601f8301169050919050565b7f45434453413a20696e76616c6964207369676e61747572650000000000000000600082015250565b7f566f7465733a20696e76616c6964206e6f6e6365000000000000000000000000600082015250565b7f45434453413a20696e76616c6964207369676e6174757265206c656e67746800600082015250565b7f4552433732313a207472616e7366657220746f206e6f6e20455243373231526560008201527f63656976657220696d706c656d656e7465720000000000000000000000000000602082015250565b7f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160008201527f6464726573730000000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a207472616e736665722066726f6d20696e636f72726563742060008201527f6f776e6572000000000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a20746f6b656e20616c7265616479206d696e74656400000000600082015250565b7f1901000000000000000000000000000000000000000000000000000000000000600082015250565b7f4552433732313a207472616e7366657220746f20746865207a65726f2061646460008201527f7265737300000000000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a20617070726f766520746f2063616c6c657200000000000000600082015250565b7f45434453413a20696e76616c6964207369676e6174757265202773272076616c60008201527f7565000000000000000000000000000000000000000000000000000000000000602082015250565b7f436865636b706f696e74733a20626c6f636b206e6f7420796574206d696e6564600082015250565b7f4552433732313a2061646472657373207a65726f206973206e6f74206120766160008201527f6c6964206f776e65720000000000000000000000000000000000000000000000602082015250565b7f566f7465733a207369676e617475726520657870697265640000000000000000600082015250565b7f45524337323155524953746f726167653a2055524920736574206f66206e6f6e60008201527f6578697374656e7420746f6b656e000000000000000000000000000000000000602082015250565b7f566f7465733a20626c6f636b206e6f7420796574206d696e6564000000000000600082015250565b7f45434453413a20696e76616c6964207369676e6174757265202776272076616c60008201527f7565000000000000000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a20617070726f76652063616c6c6572206973206e6f7420746f60008201527f6b656e206f776e6572206e6f7220617070726f76656420666f7220616c6c0000602082015250565b7f4552433732313a206d696e7420746f20746865207a65726f2061646472657373600082015250565b7f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572600082015250565b7f53616665436173743a2076616c756520646f65736e27742066697420696e203260008201527f3234206269747300000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a20696e76616c696420746f6b656e2049440000000000000000600082015250565b7f4552433732313a20617070726f76616c20746f2063757272656e74206f776e6560008201527f7200000000000000000000000000000000000000000000000000000000000000602082015250565b7f4e6f206176616c61626c6520616d6f756e7420746f206d696e74210000000000600082015250565b7f53616665436173743a2076616c756520646f65736e27742066697420696e203360008201527f3220626974730000000000000000000000000000000000000000000000000000602082015250565b7f4552433732313a2063616c6c6572206973206e6f7420746f6b656e206f776e6560008201527f72206e6f7220617070726f766564000000000000000000000000000000000000602082015250565b7f2f00000000000000000000000000000000000000000000000000000000000000600082015250565b615270816149a5565b811461527b57600080fd5b50565b615287816149b7565b811461529257600080fd5b50565b61529e816149c3565b81146152a957600080fd5b50565b6152b5816149cd565b81146152c057600080fd5b50565b6152cc81614a19565b81146152d757600080fd5b50565b6152e381614a23565b81146152ee57600080fd5b5056fe687474703a2f2f6170692e64616f696e672e6170702f636f6d6d756e697479636f6c6c656374696f6e2fa2646970667358221220ddec3e3b0576274337327ff2b9e5a55130437b8b85b987c0055ea68a6a10f6f064736f6c63430008040033
        """
    }
    
    func deployContractAndSendByPrivateKey() {
        let data = getContractData2()
        let from = "0x2648cfE97e33345300Db8154670347b08643570b"
        let to: String? = nil
        ParticleWalletAPI.getEvmService().createTransaction(from: from, to: to, data: data, type: "0x2").flatMap {
            transaction -> Single<String> in
            print("transaction = \(transaction)")
            
            return self.adapter.signAndSendTransaction(publicAddress: from, transaction: transaction)
        }.subscribe { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let signature):
                print(signature)
            }
        }.disposed(by: bag)
    }
    
    func deployContract2() {
        let from = "0x2648cfE97e33345300Db8154670347b08643570b"
        let txData = TxData(gasPrice: "0x77359400", gasLimit: "0x4C4B40", from: from, to: "", value: "0x0", data: getContractData(), chainId: ConnectManager.getChainId().toHexString())
        let transaction = try! txData.serialize()
        print(transaction)
        adapter.signAndSendTransaction(publicAddress: from, transaction: transaction).subscribe { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let signature):
                print(signature)
            }
        }.disposed(by: bag)
    }
}
