//
//  FoodCollectionViewCell.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/01.
//

import Foundation
import UIKit

class FoodCollectionViewCell: UICollectionViewCell {

    static let identifier = "FoodCollectionViewCell"
    
    var leftNutritionView: UIView = {
        let view = UIView()
        return view
    }()
    var rightNutritionView: UIView = {
        let view = UIView()
        return view
    }()
    var foodNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var recognizedTextLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var nutritionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 16
        label.text = ""
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    private func configureCell() {
        contentView.layer.borderWidth = 1
        leftNutritionView.layer.borderWidth = 0.5
        configureSubViews()
        configureConstraints()
    }
    
    private func configureSubViews() {
        contentView.addSubview(leftNutritionView)
        contentView.addSubview(rightNutritionView)
        leftNutritionView.addSubview(foodNameLabel)
        leftNutritionView.addSubview(recognizedTextLabel)
        rightNutritionView.addSubview(nutritionLabel)
    }
    
    private func configureConstraints() {
        leftNutritionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftNutritionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            leftNutritionView.rightAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -30),
            leftNutritionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftNutritionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        rightNutritionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightNutritionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            rightNutritionView.leftAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -30),
            rightNutritionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightNutritionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        foodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodNameLabel.centerYAnchor.constraint(equalTo: leftNutritionView.centerYAnchor),
            foodNameLabel.centerXAnchor.constraint(equalTo: leftNutritionView.centerXAnchor)
        ])
        
        recognizedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recognizedTextLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 20),
            recognizedTextLabel.centerXAnchor.constraint(equalTo: leftNutritionView.centerXAnchor)
        ])
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nutritionLabel.topAnchor.constraint(equalTo: rightNutritionView.topAnchor),
            nutritionLabel.leadingAnchor.constraint(equalTo: rightNutritionView.leadingAnchor,constant: 20),
            nutritionLabel.rightAnchor.constraint(equalTo: rightNutritionView.rightAnchor, constant: 20),
            nutritionLabel.bottomAnchor.constraint(equalTo: rightNutritionView.bottomAnchor)
        ])
    }
}
