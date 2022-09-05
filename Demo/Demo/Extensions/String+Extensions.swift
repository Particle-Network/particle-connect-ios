//
//  String+Extensions.swift
//  Demo
//
//  Created by link on 2022/9/5.
//

import Foundation

extension String {
    func localized() -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    func localized(para: String) -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil).replacingOccurrences(of: "%@", with: para)
    }
}
