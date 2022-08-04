//
//  SelectWalletCell.swift
//  Demo
//
//  Created by link on 2022/8/3.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit

class SelectWalletCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        config()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        if let imageView = imageView, let textLabel = textLabel {
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
            ])
            
            textLabel.textAlignment = .left
            
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                textLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20)
            ])
        }
    }
}
