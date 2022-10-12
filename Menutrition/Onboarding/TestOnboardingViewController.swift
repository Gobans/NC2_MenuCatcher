//
//  TestOnboardingViewController.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/12.
//

import UIKit

class TestOnboardingViewController: UIViewController {
    
    lazy var vc1: UIViewController = {
           let vc = OnboardingOne()
           vc.view.backgroundColor = .red

           return vc
       }()

       lazy var vc2: UIViewController = {
           let vc = OnboardingTwo()
           vc.view.backgroundColor = .green

           return vc
       }()

       lazy var vc3: UIViewController = {
           let vc = OnboardingThree()
           vc.view.backgroundColor = .blue

           return vc
       }()
       
       lazy var dataViewControllers: [UIViewController] = {
           return [vc1, vc2, vc3]
       }()
        lazy var pageViewController: UIPageViewController = {
            let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

            return vc
        }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    func setupConstraints() {
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 210),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }
}
