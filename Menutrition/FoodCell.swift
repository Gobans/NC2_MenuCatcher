//
//  FoodCollectionViewCell.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/01.
//

import UIKit
import SwipeCellKit

protocol UICollectionViewCellHighlight {
    func highlightNutritionLabel(nutrition: NutritionName, isActive: Bool)
}

protocol EnableDisplayToolTipView {
    func displayToolTip(centerX: NSLayoutXAxisAnchor, topAnchor: NSLayoutYAxisAnchor, recognizedText: String)
}


class FoodCell: SwipeCollectionViewCell {
    static let identifier = "FoodCollectionViewCell"
    
    var tooltipDelegate: EnableDisplayToolTipView?
    var food: Food? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    var isSwipeDeleting: Bool = false
    
    // Views
    private let foodCategoryImageView: UIImageView = {
        let foodCategoryImageView = UIImageView()
        foodCategoryImageView.contentMode = .scaleAspectFit
        return foodCategoryImageView
    }()
    
    private lazy var recognizedTextButton: UIButton = {
        let recognizedTextButton = UIButton()
        let questionMarkImage = UIImage(systemName: "questionmark.circle.fill")
        recognizedTextButton.setImage(questionMarkImage, for: .normal)
        recognizedTextButton.tintColor = UIColor(hexString: "#D9D9D9")
        recognizedTextButton.contentMode = .scaleAspectFit
        recognizedTextButton.isHidden = true
        recognizedTextButton.addTarget(self, action: #selector(showRecognizedText), for: .touchUpInside)
        return recognizedTextButton
    }()
    
    private let titleContentUIView = UIView()
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        return nameLabel
    }()
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
        subtitleLabel.textColor = UIColor(hexString: "#868686")
        return subtitleLabel
    }()
    private let spacerView: UIView = {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }()
    private let seperatorView: UIView = {
        let seperatorView = UIView()
        seperatorView.backgroundColor = .clear
        return seperatorView
    }()
    private let servingLabel = UILabel()
    private lazy var nutritionLabels: [NutritionPaddingLabel] = [energyLabel, carbohydrateLabel, proteinLabel, fatLabel, sugarLabel, caffeineLabel, natriumLabel]
    private lazy var nutritionNumberViews: [HighlightNumberView] = [energyNumberView, carbohydrateNumberView, proteinNumberView, fatNumberView, sugarNumberView, caffeineNumberView, natriumNumberView]
    private let nutritionLabelText: [String] = ["열량", "탄수화물", "단백질", "지방", "당류", "카페인", "나트륨"]
    private let energyLabel = NutritionPaddingLabel()
    private let carbohydrateLabel = NutritionPaddingLabel()
    private let proteinLabel = NutritionPaddingLabel()
    private let fatLabel = NutritionPaddingLabel()
    private let sugarLabel = NutritionPaddingLabel()
    private let caffeineLabel = NutritionPaddingLabel()
    private let natriumLabel = NutritionPaddingLabel()
    private let energyNumberView = HighlightNumberView()
    private let carbohydrateNumberView = HighlightNumberView()
    private let proteinNumberView = HighlightNumberView()
    private let fatNumberView = HighlightNumberView()
    private let sugarNumberView = HighlightNumberView()
    private let caffeineNumberView = HighlightNumberView()
    private let natriumNumberView = HighlightNumberView()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(named: "Indicator")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        disclosureIndicator.tintColor = .black
        return disclosureIndicator
    }()
    
    // StackViews
    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            titleContentStackView,
            spacerView,
            servingLabel,
            nutritionRootStackView
        ])
        labelStack.alignment = .top
        labelStack.axis = .vertical
        labelStack.spacing = labelPadding
        labelStack.distribution = .fillProportionally
        return labelStack
    }()
    private lazy var titleContentStackView: UIStackView = {
        let UIStackView = UIStackView(arrangedSubviews: [foodCategoryImageView, titleLabelStackView, titleContentUIView])
        UIStackView.axis = .horizontal
        UIStackView.distribution = .fill
        UIStackView.alignment = .center
        UIStackView.spacing = 14
        return UIStackView
    }()
    private lazy var titleLabelStackView: UIStackView = {
        let UIStackView = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        UIStackView.axis = .vertical
        UIStackView.distribution = .fillProportionally
        UIStackView.spacing = 5
        return UIStackView
    }()
    private lazy var nutritionRootStackView: UIStackView = {
        let nutritionRootStackView = UIStackView(arrangedSubviews: [nutritionLeftStackView, nutritionRightStackView])
        nutritionRootStackView.axis = .horizontal
        nutritionRootStackView.alignment = .leading
        nutritionRootStackView.distribution = .fillEqually
        nutritionRootStackView.spacing = 30
        nutritionRootStackView.isLayoutMarginsRelativeArrangement = true
        nutritionRootStackView.layoutMargins.bottom = 30
        return nutritionRootStackView
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
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [energyLabel, carbohydrateLabel, proteinLabel, natriumLabel])
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
        let nutritionLeftStackView = UIStackView(arrangedSubviews: [energyNumberView, carbohydrateNumberView, proteinNumberView, natriumNumberView])
        nutritionLeftStackView.axis = .vertical
        nutritionLeftStackView.spacing = 10
        return nutritionLeftStackView
    }()
    private lazy var nutritionRightNumberStackView: UIStackView = {
        let nutritionRightStackView = UIStackView(arrangedSubviews: [fatNumberView, sugarNumberView, caffeineNumberView])
        nutritionRightStackView.axis = .vertical
        nutritionRightStackView.spacing = 10
        return nutritionRightStackView
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        energyNumberView.highlightUIView.alpha = 0
        proteinNumberView.highlightUIView.alpha = 0
        fatNumberView.highlightUIView.alpha = 0
        carbohydrateNumberView.highlightUIView.alpha = 0
        sugarNumberView.highlightUIView.alpha = 0
        natriumNumberView.highlightUIView.alpha = 0
        caffeineNumberView.highlightUIView.alpha = 0
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
        servingLabel.font = UIFont(name: "Roboto-SemiBold", size: 14)
        nutritionLabels.enumerated().forEach{(index, label) in
            label.text = "\(nutritionLabelText[index])"
            label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .black
            label.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
        }
        nutritionNumberViews.enumerated().forEach{(index, numberView) in
            numberView.numberLabel.textAlignment = .center
        }
    }
    
    private func setUpConstraints() {
        contentView.addSubview(labelStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            labelStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: rootPadding),
            labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rootPadding),
        ])
        
        foodCategoryImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodCategoryImageView.heightAnchor.constraint(equalToConstant: 52),
            foodCategoryImageView.widthAnchor.constraint(equalTo: titleContentStackView.widthAnchor, multiplier: 0.2)
        ])
        
        contentView.addSubview(disclosureIndicator)
        disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            disclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -31),
            disclosureIndicator.centerYAnchor.constraint(equalTo: titleContentStackView.centerYAnchor),
            disclosureIndicator.heightAnchor.constraint(equalToConstant: 10),
            disclosureIndicator.widthAnchor.constraint(equalToConstant: 18),
        ])
        
        contentView.addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seperatorView.widthAnchor.constraint(equalTo: labelStack.widthAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.centerXAnchor.constraint(equalTo: labelStack.centerXAnchor),
            seperatorView.centerYAnchor.constraint(equalTo: spacerView.centerYAnchor)
        ])
        
        energyNumberView.translatesAutoresizingMaskIntoConstraints = false
        carbohydrateNumberView.translatesAutoresizingMaskIntoConstraints = false
        proteinNumberView.translatesAutoresizingMaskIntoConstraints = false
        fatNumberView.translatesAutoresizingMaskIntoConstraints = false
        sugarNumberView.translatesAutoresizingMaskIntoConstraints = false
        caffeineNumberView.translatesAutoresizingMaskIntoConstraints = false
        natriumNumberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            energyNumberView.centerYAnchor.constraint(equalTo: energyLabel.centerYAnchor),
            carbohydrateNumberView.centerYAnchor.constraint(equalTo: carbohydrateLabel.centerYAnchor),
            proteinNumberView.centerYAnchor.constraint(equalTo: proteinLabel.centerYAnchor),
            fatNumberView.centerYAnchor.constraint(equalTo: fatLabel.centerYAnchor),
            sugarNumberView.centerYAnchor.constraint(equalTo: sugarLabel.centerYAnchor),
            caffeineNumberView.centerYAnchor.constraint(equalTo: caffeineLabel.centerYAnchor),
            natriumNumberView.centerYAnchor.constraint(equalTo: natriumLabel.centerYAnchor)
        ])
        
        nutritionLeftLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nutritionLeftLabelStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
        ])
        
        nutritionRightLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nutritionRightLabelStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
        ])
        
        closedConstraint =
        titleContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
        nutritionRootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        openConstraint?.priority = .defaultLow
        
        contentView.addSubview(recognizedTextButton)
        recognizedTextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recognizedTextButton.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
            recognizedTextButton.widthAnchor.constraint(equalTo: recognizedTextButton.heightAnchor),
            recognizedTextButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: -1),
            recognizedTextButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func updateContent() {
        guard let food = food else { return }
        nameLabel.text = food.name
        servingLabel.text = "1회 제공량 : \(food.serving)\(food.unit)"
        let attributedStr = NSMutableAttributedString(string: servingLabel.text!, attributes: [ .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 14)!])
        attributedStr.addAttribute(.foregroundColor, value: UIColor(hexString: "#CFCFCF"), range: (servingLabel.text! as NSString).range(of: "1회 제공량 :"))
        servingLabel.attributedText = attributedStr
        let energyNumberLabelText = "\(food.energy.getNoDigitString())kcal"
        let carbohydrateNumberLabelText = "\(food.carbohydrate.getOneDigitString())g"
        let proteinNumberLabelText = "\(food.protein.getOneDigitString())g"
        let fatNumberLabelText = "\(food.fat.getOneDigitString())g"
        let sugarNumberLabelText = "\(food.sugar.getOneDigitString())g"
        let caffeineNumberLabelText = "\(food.caffeine.getOneDigitString())mg"
        let natriumNumberLabelText = "\(food.natrium.getOneDigitString())mg"
        energyNumberView.numberLabel.attributedText = makeRobotoAttributeString(energyNumberLabelText)
        carbohydrateNumberView.numberLabel.attributedText = makeRobotoAttributeString(carbohydrateNumberLabelText)
        proteinNumberView.numberLabel.attributedText = makeRobotoAttributeString(proteinNumberLabelText)
        fatNumberView.numberLabel.attributedText = makeRobotoAttributeString(fatNumberLabelText)
        sugarNumberView.numberLabel.attributedText = makeRobotoAttributeString(sugarNumberLabelText)
        caffeineNumberView.numberLabel.attributedText = makeRobotoAttributeString(caffeineNumberLabelText)
        natriumNumberView.numberLabel.attributedText = makeRobotoAttributeString(natriumNumberLabelText)
        
        switch food.category {
        case "기타 빵류", "샌드위치류", "식빵류":
            let categoryImage = UIImage(named: "빵류")
            foodCategoryImageView.image = categoryImage
            subtitleLabel.text = "빵류"
        case "과일 채소음료류", "기타 음료류", "스무디류", "차류", "커피류", "탄산음료류":
            let categoryImage = UIImage(named: "음료류")
            foodCategoryImageView.image = categoryImage
            subtitleLabel.text = "음료류"
        case "기타 음식류", "튀김류", "피자류":
            let categoryImage = UIImage(named: "음식류")
            foodCategoryImageView.image = categoryImage
            subtitleLabel.text = "음식류"
        case "아이스크림류", "페이스트리류", "케이크류", "과자류":
            let categoryImage = UIImage(named: "디저트류")
            foodCategoryImageView.image = categoryImage
            subtitleLabel.text = "디저트류"
        default:
            print("none")
        }
        if food.name != food.recognizedText {
            recognizedTextButton.isHidden = false
        } else {
            recognizedTextButton.isHidden = true
        }
    }
    private func makeRobotoAttributeString(_ string: String) -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString(string: string, attributes: [ .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 14)!])
        return attributedStr
    }
    private func updateAppearance() {
        if !isSwipeDeleting {
            closedConstraint?.isActive = !isSelected
            openConstraint?.isActive = isSelected
            seperatorView.backgroundColor = isSelected ? UIColor(hexString: "#EFEFEF") : .clear
            UIView.animate(withDuration: 0.3) {
                let up = CGAffineTransform(rotationAngle: .pi)
                let down = CGAffineTransform(rotationAngle: .pi * 2)
                self.disclosureIndicator.transform = self.isSelected ? up : down
            }
        }
    }
    @objc private func showRecognizedText() {
        guard let recognizedText = food?.recognizedText else {return}
        if isSwipeDeleting { return }
        tooltipDelegate?.displayToolTip(centerX: recognizedTextButton.centerXAnchor, topAnchor: recognizedTextButton.topAnchor, recognizedText: recognizedText)
    }
}

extension FoodCell: UICollectionViewCellHighlight {
    func highlightNutritionLabel(nutrition: NutritionName, isActive: Bool) {
        switch nutrition {
        case .energy:
            energyNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .protein:
            proteinNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .fat:
            fatNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .carbohydrate:
            carbohydrateNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .sugar:
            sugarNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .natrium:
            natriumNumberView.highlightUIView.alpha = isActive ? 1 : 0
        case .caffeine:
            caffeineNumberView.highlightUIView.alpha = isActive ? 1 : 0
        }
    }
}
