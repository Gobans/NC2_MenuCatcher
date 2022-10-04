//
//  PaddingLabel.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/17.
//

import UIKit
import Foundation

class NutritionPaddingLabel: UILabel {
    var topInset: CGFloat = 4.0
    var bottomInset: CGFloat = 3.0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0
 
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}
