//
//  LoginCell.swift
//  Demo
//
//  Created by link on 2022/8/15.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit

final class LoginCell: UITableViewCell {
    let bgView = UIView()
    
    let iconImageView = UIImageView()
    
    let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        config()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        contentView.addSubview(bgView)
        
        bgView.addSubview(iconImageView)
        bgView.addSubview(nameLabel)
        
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = UIColor.black
        
        bgView.layer.cornerRadius = 22.5
        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        
        bgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(37)
            make.height.equalTo(45)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(17)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setName(_ name: String, image: UIImage?) {
        iconImageView.image = image
        nameLabel.text = name
    }
}
