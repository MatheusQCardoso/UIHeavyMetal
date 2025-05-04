//
//  ShadeDemoViewController.swift
//  DemoApp
//
//  Created by Matheus Quirino Cardoso on 29/04/25.
//

import UIKit
import UIHeavyMetal

class ShadeDemoViewController: UIViewController {
    
    lazy var shaderView: UIHeavyMetalShaderView = {
        let shaderView = UIHeavyMetalShaderView(shader: self.shader)
        shaderView.translatesAutoresizingMaskIntoConstraints = false
        return shaderView
    }()
    
    let shader: UIHeavyMetalShader
    
    init(shader: UIHeavyMetalShader) {
        self.shader = shader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(shaderView)
        
        NSLayoutConstraint.activate([
            shaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shaderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            shaderView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
