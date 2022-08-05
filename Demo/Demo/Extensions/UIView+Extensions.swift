//
//  UIView+Extensions.swift
//  Demo
//
//  Created by link on 2022/8/5.
//  Copyright © 2022 ParticleNetwork. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showToast(title: String, message: String?, completeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let completeHandler = completeHandler {
                completeHandler()
            }
        }))
        present(alert, animated: true)
    }
}

