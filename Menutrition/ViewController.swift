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
    
    private let scanButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Scan", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
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
    
    private let catchLabel: UILabel = {
        let label = UILabel()
        label.text = "none"
        label.textColor = .red
        label.numberOfLines = 20
        return label
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        configureSubViews()
        configureConstratints()
        configureTargets()
    }
    
    private func configureSubViews() {
        view.addSubview(scanButton)
        view.addSubview(catchLabel)
        dataScannerViewController.view.addSubview(catchButton)
    }
    
    private func configureConstratints() {
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
        ])
        
        catchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchButton.centerXAnchor.constraint(equalTo: dataScannerViewController.view.centerXAnchor),
            catchButton.bottomAnchor.constraint(equalTo: dataScannerViewController.view.bottomAnchor, constant: -100),
            catchButton.widthAnchor.constraint(equalToConstant: 110),
            catchButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        catchLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchLabel.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 30),
            catchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            catchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    private func configureTargets() {
        scanButton.addTarget(self, action: #selector(startScanning), for: .touchUpInside)
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
            print("foodName: \(foodName)")
            let predictedTable = categoryClassifier.predictedLabelHypotheses(for: foodName, maximumCount: 3)
            print("predictedTable: \(predictedTable)")
            var sortedPredictedTable = predictedTable.sorted{ $0.value < $1.value }
            print("sortedPredictedTable: \(sortedPredictedTable)")
            guard let table = sortedPredictedTable.popLast()?.key else { return }
            print("table: \(table)")
            while(!sortedPredictedTable.isEmpty) {
                guard let table = sortedPredictedTable.popLast()?.key else { return }
                let dbFoodNameArray = Sqlite.shared.fetchFoodNameByTable(table)
                print("dbFoodNameArray: \(dbFoodNameArray)")
                let result = textProcessing.findSimliarWord(baseString: foodName, otehrStringArray: dbFoodNameArray)
                let vaildFoodName = result.0
                let candidateFoodNameArray: [String] = result.1
                if vaildFoodName != "" {
                    print(vaildFoodName)
                    break
                }
            }
        }
    }
    
    @objc private func startScanning() {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            present(dataScannerViewController, animated: true)
            try? self.dataScannerViewController.startScanning()
        }
    }
    
    @objc private func catchText() {
        guard let item = currentItems.first else { return } // recognizesMultipleItems 를 사용하지않기 떄문에 하나만 선택
        catchLabel.text = item.value
        let splitedStringArray:[String] = item.value.split(separator: "\n").map{String($0)}
        endScan(splitedStringArray: splitedStringArray)
        dataScannerViewController.dismiss(animated: true)
        dataScannerViewController.stopScanning()
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
