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
    
    lazy var dataScannerViewController: DataScannerViewController = {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .accurate, recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
        viewController.delegate = self
        return viewController
    }()
    
    lazy var scanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "text.viewfinder") , style: .plain, target: self, action: #selector(startScanning))
        button.tintColor = .systemBlue
        return button
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash") , style: .plain, target: self, action: #selector(deleteFoodData))
        button.tintColor = .systemBlue
        return button
    }()
    
    private let catchButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.setTitle("Catch", for: .normal)
        button.isUserInteractionEnabled = false
        button.configuration?.background.backgroundColor = .gray
        return button
    }()
    
    var currentItems: [RecognizedItem.ID: String] = [:] {
        didSet {
            if currentItems.isEmpty {
                catchButton.isUserInteractionEnabled = false
                catchButton.configuration?.background.backgroundColor = .gray
            } else {
                catchButton.isUserInteractionEnabled = true
                catchButton.configuration?.background.backgroundColor = .systemBlue
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
        navigationItem.rightBarButtonItem = scanButton
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
        dataScannerViewController.view.addSubview(catchButton)
    }
    
    private func configureConstratints() {
        catchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchButton.centerXAnchor.constraint(equalTo: dataScannerViewController.view.centerXAnchor),
            catchButton.bottomAnchor.constraint(equalTo: dataScannerViewController.view.bottomAnchor, constant: -100),
            catchButton.widthAnchor.constraint(equalToConstant: 110),
            catchButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureTargets() {
        catchButton.addTarget(self, action: #selector(catchText), for: .touchUpInside)
    }
    
    private func endScan(splitedStringArray: [String]) {
        var foodArray: [String] = []
        for phase in splitedStringArray {
            if textProcessing.isValidWord(phase) {
                foodArray.append(phase)
            }
        }
        for foodName in foodArray {
            let predictedTable = categoryClassifier.predictedLabelHypotheses(for: foodName, maximumCount: 3)
            let sortedPredictedTable = predictedTable.sorted{ $0.value > $1.value }
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
    
    @objc private func startScanning() {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            present(dataScannerViewController, animated: true)
            try? self.dataScannerViewController.startScanning()
        }
    }
    
    @objc private func catchText() {
        guard let item = currentItems.first else { return } // recognizesMultipleItems 를 사용하지않기 떄문에 하나만 선택
        let splitedStringArray:[String] = item.value.split(separator: "\n").map{String($0)}
        endScan(splitedStringArray: splitedStringArray)
        dataScannerViewController.dismiss(animated: true)
        dataScannerViewController.stopScanning()
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
        let tempString = "1회 제공량: \(String(foodInfo.serving))\(foodInfo.unit)\n열량: \(String(foodInfo.energy))\n단백질: \(foodInfo.protein)\n지방: \(foodInfo.fat)\n탄수화물: \(foodInfo.carbohydrate)\n당류: \(foodInfo.sugar)\n카페인: \(foodInfo.caffeine)"
        cell.nutritionLabel.text = tempString
        return cell
    }
}
