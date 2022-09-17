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
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        return nameLabel
    }()
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        return subtitleLabel
    }()
    private let spacerView: UIView = {
        let spacerView = UIView()
        spacerView.backgroundColor = .black
        spacerView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        spacerView.frame = CGRect(x: 0, y: 0, width: 320, height: 1)
        return spacerView
    }()
    private let servingLabel = UILabel()
    private lazy var nutritionRootStackView: UIStackView = {
        let nutritionStackView = UIStackView(arrangedSubviews: [nutritionLeftStackView, nutritionRightStackView])
        nutritionStackView.axis = .horizontal
        nutritionStackView.alignment = .leading
        nutritionStackView.distribution = .fillEqually
        nutritionStackView.spacing = 30
        return nutritionStackView
    }()
    private lazy var nutritionLeftStackView: UIStackView = {
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [nutritionLeftLabelStackView, nutritionLeftNumberStackView])
        nutritionLeftStackView.axis = .horizontal
        nutritionLeftStackView.distribution = .fillProportionally
        nutritionLeftStackView.spacing = 10
        return nutritionLeftStackView
    }()
    private lazy var nutritionRightStackView: UIStackView = {
        let nutritionRightStackView = UIStackView(arrangedSubviews: [nutritionRightLabelStackView, nutritionRightNumberStackView])
        nutritionRightStackView.axis = .horizontal
        nutritionRightStackView.distribution = .fillProportionally
        nutritionRightStackView.spacing = 10
        return nutritionRightStackView
    }()
    private lazy var nutritionLeftLabelStackView: UIStackView = {
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [energyLabel, carbohydrateLabel, proteinLabel])
        nutritionLeftStackView.axis = .vertical
        nutritionLeftStackView.spacing = 10
        return nutritionLeftStackView
    }()
    private lazy var nutritionRightLabelStackView: UIStackView = {
        let nutritionRightStackView = UIStackView(arrangedSubviews: [fatLabel, sugarLabel, caffeineLabel])
        nutritionRightStackView.axis = .vertical
        nutritionRightStackView.spacing = 10
        return nutritionRightStackView
    }()
    private lazy var nutritionLeftNumberStackView: UIStackView = {
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [energyNumberLabel, carbohydrateNumberLabel, proteinNumberLabel])
        nutritionLeftStackView.axis = .vertical
        nutritionLeftStackView.spacing = 10
        return nutritionLeftStackView
    }()
    private lazy var nutritionRightNumberStackView: UIStackView = {
        let nutritionRightStackView = UIStackView(arrangedSubviews: [fatNumberLabel, sugarNumberLabel, caffeineNumberLabel])
        nutritionRightStackView.axis = .vertical
        nutritionRightStackView.spacing = 10
        return nutritionRightStackView
    }()
    private lazy var nutritionLabels: [NutritionPaddingLabel] = [energyLabel, carbohydrateLabel, proteinLabel, fatLabel, sugarLabel, caffeineLabel]
    private lazy var nutritionNumberLabels: [UILabel] = [energyNumberLabel, carbohydrateNumberLabel, proteinNumberLabel, fatNumberLabel, sugarNumberLabel, caffeineNumberLabel]
    private let nutritionLabelText: [String] = ["열량", "탄수화물", "단백질", "지방", "당류", "카페인"]
    private let energyLabel = NutritionPaddingLabel()
    private let carbohydrateLabel = NutritionPaddingLabel()
    private let proteinLabel = NutritionPaddingLabel()
    private let fatLabel = NutritionPaddingLabel()
    private let sugarLabel = NutritionPaddingLabel()
    private let caffeineLabel = NutritionPaddingLabel()
    private let energyNumberLabel = UILabel()
    private let carbohydrateNumberLabel = UILabel()
    private let proteinNumberLabel = UILabel()
    private let fatNumberLabel = UILabel()
    private let sugarNumberLabel = UILabel()
    private let caffeineNumberLabel = UILabel()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    private lazy var rootStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [labelStack])
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
    private let nutritionPadding: CGFloat = 22
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    private func setUp() {
        configureUI()
        setUpConstraints()
        updateAppearance()
    }
    
    private func configureUI() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        servingLabel.font = UIFont(name: "SFPro-Medium", size: 11)
        nutritionLabels.enumerated().forEach{(index, label) in
            label.text = "\(nutritionLabelText[index])"
            label.font = UIFont(name: "SFPro-Medium", size: 11)
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .black
            label.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
        }
        nutritionNumberLabels.enumerated().forEach{(index, label) in
            label.font = UIFont(name: "SFPro-Medium", size: 11)
            label.textAlignment = .center
        }
    }
    
    private func setUpConstraints() {
        contentView.addSubview(rootStack)
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
        
        contentView.addSubview(disclosureIndicator)
        disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            disclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -31),
            disclosureIndicator.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
        ])
        
        energyNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        carbohydrateNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        proteinNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        fatNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        sugarNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        caffeineNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            energyNumberLabel.centerYAnchor.constraint(equalTo: energyLabel.centerYAnchor),
            carbohydrateNumberLabel.centerYAnchor.constraint(equalTo: carbohydrateLabel.centerYAnchor),
            proteinNumberLabel.centerYAnchor.constraint(equalTo: proteinLabel.centerYAnchor),
            fatNumberLabel.centerYAnchor.constraint(equalTo: fatLabel.centerYAnchor),
            sugarNumberLabel.centerYAnchor.constraint(equalTo: sugarLabel.centerYAnchor),
            caffeineNumberLabel.centerYAnchor.constraint(equalTo: caffeineLabel.centerYAnchor),
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
        let attributedStr = NSMutableAttributedString(string: servingLabel.text!)
        attributedStr.addAttribute(.foregroundColor, value: UIColor(hexString: "#CFCFCF"), range: (servingLabel.text! as NSString).range(of: "1회 제공량 :"))
        servingLabel.attributedText = attributedStr
        energyNumberLabel.text = "\(food.energy)kcal"
        carbohydrateNumberLabel.text = "\(food.carbohydrate)g"
        proteinNumberLabel.text = "\(food.protein)g"
        fatNumberLabel.text = "\(food.fat)g"
        sugarNumberLabel.text = "\(food.sugar)g"
        caffeineNumberLabel.text = "\(food.caffeine)mg"
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
