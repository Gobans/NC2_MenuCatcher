//
//  FoodCollectionView.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/30.
//

import UIKit

class FoodCollectionView: UICollectionView {
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
