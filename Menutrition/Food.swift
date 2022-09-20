//
//  Food.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/09/01.
//

import Foundation

struct Food {
    let id = UUID()
    let name: String
    let serving: Int64
    let unit: String
    let energy: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let sugar: Double
    let natrium: Double
    let cholesterol: Double
    let saturatedFat: Double
    let transFat: Double
    let caffeine: Double
    let category: String
    var recognizedText: String = ""
}

extension Food: Hashable {
    static func == (lhs: Food, rhs: Food) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
