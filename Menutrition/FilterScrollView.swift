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
        return insetConfiguration
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let categoryStackView = UIStackView(arrangedSubviews: nutritionButtons)
        categoryStackView.axis = .horizontal
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
    private let nutritionLabelText: [String] = ["열량", "탄수화물", "단백질", "지방", "당류","카페인", "나트륨",]
    private lazy var nutritionButtons: [UIButton] = [energyButton, carbohydrateButton, proteinButton, fatButton, sugarButton,caffeineButton, natriumButton]
    
    private lazy var currentHilightedButton: UIButton? = nil
    
    @objc private func filterNutrition(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? .black : .white
        let senderTitle = sender.currentTitle
        let isActive = sender.isSelected
        switch senderTitle {
        case "열량":
            highlightDelegate?.highlightCells(nutrition: NutritionName.energy, isActive: isActive)
            print("열량 버튼 \(isActive)")
        case "탄수화물":
            highlightDelegate?.highlightCells(nutrition: NutritionName.carbohydrate, isActive: isActive)
        case "단백질":
            highlightDelegate?.highlightCells(nutrition: NutritionName.protein, isActive: isActive)
        case "지방":
            highlightDelegate?.highlightCells(nutrition: NutritionName.fat, isActive: isActive)
        case "당류":
            highlightDelegate?.highlightCells(nutrition: NutritionName.sugar, isActive: isActive)
        case "나트륨":
            highlightDelegate?.highlightCells(nutrition: NutritionName.natrium, isActive: isActive)
        case "카페인":
            highlightDelegate?.highlightCells(nutrition: NutritionName.caffeine, isActive: isActive)
        default:
            print("error ")
        }
        guard let currentHilighted = currentHilightedButton else {
            currentHilightedButton = sender
            return
        }
        if currentHilighted != sender {
            let currentHilightedTitle = currentHilighted.currentTitle
            switch currentHilightedTitle {
            case "열량":
                highlightDelegate?.highlightCells(nutrition: NutritionName.energy, isActive: false)
            case "탄수화물":
                highlightDelegate?.highlightCells(nutrition: NutritionName.carbohydrate, isActive: false)
            case "단백질":
                highlightDelegate?.highlightCells(nutrition: NutritionName.protein, isActive: false)
            case "지방":
                highlightDelegate?.highlightCells(nutrition: NutritionName.fat, isActive: false)
            case "나트륨":
                highlightDelegate?.highlightCells(nutrition: NutritionName.natrium, isActive: false)
            case "당류":
                highlightDelegate?.highlightCells(nutrition: NutritionName.sugar, isActive: false)
            case "카페인":
                highlightDelegate?.highlightCells(nutrition: NutritionName.caffeine, isActive: false)
            default:
                print("error ")
            }
            currentHilighted.isSelected = false
            currentHilighted.tintColor = .white
            currentHilightedButton = sender
        }
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
            button.setTitle(nutritionLabelText[index], for: .normal)
            button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 11)
            button.titleLabel?.textAlignment = .center
            button.tintColor = .white
            button.backgroundColor = UIColor(hexString: "#D9D9D9")
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
