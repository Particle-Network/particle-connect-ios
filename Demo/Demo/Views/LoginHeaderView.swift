//
//  LoginHeaderView.swift
//  Demo
//
//  Created by link on 2022/8/15.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LoginHeaderView: UITableViewHeaderFooterView {
    private let line1 = UIView()
    private let line2 = UIView()
    private let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        config()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config() {
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(titleLabel)
        
        line1.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        line2.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        titleLabel.text = "or".localized()
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        
        line1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().inset(20)
            make.right.equalTo(titleLabel.snp.left).offset(-15)
        }
        
        line2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.right.equalToSuperview().inset(20)
            make.left.equalTo(titleLabel.snp.right).offset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.centerX.equalToSuperview()
        }
    }
}
