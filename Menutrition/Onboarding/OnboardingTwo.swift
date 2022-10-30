//
//  OnboardingTwo.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/12.
//

import UIKit

final class OnboardingTwo: UIViewController {
    
    private let onboardingImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Onboarding2")
        imageView.image = image
        return imageView
    }()
    
    private let onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        label.numberOfLines = 4
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.25
        label.attributedText = NSMutableAttributedString(string: "혹시 같은 메뉴가 없다면\n비슷한 음식의 영양정보를 찾아드려요!", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.textAlignment = .left
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
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
