//
//  HomeViewController.swift
//  DemoApp
//
//  Created by Matheus Quirino Cardoso on 29/04/25.
//

import UIKit
import UIHeavyMetal

class HomeViewController: UIViewController {
    
    let kButtonHeight: CGFloat = 40
    let kStackViewSpacing: CGFloat = 20
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var topTitle: UILabel = {
        let view = UILabel()
        view.text = "UIHeavyMetal"
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 32, weight: .bold)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.alwaysBounceHorizontal = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = kStackViewSpacing
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var footerText: UILabel = {
        let view = UILabel()
        view.text = "by Matheus Quirino (MatheusQCardoso)\non LinkedIn and GitHub"
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 14, weight: .bold)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var safeArea: UILayoutGuide = view.safeAreaLayoutGuide

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(topView)
        topView.addSubview(topTitle)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(bottomView)
        bottomView.addSubview(footerText)
        
        for demoItem in DemoShaders.allCases.shuffled() {
            let button = PreviewButton(text: demoItem.displayName, onClick: { [weak self] in
                self?.navigationController?.pushViewController(ShadeDemoViewController(shader: demoItem.shader), animated: true)
            })
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: kButtonHeight)
            ])
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topView.heightAnchor.constraint(equalToConstant: 160.0),
            
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 60.0),
            
            scrollView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            topTitle.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            topTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            topTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -8),
            
            footerText.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            footerText.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            footerText.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: +8)
        ])
    }
    
    
    
    class PreviewButton: UIButton {
        
        let onClick: () -> Void
        
        init(text: String, onClick: @escaping () -> Void) {
            self.onClick = onClick
            super.init(frame: .zero)
            
            self.clipsToBounds = true
            self.layer.cornerRadius = 20
            self.backgroundColor = .blue
            self.setTitleColor(.white, for: .normal)
            self.setTitle(text, for: .normal)
            
            self.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func didTap() {
            onClick()
        }
    }
}
