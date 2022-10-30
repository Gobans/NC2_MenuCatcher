//
//  FilterScrollView.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/27.
//

import UIKit

class FilterScrollView: UIScrollView {
    var highlightDelegate: EnableHighlightCells?
    let insetConfiguration: UIButton.Configuration = {
        var insetConfiguration = UIButton.Configuration.tinted()
        insetConfiguration.contentInsets = .init(top: 4, leading: 16, bottom: 3, trailing: 16)
        return insetConfiguration
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let categoryStackView = UIStackView(arrangedSubviews: nutritionButtons)
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillProportionally
        categoryStackView.spacing = 6
        return categoryStackView
    }()
    
    private lazy var energyButton = UIButton(configuration: insetConfiguration)
    private lazy var carbohydrateButton = UIButton(configuration: insetConfiguration)
    private lazy var proteinButton = UIButton(configuration: insetConfiguration)
    private lazy var fatButton = UIButton(configuration: insetConfiguration)
    private lazy var sugarButton = UIButton(configuration: insetConfiguration)
    private lazy var caffeineButton = UIButton(configuration: insetConfiguration)
    private lazy var natriumButton = UIButton(configuration: insetConfiguration)
    private let nutritionLabelText: [String] = ["열량", "탄수화물", "단백질", "지방", "당류","카페인", "나트륨"]
    private lazy var nutritionButtons: [UIButton] = [energyButton, carbohydrateButton, proteinButton, fatButton, sugarButton,caffeineButton, natriumButton]
    var highlightNutrition: NutritionName?
    
    lazy var currentHilightedButton: UIButton? = nil
    
    @objc private func filterNutrition(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? .black : .white
        guard let senderTitle = sender.currentAttributedTitle?.string else {return}
        if sender == currentHilightedButton {
            highlightDelegate?.disableHighlightCells()
            currentHilightedButton = nil
            highlightNutrition = nil
            return
        } else {
            switch senderTitle {
            case "열량":
                highlightDelegate?.highlightCells(nutrition: NutritionName.energy)
                highlightNutrition = .energy
            case "탄수화물":
                highlightDelegate?.highlightCells(nutrition: NutritionName.carbohydrate)
                highlightNutrition = .carbohydrate
            case "단백질":
                highlightDelegate?.highlightCells(nutrition: NutritionName.protein)
                highlightNutrition = .protein
            case "지방":
                highlightDelegate?.highlightCells(nutrition: NutritionName.fat)
                highlightNutrition = .fat
            case "당류":
                highlightDelegate?.highlightCells(nutrition: NutritionName.sugar)
                highlightNutrition = .sugar
            case "나트륨":
                highlightDelegate?.highlightCells(nutrition: NutritionName.natrium)
                highlightNutrition = .natrium
            case "카페인":
                highlightDelegate?.highlightCells(nutrition: NutritionName.caffeine)
                highlightNutrition = .caffeine
            default:
                print("error")
            }
        }
        guard let hilightedButton = currentHilightedButton else {
            currentHilightedButton = sender
            return
        }
        hilightedButton.isSelected = false
        hilightedButton.tintColor = .white
        currentHilightedButton = sender
    }
    
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
        nutritionButtons.enumerated().forEach{(index, button) in
            button.setAttributedTitle(NSAttributedString(string: nutritionLabelText[index], attributes: [
                .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 14)!
            ]), for: .normal)
            button.titleLabel?.textAlignment = .center
            button.tintColor = .white
            button.backgroundColor = UIColor(hexString: "#BFBFBF")
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(filterNutrition(_:)), for: .touchUpInside)
        }
        addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryStackView.topAnchor.constraint(equalTo: topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryStackView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}
