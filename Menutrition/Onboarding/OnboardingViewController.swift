//
//  OnboardingViewController.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/12.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor(hexString: "#CFCFCF")
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.preferredIndicatorImage = UIImage(named: "PageIndicator")
        return pageControl
    }()
    var currentIndex: Int? {
        willSet(newValue) {
            if newValue == onboardingViewControllers.count - 1 {
                nextButton.setImage(nil, for: .normal)
                nextButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
                nextButton.setTitle("시작하기", for: .normal)
                isLastOnboardingPage = true
            }
            else {
                let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
                let arrowImage = UIImage(systemName: "arrow.forward", withConfiguration: imageConfiguration)
                nextButton.setImage(arrowImage, for: .normal)
                nextButton.setTitle("", for: .normal)
                isLastOnboardingPage = false
            }
        }
    }
    var pendingIndex: Int?
    var isLastOnboardingPage = false
    private let onboardingOne = OnboardingOne()
    private let onboardingTwo = OnboardingTwo()
    private let onboardingThree = OnboardingThree()
    private let onboardingFour = OnboardingFour()
    
    lazy var onboardingViewControllers: [UIViewController] = {
        return [onboardingOne, onboardingTwo, onboardingThree, onboardingFour]
    }()
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
        let arrowImage = UIImage(systemName: "arrow.forward", withConfiguration: imageConfiguration)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        setupConstraints()
        if let firstVC = onboardingViewControllers.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        setupDelegate()
    }
    
    @objc func nextButtonClicked() {
        if isLastOnboardingPage {
            navigationController?.popViewController(animated: true)
            UserDefaults.standard.isUserSeenOnboarding = true
        } else {
            if currentIndex == nil {
                currentIndex = 0
            }
            if pendingIndex == nil {
                pendingIndex = 0
            }
            if onboardingViewControllers.count > currentIndex ?? 0 {
                self.pageViewController.goToNextPage()
                currentIndex! += 1
                pendingIndex! += 1
                pageControl.currentPage = currentIndex!
            }
        }
    }
    
    func setupConstraints() {
        view.addSubview(pageViewController.view)
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -110),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -60),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor)
        ])
    }
    
    private func setupDelegate() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return onboardingViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == onboardingViewControllers.count {
            return nil
        }
        return onboardingViewControllers[nextIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = onboardingViewControllers.firstIndex(of: pendingViewControllers.first!)
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
}
