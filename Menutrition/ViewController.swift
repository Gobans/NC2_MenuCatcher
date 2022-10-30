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
import SwipeCellKit

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
        button.layer.cornerRadius = 0.5 * 76
        return button
    }()
    
    private var catchSinggleLabel: UILabel = {
        $0.text = "메뉴판을 스캔해주세요"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 13)
        $0.textColor = .white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var catchSinggleButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(catchText), for: .touchUpInside)
        button.configuration = .filled()
        button.isUserInteractionEnabled = false
        button.configuration?.background.backgroundColor = UIColor(hexString: "#878787")
        button.clipsToBounds = true
        button.layer.cornerRadius = 0.5 * 71.58
        return button
    }()
    private var catchSinggleButtonBorderUIView: UIView = {
        $0.layer.borderColor = UIColor(hexString: "#878787").cgColor
        $0.layer.borderWidth = 2.5
        $0.layer.cornerRadius = 0.5 * 80
        return $0
    }(UIView())
    
    var currentItems: [RecognizedItem.ID: String] = [:] {
        didSet {
            if currentItems.isEmpty {
                catchSinggleButton.isUserInteractionEnabled = false
                catchSinggleButtonBorderUIView.layer.borderColor = UIColor(hexString: "#878787").cgColor
                catchSinggleButton.configuration?.background.backgroundColor =  UIColor(hexString: "#878787")
            } else {
                catchSinggleButton.isUserInteractionEnabled = true
                catchSinggleButtonBorderUIView.layer.borderColor = UIColor.white.cgColor
                catchSinggleButton.configuration?.background.backgroundColor = .white
            }
        }
    }
    
    var foodDataArray: [Food] = []
    
    var allFoodNameDictionary: [String: [String]] = [:]
    
    var swipeCellIndexPath: IndexPath?
    
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
            collectionView.topAnchor.constraint(equalTo: filterScorllView.bottomAnchor, constant: 20),
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
            cell.tooltipDelegate = self
            cell.isSwipeDeleting = false
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
        dataSingleScannerViewController.view.addSubview(catchSinggleButtonBorderUIView)
        dataSingleScannerViewController.view.addSubview(catchSinggleLabel)
        catchSinggleButtonBorderUIView.addSubview(catchSinggleButton)
    }
    
    private func configureConstratints() {
        filterScorllView.translatesAutoresizingMaskIntoConstraints = false
        filterScorllView.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        NSLayoutConstraint.activate([
            filterScorllView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterScorllView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            filterScorllView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        catchSinggleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleLabel.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleLabel.bottomAnchor.constraint(equalTo: catchSinggleButtonBorderUIView.topAnchor, constant: -11),
        ])
        
        catchSinggleButtonBorderUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleButtonBorderUIView.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleButtonBorderUIView.bottomAnchor.constraint(equalTo: dataSingleScannerViewController.view.bottomAnchor, constant: -66),
            catchSinggleButtonBorderUIView.widthAnchor.constraint(equalToConstant: 80),
            catchSinggleButtonBorderUIView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        catchSinggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catchSinggleButton.centerXAnchor.constraint(equalTo: dataSingleScannerViewController.view.centerXAnchor),
            catchSinggleButton.bottomAnchor.constraint(equalTo: catchSinggleButtonBorderUIView.bottomAnchor, constant: -4.21),
            catchSinggleButton.widthAnchor.constraint(equalToConstant: 71.58),
            catchSinggleButton.heightAnchor.constraint(equalToConstant: 71.58)
        ])
        
        singleScanButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            singleScanButton.bottomAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.bottomAnchor, constant: -30),
            singleScanButton.trailingAnchor.constraint(equalTo: collectionView.layoutMarginsGuide.trailingAnchor, constant: -30),
            singleScanButton.heightAnchor.constraint(equalToConstant: 70),
            singleScanButton.widthAnchor.constraint(equalToConstant: 70)
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
                collectionView.initialUIView.isHidden = true
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
        UIView.animate(withDuration: 0.2, animations: {
            self.catchSinggleLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1, animations: {
                self.catchSinggleLabel.alpha = 0.4
            }, completion: { isSucceced in
                
            })
        })
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
            if foodDataArray.isEmpty {
                collectionView.initialImageView.image = UIImage(named: "Alertfrok")
                var paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.19
                collectionView.initialLabel.attributedText = NSMutableAttributedString(string: "스캔정보가 없네요!\n다시 한 번 스캔해주세요", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
                collectionView.initialLabel.textAlignment = .center
            }
        }
        dataSingleScannerViewController.dismiss(animated: true)
        dataSingleScannerViewController.stopScanning()
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

extension ViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        self.swipeCellIndexPath = indexPath
        let cell = collectionView.cellForItem(at: indexPath) as? FoodCell
        cell?.isSwipeDeleting = true
        let deleteAction = SwipeAction(style: .destructive , title: nil) { action, indexPath in
            // handle action by updating model with deletion
            self.foodDataArray.remove(at: indexPath.item)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Food>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.foodDataArray)
            self.dataSource?.apply(snapshot, animatingDifferences: true)
            let initialView = collectionView as? FoodCollectionView
            initialView?.initialUIView.isHidden = self.foodDataArray.isEmpty ? false : true
            if self.foodDataArray.isEmpty {
                self.collectionView.initialImageView.image = UIImage(named: "NoData")
                var paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.33
                self.collectionView.initialLabel.attributedText = NSMutableAttributedString(string: "아래 버튼을 눌러 메뉴를 스캔해요", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
                self.collectionView.initialLabel.textAlignment = .center
            }
        }
        // customize the action appearance
        let deleteImageWithColor = UIImage(systemName: "trash.fill")?.withTintColor(UIColor(hexString: "#F3645B"), renderingMode: .alwaysOriginal)
        deleteAction.transitionDelegate = self
        deleteAction.image = deleteImageWithColor
        deleteAction.backgroundColor = UIColor(hexString: "#FFE6E3")
        return [deleteAction]
    }
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        return options
    }
}

var swipeOffsetForRecognizedText: [String:CGFloat] = [:]
var TooltipViewForRecognizedText: [String:ToolTipView] = [:]
var isAnimating = false

extension ViewController: SwipeActionTransitioning {
    func didTransition(with context: SwipeActionTransitioningContext) {
        guard let swipeCellIndexPath else {return}
        guard let cell = collectionView.cellForItem(at: swipeCellIndexPath) as? FoodCell else {return}
        if context.newPercentVisible == 0 {
            cell.isSwipeDeleting = false
        }
        let recognizedText = cell.food!.recognizedText
        swipeOffsetForRecognizedText[recognizedText] = cell.swipeOffset
        guard let toolTipView = TooltipViewForRecognizedText[recognizedText] else {return}
        if isAnimating {
            return
        }
        isAnimating = true
        toolTipView.layer.removeAllAnimations()
        toolTipView.alpha = toolTipView.alpha
        UIView.animate(withDuration: 0.01, animations: {
            toolTipView.alpha = toolTipView.tooltipAlpha
        }, completion: { _ in
        UIView.animate(withDuration: 0.5 ,animations: {
                toolTipView.alpha = 0
            }, completion: { _ in
                TooltipViewForRecognizedText.removeValue(forKey: recognizedText)
                swipeOffsetForRecognizedText.removeValue(forKey: recognizedText)
                isAnimating = false
            })
        })
    }
}

extension ViewController: EnableDisplayToolTipView {
    func displayToolTip(centerX: NSLayoutXAxisAnchor, topAnchor: NSLayoutYAxisAnchor, recognizedText: String) {
        if TooltipViewForRecognizedText.contains(where: {$0.key == recognizedText}){
           return
        }
        let toolTipView = ToolTipView(frame: .zero, message: recognizedText)
        self.collectionView.addSubview(toolTipView)
        toolTipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolTipView.bottomAnchor.constraint(equalTo: topAnchor, constant: -toolTipView.tooltipBottomPadding + toolTipView.pointerHeight),
            toolTipView.centerXAnchor.constraint(equalTo: centerX),
            toolTipView.heightAnchor.constraint(equalToConstant: toolTipView.labelHeight + toolTipView.pointerHeight),
            toolTipView.widthAnchor.constraint(equalToConstant: toolTipView.labelWidth)
        ])
        toolTipView.alpha = 0
        TooltipViewForRecognizedText[recognizedText] = toolTipView

        UIView.animate(withDuration: 0.2, animations: {
            toolTipView.alpha = toolTipView.tooltipAlpha
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 3, animations: {
                toolTipView.alpha = 0
            }, completion: { isSucceced in
                if isSucceced {
                    toolTipView.removeFromSuperview()
                    TooltipViewForRecognizedText.removeValue(forKey: recognizedText)
                    swipeOffsetForRecognizedText.removeValue(forKey: recognizedText)
                }
            })
        })
    }
}
