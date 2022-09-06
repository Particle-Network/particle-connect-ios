//
//  LoginDataModel.swift
//  Demo
//
//  Created by link on 2022/8/15.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit

struct LoginDataModel {
    let imageName: ImageName
    let name: String
}

enum ImageName: String {
    case login_apple
    case login_bitkeep
    case login_discord
    case login_email
    case login_facebook
    case login_github
    case login_google
    case login_imtoken
    case login_linkedin
    case login_metamask
    case login_microsoft
    case login_phantom
    case login_phone
    case login_private_key
    case login_rainbow
    case login_trust
    case login_twitch
    case login_wallet_connect
    case login_gnosis
}
