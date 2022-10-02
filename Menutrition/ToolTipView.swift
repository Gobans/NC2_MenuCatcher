//
//  ToolTipButton.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/02.
//

import UIKit

class ToolTipView: UIView {
    let tooltipBottomPadding: CGFloat = 12
    let tooltipCornerRadius: CGFloat = 6
    let tooltipAlpha: CGFloat = 0.95
    let pointerBaseWidth: CGFloat = 14
    let pointerHeight: CGFloat = 8
    let padding = CGPoint(x: 18, y: 12)
    lazy var labelHeight = message.height(withWidth: .greatestFiniteMagnitude, font: UIFont.systemFont(ofSize: 12)) + padding.y
    lazy var labelWidth = message.width(withHeight: .zero, font: UIFont.systemFont(ofSize: 12)) + padding.x
    
    let message: String
    
    init(frame: CGRect, message: String) {
        self.message = message
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tooltipLabel: UILabel = {
        let tooltipLabel = UILabel()
        tooltipLabel.text = "\(message)"
        tooltipLabel.textAlignment = .center
        tooltipLabel.font = UIFont.systemFont(ofSize: 12)
        tooltipLabel.contentMode = .center
        tooltipLabel.textColor = .white
        tooltipLabel.layer.backgroundColor = UIColor(red: 44 / 255, green: 44 / 255, blue: 44 / 255, alpha: 1).cgColor
        tooltipLabel.layer.cornerRadius = self.tooltipCornerRadius
        return tooltipLabel
    }()
    lazy var pointerPath: UIBezierPath = {
        let pointerPath = UIBezierPath()
        let pointerTip = CGPoint(x: labelWidth / 2, y: labelHeight + pointerHeight)
        let pointerBaseLeft = CGPoint(x: labelWidth / 2 - pointerBaseWidth / 2, y: labelHeight)
        let pointerBaseRight = CGPoint(x: labelWidth / 2 + pointerBaseWidth / 2, y: labelHeight)
        pointerPath.move(to: pointerBaseLeft)
        pointerPath.addLine(to: pointerTip)
        pointerPath.addLine(to: pointerBaseRight)
        pointerPath.close()
        
        let pointer = CAShapeLayer()
        pointer.path = pointerPath.cgPath
        pointer.fillColor = UIColor(red: 44 / 255, green: 44 / 255, blue: 44 / 255, alpha: 1).cgColor
        return pointerPath
    }()
    lazy var pointer: CAShapeLayer = {
        let pointer = CAShapeLayer()
        pointer.path = pointerPath.cgPath
        pointer.fillColor = UIColor(red: 44 / 255, green: 44 / 255, blue: 44 / 255, alpha: 1).cgColor
        return pointer
    }()
    
    func configureUI() {
        self.addSubview(tooltipLabel)
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pointerHeight).isActive = true
        tooltipLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tooltipLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tooltipLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.layer.addSublayer(pointer)
    }
}
