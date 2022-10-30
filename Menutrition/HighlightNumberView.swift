//
//  HighlightNumberLabel.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/16.
//

import Foundation
import UIKit

class HighlightNumberView: UIView {
    let numberLabel = UILabel()
    let highlightUIView = UIView()
    
    init() {
        super.init(frame: .zero)
        configureUI()
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        highlightUIView.backgroundColor = UIColor(hexString: "#FFBFAB")
        highlightUIView.clipsToBounds = true
        highlightUIView.layer.cornerRadius = 1
        highlightUIView.alpha = 0
    }
    
    func createLayout() {
        addSubview(highlightUIView)
        addSubview(numberLabel)
        
        highlightUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highlightUIView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1),
            highlightUIView.centerXAnchor.constraint(equalTo: centerXAnchor),
            highlightUIView.widthAnchor.constraint(equalTo: numberLabel.widthAnchor),
            highlightUIView.heightAnchor.constraint(equalTo: numberLabel.heightAnchor, multiplier: 0.3)
        ])
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            numberLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
