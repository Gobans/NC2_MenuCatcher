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
    
    // Used Class
    
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
    
    // UI Component
    
    private let filterScorllView = FilterScrollView()
    
    enum Section {
        case main
    }
    
    private lazy var collectionView = FoodCollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Section, Food>?
    
    private let padding: CGFloat = 12
    
    lazy var dataSingleScannerViewController: DataScannerViewController = {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .accurate, recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: false, isHighlightingEnabled: true)
        viewController.delegate = self
        return viewController
    }()
    
    lazy var singleScanButton: UIButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration.init(pointSize: 25)
        let viewfinderImageView = UIImage(systemName: "text.viewfinder", withConfiguration: imageConfiguration)
        button.setImage(viewfinderImageView, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(startSinggleScanning), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 0.5 * 60
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
    
    var foodDataArray: [Food] = []
    
    var allFoodNameDictionary: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpCollectionView()
        Task {
            allFoodNameDictionary = await sqlite.fetchAllFoodName()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(hexString: "FAFAFA")
        navigationItem.leftBarButtonItem = deleteButton
        navigationItem.title = "메뉴 캐처"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureSubViews()
        configureConstratints()
        setUpCollectionView()
        setUpDataSource()
        
        // Setup Delegate
        collectionView.delegate = self
        filterScorllView.highlightDelegate = collectionView
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .estimated(50))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                         subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = .init(top: 40, leading: 20, bottom: 120, trailing: 20)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setUpCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
        collectionView.register(FoodCell.self, forCellWithReuseIdentifier: String(describing: FoodCell.self))
        collectionView.backgroundColor = UIColor(hexString: "FAFAFA")
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: filterScorllView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Food>(collectionView: collectionView) {
            (collectionView, indexPath, food) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: FoodCell.self),
                for: indexPath) as? FoodCell else {
                    fatalError("Could not cast cell as \(FoodCell.self)")
            }
            cell.food = food
            cell.delegate = self
            return cell
        }
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Food>()
        snapshot.appendSections([.main])
        snapshot.appendItems(foodDataArray)
        dataSource?.apply(snapshot)
    }

    
    private func configureSubViews() {
        view.addSubview(filterScorllView)
        collectionView.addSubview(singleScanButton)
        dataSingleScannerViewController.view.addSubview(catchSinggleButton)
    }
    
    private func configureConstratints() {
        filterScorllView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterScorllView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterScorllView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterScorllView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
            filterScorllView.heightAnchor.constraint(equalToConstant: 23)
        ])
        
        catchSinggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleButton.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleButton.bottomAnchor.constraint(equalTo: dataSingleScannerViewController.view.bottomAnchor, constant: -100),
            catchSinggleButton.widthAnchor.constraint(equalToConstant: 110),
            catchSinggleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        singleScanButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            singleScanButton.bottomAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.bottomAnchor, constant: -40),
            singleScanButton.trailingAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.trailingAnchor, constant: -30),
            singleScanButton.heightAnchor.constraint(equalToConstant: 60),
            singleScanButton.widthAnchor.constraint(equalToConstant: 60)
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
            if var food = await sqlite.fetchFoodDataByName(tableName: simliarFoodTable, foodName: simliarFoodName) {
                food.recognizedText = foodName
                foodDataArray.insert(food, at: foodInsertIndex)
                foodInsertIndex += 1
                DispatchQueue.main.async {
                    self.updateFoodDataSource()
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
        updateFoodDataSource()
    }
    
    private func updateFoodDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Food>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.foodDataArray)
        self.dataSource?.apply(snapshot)
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

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        dataSource.refresh()
        return
    }
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        dataSource.refresh()
        return
    }
}

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: true, completion: completion)
    }
}

extension ViewController: SwipeableCollectionViewCellDelegate {
    func foodCellSwiped(inCell cell: FoodCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
          foodDataArray.remove(at: indexPath.item)
        var snapshot = NSDiffableDataSourceSnapshot<Section, Food>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.foodDataArray)
        dataSource?.apply(snapshot, animatingDifferences: true)
        print("delete")
    }
}
