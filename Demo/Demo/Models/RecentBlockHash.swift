//
//  RecentBlockHash.swift
//  Demo
//
//  Created by link on 2022/8/4.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation

struct RecentBlockHash: Codable {
    struct Context: Codable {
        let slot: Int
    }
    
    struct Value: Codable {
        struct FeeCalculator: Codable {
            let lamportsPerSignature: Int
        }
        
        let blockhash: String
        let feeCalculator: FeeCalculator
    }
    
    let context: Context
    let value: Value
}
