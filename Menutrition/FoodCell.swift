//
//  FoodCollectionViewCell.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/01.
//

import Foundation
import UIKit

class FoodCell: UICollectionViewCell {
    
    static let identifier = "FoodCollectionViewCell"
    
    var food: Food? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    private let foodCategoryImageView: UIImageView = {
        let foodCategoryImageView = UIImageView()
        let categoryImage = UIImage(systemName: "fork.knife")
        foodCategoryImageView.image = categoryImage
        foodCategoryImageView.contentMode = .scaleAspectFit
        return foodCategoryImageView
    }()
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        return nameLabel
    }()
    private let servingLabel = UILabel()
    private lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView(arrangedSubviews: [foodCategoryImageView, nameLabel])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .leading
        titleStackView.distribution = .fillProportionally
        titleStackView.spacing = childPadding
        return titleStackView
    }()
    private lazy var nutritionRootStackView: UIStackView = {
        let nutritionStackView = UIStackView(arrangedSubviews: [nutritionLeftStackView, nutritionRightStackView])
        nutritionStackView.axis = .horizontal
        nutritionStackView.alignment = .leading
        nutritionStackView.distribution = .fillEqually
        return nutritionStackView
    }()
    private lazy var nutritionLeftStackView: UIStackView = {
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [energyLabel, carbohydrateLabel, proteinLabel])
        nutritionLeftStackView.axis = .vertical
        nutritionLeftStackView.spacing = childPadding
        return nutritionLeftStackView
    }()
    private lazy var nutritionRightStackView: UIStackView = {
        let nutritionRightStackView = UIStackView(arrangedSubviews: [fatLabel, sugarLabel, caffeineLabel])
        nutritionRightStackView.axis = .vertical
        nutritionRightStackView.spacing = childPadding
        return nutritionRightStackView
    }()
    private let energyLabel = UILabel()
    private let carbohydrateLabel = UILabel()
    private let proteinLabel = UILabel()
    private let fatLabel = UILabel()
    private let sugarLabel = UILabel()
    private let caffeineLabel = UILabel()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    private lazy var rootStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [labelStack, disclosureIndicator])
        rootStack.alignment = .top
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            titleStackView,
            servingLabel,
            nutritionRootStackView
        ])
        labelStack.axis = .vertical
        labelStack.spacing = labelPadding
        return labelStack
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let rootPadding: CGFloat = 8
    private let labelPadding: CGFloat = 20
    private let childPadding: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    private func setUp() {
        backgroundColor = .systemGray6
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        
        contentView.addSubview(rootStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        setUpConstraints()
        updateAppearance()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: rootPadding),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: rootPadding),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rootPadding),
        ])
        
        closedConstraint =
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -rootPadding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
        nutritionRootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -rootPadding)
        openConstraint?.priority = .defaultLow
    }
    
    private func updateContent() {
        guard let food = food else { return }
        nameLabel.text = food.name
        servingLabel.text = "1회 제공량 : \(food.serving)\(food.unit)"
        energyLabel.text = "열량 | \(food.energy)kcal"
        carbohydrateLabel.text = "탄수화물 | \(food.carbohydrate)g"
        proteinLabel.text = "단백질 | \(food.protein)g"
        fatLabel.text = "지방 | \(food.fat)g"
        sugarLabel.text = "당류 | \(food.sugar)g"
        caffeineLabel.text = "카페인 | \(food.caffeine)mg"
    }
    private func updateAppearance() {
        closedConstraint?.isActive = !isSelected
        openConstraint?.isActive = isSelected
        UIView.animate(withDuration: 0.3) { // 0.3 seconds matches collection view animation
            // Set the rotation just under 180º so that it rotates back the same way
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown :.identity
        }
    }
}
