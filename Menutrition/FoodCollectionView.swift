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
    let initialImageView: UIImageView = {
        let imageView = UIImageView()
        let noDataImage = UIImage(named: "NoData")
        imageView.image = noDataImage
        return imageView
    }()
    let initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 15)
        label.textColor = UIColor(hexString: "#868686")
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.33
        label.attributedText = NSMutableAttributedString(string: "아래 버튼을 눌러 메뉴를 스캔해요", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func allFoodCells() async -> [FoodCell] {
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
            initialImageView.heightAnchor.constraint(equalToConstant: 130),
            initialImageView.widthAnchor.constraint(equalToConstant: 200)
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
    func highlightCells(nutrition: NutritionName) {
        Task {
            let foodCells = await self.allFoodCells()
            foodCells.forEach{ foodCell in
                foodCell.highlightItem = nutrition
            }
        }
    }
    func disableHighlightCells() {
        Task{
            let foodCells = await self.allFoodCells()
            foodCells.forEach{ foodCell in
                foodCell.highlightItem = nil
            }
        }
    }
}

protocol EnableHighlightCells {
    func highlightCells(nutrition: NutritionName)
    func disableHighlightCells()
}
