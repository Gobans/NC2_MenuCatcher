//
//  FilterScrollView.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/27.
//

import UIKit

class FilterScrollView: UIScrollView {
    private lazy var categoryStackView: UIStackView = {
        let categoryStackView = UIStackView(arrangedSubviews: nutritionLabels)
        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 6
        categoryStackView.distribution = .fillEqually
        return categoryStackView
    }()
    
    private let energyLabel = CategoryPaddingLabel()
    private let carbohydrateLabel = CategoryPaddingLabel()
    private let proteinLabel = CategoryPaddingLabel()
    private let fatLabel = CategoryPaddingLabel()
    private let sugarLabel = CategoryPaddingLabel()
    private let caffeineLabel = CategoryPaddingLabel()
    private let nutritionLabelText: [String] = ["열량", "탄수화물", "단백질", "지방", "당류", "카페인"]
    private lazy var nutritionLabels: [CategoryPaddingLabel] = [energyLabel, carbohydrateLabel, proteinLabel, fatLabel, sugarLabel, caffeineLabel]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented xib init")
    }

    func configure() {
        showsHorizontalScrollIndicator = false
        bounces = false
        nutritionLabels.enumerated().forEach{(index, label) in
            label.text = "\(nutritionLabelText[index])"
            label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 11)
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .black
            label.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
        }
        addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryStackView.topAnchor.constraint(equalTo: topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
