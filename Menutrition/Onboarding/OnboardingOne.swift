//
//  OnboardingOne.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/12.
//

import UIKit

final class OnboardingOne: UIViewController {
    
    private let onboardingImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Onboarding1")
        imageView.image = image
        return imageView
    }()
    
    private let onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        label.numberOfLines = 4
        label.text = "식당에서 메뉴판을 스캔하여\n영양정보를 확인하세요!"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    func setupConstraints() {
        view.addSubview(onboardingImageView)
        onboardingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            onboardingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            onboardingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        view.addSubview(onboardingLabel)
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            onboardingLabel.topAnchor.constraint(equalTo: onboardingImageView.bottomAnchor),
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
    }
}
