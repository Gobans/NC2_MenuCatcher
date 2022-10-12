//
//  FoodCollectionView.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/30.
//

import UIKit

class FoodCollectionView: UICollectionView {
    lazy var initialUIView: UIView = {
       let uiView = UIView()
        return uiView
    }()
    private let initialImageView: UIImageView = {
        let imageView = UIImageView()
        let noDataImage = UIImage(named: "NoData")
        imageView.image = noDataImage
        return imageView
    }()
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.text = "스캔한 음식정보가 아직 없네요"
        return label
    }()
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func allFoodCells() -> [FoodCell] {
        var cells = [FoodCell]()
        for i in 0...self.numberOfSections-1
        {
            if numberOfItems(inSection: i) != 0 {
                for j in 0...self.numberOfItems(inSection: i) - 1
                {
                    if let cell = self.cellForItem(at: NSIndexPath(row: j, section: i) as IndexPath) as? FoodCell {
                        cells.append(cell)
                    }
                }
            }
        }
        return cells
    }
    
    func setUpConstraints() {
        addSubview(initialUIView)
        initialUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            initialUIView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -110),
            initialUIView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        initialUIView.addSubview(initialImageView)
        initialImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            initialImageView.centerYAnchor.constraint(equalTo: initialUIView.centerYAnchor),
            initialImageView.centerXAnchor.constraint(equalTo: initialUIView.centerXAnchor),
            initialImageView.heightAnchor.constraint(equalToConstant: 60),
            initialImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        initialUIView.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            initialLabel.centerXAnchor.constraint(equalTo: initialUIView.centerXAnchor),
            initialLabel.topAnchor.constraint(equalTo: initialImageView.bottomAnchor, constant: 20)
        ])
    }
}

extension FoodCollectionView: EnableHighlightCells {
    func highlightCells(nutrition: NutritionName, isActive: Bool) {
        let foodCells = self.allFoodCells()
        foodCells.forEach{ foodCell in
            foodCell.highlightNutritionLabel(nutrition: nutrition, isActive: isActive)
        }
    }
}

protocol EnableHighlightCells {
    func highlightCells(nutrition: NutritionName, isActive: Bool)
}
