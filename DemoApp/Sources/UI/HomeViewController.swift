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
    
    lazy var safeArea: UILayoutGuide = view.safeAreaLayoutGuide

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        for demoItem in DemoShaders.allCases {
            let button = PreviewButton(text: String(describing: demoItem), onClick: { [weak self] in
                self?.navigationController?.pushViewController(ShadeDemoViewController(shader: demoItem.shader), animated: true)
            })
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: kButtonHeight)
            ])
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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
