//
//  ViewController.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/08/25.
//

import UIKit
import NaturalLanguage
import CoreML

class ViewController: UIViewController {
    var categoryClassifier: NLModel {
        do {
            let mlModel = try FoodCategoryClassfier(configuration: MLModelConfiguration()).model
            let categoryPredictor = try NLModel(mlModel: mlModel)
            return categoryPredictor
        } catch {
            fatalError()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        print(categoryClassifier.predictedLabelHypotheses(for: "아구", maximumCount: 3))
//        Sqlite.shared.fetchData()
    }
}

