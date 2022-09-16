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
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .preferredFont(forTextStyle: .callout)
        return subtitleLabel
    }()
    private let spacerView: UIView = {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }()
    private let servingLabel = UILabel()
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
            titleContentStackView,
            spacerView,
            servingLabel,
            nutritionRootStackView
        ])
        labelStack.axis = .vertical
        labelStack.spacing = labelPadding
        return labelStack
    }()
    private lazy var titleContentStackView: UIStackView = {
        let UIStackView = UIStackView(arrangedSubviews: [foodCategoryImageView, titleLabelStackView])
        UIStackView.axis = .horizontal
        UIStackView.distribution = .fill
        UIStackView.alignment = .leading
        UIStackView.spacing = 14
        return UIStackView
    }()
    private lazy var titleLabelStackView: UIStackView = {
        let UIStackView = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        UIStackView.axis = .vertical
        UIStackView.distribution = .fillProportionally
        return UIStackView
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let contentViewPadding: CGFloat = 20
    private let rootPadding: CGFloat = 20
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
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        
        contentView.addSubview(rootStack)
        
        setUpConstraints()
        updateAppearance()
    }
    
    private func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: rootPadding),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: rootPadding),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rootPadding),
        ])
        
        foodCategoryImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodCategoryImageView.heightAnchor.constraint(equalTo: titleLabelStackView.heightAnchor),
            foodCategoryImageView.widthAnchor.constraint(equalTo: titleContentStackView.widthAnchor, multiplier: 0.2)
        ])
        
        closedConstraint =
        titleContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -labelPadding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
        nutritionRootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -labelPadding)
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
        subtitleLabel.text = "식사류"
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
