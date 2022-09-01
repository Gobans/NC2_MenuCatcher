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
            fatalError()
        }
    }
    
    let textProcessing = TextProcessing()
    
    let sqlite = Sqlite.shared
    
    lazy var dataMultipleScannerViewController: DataScannerViewController = {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .accurate, recognizesMultipleItems: true, isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
        viewController.delegate = self
        return viewController
    }()
    
    lazy var dataSingleScannerViewController: DataScannerViewController = {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .accurate, recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
        viewController.delegate = self
        return viewController
    }()
    
    lazy var multiScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "text.viewfinder") , style: .plain, target: self, action: #selector(startMultipleScanning))
        button.tintColor = .systemBlue
        return button
    }()
    
    lazy var singleScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "viewfinder") , style: .plain, target: self, action: #selector(startSinggleScanning))
        button.tintColor = .systemBlue
        return button
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash") , style: .plain, target: self, action: #selector(deleteFoodData))
        button.tintColor = .systemBlue
        return button
    }()
    
    private let catchMultipleButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.setTitle("Catch", for: .normal)
        button.isUserInteractionEnabled = false
        button.configuration?.background.backgroundColor = .gray
        return button
    }()
    
    private let catchSinggleButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.setTitle("Catch", for: .normal)
        button.isUserInteractionEnabled = false
        button.configuration?.background.backgroundColor = .gray
        return button
    }()
    
    var isMultiple = false
    
    var currentItems: [RecognizedItem.ID: String] = [:] {
        didSet {
            if currentItems.isEmpty {
                catchMultipleButton.isUserInteractionEnabled = false
                catchMultipleButton.configuration?.background.backgroundColor = .gray
                catchSinggleButton.isUserInteractionEnabled = false
                catchSinggleButton.configuration?.background.backgroundColor = .gray
            } else {
                catchMultipleButton.isUserInteractionEnabled = true
                catchMultipleButton.configuration?.background.backgroundColor = .systemBlue
                catchSinggleButton.isUserInteractionEnabled = true
                catchSinggleButton.configuration?.background.backgroundColor = .systemBlue
            }
        }
    }
    
    var foodDataArray: [FoodData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        registerCollectionView()
        configureViewDelegate()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItems = [singleScanButton, multiScanButton]
        navigationItem.leftBarButtonItem = deleteButton
        navigationItem.title = "Menu Catcher"
        configureSubViews()
        configureConstratints()
        configureTargets()
    }
    
    private func configureCollectionView() {
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
    }
    
    func registerCollectionView() {
        foodCollectionView.register(FoodCollectionViewCell.self, forCellWithReuseIdentifier: FoodCollectionViewCell.identifier)
    }
    
    func configureViewDelegate() {
        foodCollectionView.delegate = self
        foodCollectionView.dataSource = self
    }
    
    private func configureSubViews() {
        dataMultipleScannerViewController.view.addSubview(catchMultipleButton)
        dataSingleScannerViewController.view.addSubview(catchSinggleButton)
    }
    
    private func configureConstratints() {
        catchMultipleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchMultipleButton.centerXAnchor.constraint(equalTo: dataMultipleScannerViewController.view.centerXAnchor),
            catchMultipleButton.bottomAnchor.constraint(equalTo: dataMultipleScannerViewController.view.bottomAnchor, constant: -100),
            catchMultipleButton.widthAnchor.constraint(equalToConstant: 110),
            catchMultipleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        catchSinggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleButton.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleButton.bottomAnchor.constraint(equalTo: dataSingleScannerViewController.view.bottomAnchor, constant: -100),
            catchSinggleButton.widthAnchor.constraint(equalToConstant: 110),
            catchSinggleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureTargets() {
        catchMultipleButton.addTarget(self, action: #selector(catchText), for: .touchUpInside)
        catchSinggleButton.addTarget(self, action: #selector(catchText), for: .touchUpInside)
    }
    
    private func endScan(splitedStringArray: [String]) {
        var foodArray: [String] = []
        for phase in splitedStringArray {
            if textProcessing.isValidWord(phase) {
                print(phase)
                foodArray.append(phase)
            }
        }
        for foodName in foodArray {
            let predictedTable = categoryClassifier.predictedLabelHypotheses(for: foodName, maximumCount: 3)
            let sortedPredictedTable = predictedTable.sorted{ $0.value > $1.value }
            print(sortedPredictedTable)
            Task {
                if var foodData = await fetchFoodDataFromDB(sortedPredictedTable: sortedPredictedTable, foodName: foodName) {
                    foodData.recognizedText = foodName
                    foodDataArray.append(foodData)
                    DispatchQueue.main.async {
                        self.foodCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchFoodDataFromDB(sortedPredictedTable: [Dictionary<String, Double>.Element], foodName: String) async -> FoodData? {
        for item in sortedPredictedTable {
            let dbFoodNameArray = await sqlite.fetchFoodNameByTable(item.key)
            let result = textProcessing.findSimliarWord(baseString: foodName, otehrStringArray: dbFoodNameArray)
            let vaildFoodName = result.0
            if vaildFoodName != "" {
                let foodData = await sqlite.fetchFoodDataByName(tableName: item.key, foodName: vaildFoodName)
                return foodData
            }
        }
        return nil
    }
    
    @objc private func startMultipleScanning() {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            isMultiple = true
            present(dataMultipleScannerViewController, animated: true)
            try? self.dataMultipleScannerViewController.startScanning()
        }
    }
    
    @objc private func startSinggleScanning() {
        isMultiple = false
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
        endScan(splitedStringArray: splitedStringArray)
        if isMultiple {
            dataMultipleScannerViewController.dismiss(animated: true)
            dataMultipleScannerViewController.stopScanning()
        } else {
            dataSingleScannerViewController.dismiss(animated: true)
            dataSingleScannerViewController.stopScanning()
        }
        
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
        let tempString = "1회 제공량: \(String(foodInfo.serving))\(foodInfo.unit)\n열량: \(String(foodInfo.energy)) kcal\n단백질: \(foodInfo.protein)g\n지방: \(foodInfo.fat)g\n탄수화물: \(foodInfo.carbohydrate)g\n당류: \(foodInfo.sugar)g\n카페인: \(foodInfo.caffeine)mg"
        cell.nutritionLabel.text = tempString
        return cell
    }
}
