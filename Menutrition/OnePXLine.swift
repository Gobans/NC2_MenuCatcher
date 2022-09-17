//
//  OnePXLine.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/18.
//

import UIKit

class OnePXLine: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        var rect = self.frame;
        rect.size.height = (1 / UIScreen.main.scale);
        self.frame = rect;
    }
}
