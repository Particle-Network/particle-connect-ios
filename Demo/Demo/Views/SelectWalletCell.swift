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
    let iconImageView = UIImageView()
    
    let nameLabel = UILabel()
    
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
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 20
        iconImageView.contentMode = .scaleAspectFit
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
    }
}

