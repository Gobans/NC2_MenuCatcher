//
//  ViewController.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/08/25.
//

import UIKit
import NaturalLanguage
import CoreML
import VisionKit

final class ViewController: UIViewController {
    
    private var foodCollectionView: FoodCollectionView!
    
    var categoryClassifier: NLModel {
        do {
            let mlModel = try FoodCategoryClassfier(configuration: MLModelConfiguration()).model
            let categoryPredictor = try NLModel(mlModel: mlModel)
            return categoryPredictor
        } catch {
            fatalError("Faild to initialize NLModel")
        }
    }
    
    let textProcessing = TextProcessing()
    
    let sqlite = Sqlite.shared
    
    lazy var dataSingleScannerViewController: DataScannerViewController = {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .accurate, recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: false, isHighlightingEnabled: true)
        viewController.delegate = self
        return viewController
    }()
    
    lazy var singleScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "text.viewfinder") , style: .plain, target: self, action: #selector(startSinggleScanning))
        button.tintColor = .systemBlue
        return button
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash") , style: .plain, target: self, action: #selector(deleteFoodData))
        button.tintColor = .systemBlue
        return button
    }()
    
    lazy var catchSinggleButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(catchText), for: .touchUpInside)
        button.configuration = .filled()
        button.setTitle("Catch", for: .normal)
        button.isUserInteractionEnabled = false
        button.configuration?.background.backgroundColor = .gray
        return button
    }()
    
    var currentItems: [RecognizedItem.ID: String] = [:] {
        didSet {
            if currentItems.isEmpty {
                catchSinggleButton.isUserInteractionEnabled = false
                catchSinggleButton.configuration?.background.backgroundColor = .gray
            } else {
                catchSinggleButton.isUserInteractionEnabled = true
                catchSinggleButton.configuration?.background.backgroundColor = .systemBlue
            }
        }
    }
    
    var foodDataArray: [FoodData] = []
    
    var allFoodNameDictionary: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        configureViewDelegate()
        Task {
            allFoodNameDictionary = await sqlite.fetchAllFoodName()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = singleScanButton
        navigationItem.leftBarButtonItem = deleteButton
        navigationItem.title = "Menu Catcher"
        configureSubViews()
        configureConstratints()
    }
    
    func configureCollectionView() {
        let collectionViewLayer = UICollectionViewFlowLayout()
        foodCollectionView = FoodCollectionView(frame: .zero, collectionViewLayout: collectionViewLayer)
        view.addSubview(foodCollectionView)
        foodCollectionView.backgroundColor = .white
        foodCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            foodCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            foodCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            foodCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        registerCollectionView()
    }
    
    func registerCollectionView() {
        foodCollectionView.register(FoodCollectionViewCell.self, forCellWithReuseIdentifier: FoodCollectionViewCell.identifier)
    }
    
    func configureViewDelegate() {
        foodCollectionView.delegate = self
        foodCollectionView.dataSource = self
    }
    
    private func configureSubViews() {
        dataSingleScannerViewController.view.addSubview(catchSinggleButton)
    }
    
    private func configureConstratints() {
        catchSinggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleButton.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleButton.bottomAnchor.constraint(equalTo: dataSingleScannerViewController.view.bottomAnchor, constant: -100),
            catchSinggleButton.widthAnchor.constraint(equalToConstant: 110),
            catchSinggleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func endScan(splitedStringArray: [String]) async {
        let start = CFAbsoluteTimeGetCurrent()
        var foodArray: [String] = []
        for phase in splitedStringArray {
            if textProcessing.isValidWord(phase) {
                foodArray.append(phase)
            }
        }
        var foodInsertIndex:Int = 0
        for foodName in foodArray {
            let rmSpacingFoodName = foodName.replacingOccurrences(of: " ", with: "")
            let predictedTable = categoryClassifier.predictedLabelHypotheses(for: foodName, maximumCount: 8)
            let sortedPredictedTable = predictedTable.sorted{ $0.value > $1.value }.map{ $0.key }
            var vaildfoodNameDictionary: [String: [String]] = [:]
            let _ =  sortedPredictedTable.map {
                vaildfoodNameDictionary[$0] = []
            }
            for table in sortedPredictedTable {
                guard let vaildFoodNameArray = allFoodNameDictionary[table] else {
                    return
                }
                let vaildConsonantFood = textProcessing.checkVaildConsonantFood(verifyString: rmSpacingFoodName, dbFoodNameArray: vaildFoodNameArray)
                let _ = vaildConsonantFood.map {
                    vaildfoodNameDictionary[table]?.append($0)
                }
            }
            let result = textProcessing.findSimliarWord(baseString: rmSpacingFoodName, vaildfoodNameDictionary: vaildfoodNameDictionary)
            let simliarFoodName = result.0.0
            let simliarFoodTable = result.0.1
            let simliarFoodArray = result.1
            if var foodData = await sqlite.fetchFoodDataByName(tableName: simliarFoodTable, foodName: simliarFoodName) {
                foodData.recognizedText = foodName
                foodDataArray.insert(foodData, at: foodInsertIndex)
                foodInsertIndex += 1
                DispatchQueue.main.async {
                    self.foodCollectionView.reloadData()
                    let processTime = CFAbsoluteTimeGetCurrent() - start
                    print("경과시간 \(processTime)")
                }
            }
        }
    }
    
    @objc private func startSinggleScanning() {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            present(dataSingleScannerViewController, animated: true)
            try? self.dataSingleScannerViewController.startScanning()
        }
    }
    
    @objc private func catchText() {
        var splitedStringArray: [String] = []
        for item in currentItems {
            let tempStringArray:[String] = item.value.split(separator: "\n").map{String($0)}
            for tempString in tempStringArray {
                splitedStringArray.append(tempString)
            }
        }
        Task {
            await endScan(splitedStringArray: splitedStringArray)
        }
        dataSingleScannerViewController.dismiss(animated: true)
        dataSingleScannerViewController.stopScanning()
    }
    
    @objc private func deleteFoodData() {
        foodDataArray.removeAll()
        foodCollectionView.reloadData()
    }
}

extension ViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
            case .text(let text):
                currentItems[item.id] = text.transcript
            default:
                break
            }
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didUpdate addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
            case .text(let text):
                currentItems[item.id] = text.transcript
            default:
                break
            }
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didRemove addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            currentItems.removeValue(forKey: item.id)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("make cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodCollectionViewCell.identifier, for: indexPath) as! FoodCollectionViewCell
        let foodInfo = foodDataArray[indexPath.row]
        cell.foodNameLabel.text = foodInfo.name
        cell.recognizedTextLabel.text = "인식된 text: \(foodInfo.recognizedText)"
        let tempString = "1회 제공량: \(String(foodInfo.serving))\(foodInfo.unit)\n열량: \(String(foodInfo.energy)) kcal\n단백질: \(foodInfo.protein)g\n지방: \(foodInfo.fat)g\n탄수화물: \(foodInfo.carbohydrate)g\n당류: \(foodInfo.sugar)g\n나트륨: \(foodInfo.natrium)mg\n콜레스테롤: \(foodInfo.cholesterol)mg\n포화지방: \(foodInfo.saturatedFat)mg\n트랜스지방: \(foodInfo.transFat)mg\n카페인: \(foodInfo.caffeine)mg"
        cell.nutritionLabel.text = tempString
        return cell
    }
}
