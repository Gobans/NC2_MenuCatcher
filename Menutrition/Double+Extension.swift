//
//  Double+Extension.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/02.
//

import UIKit

extension Double {
    func getNoDigitString() -> String {
        let str = String(format: "%.0f", self)
        return str
    }
    func getOneDigitString() -> String {
        let str = String(format: "%.1f", self)
        return str
    }
}
