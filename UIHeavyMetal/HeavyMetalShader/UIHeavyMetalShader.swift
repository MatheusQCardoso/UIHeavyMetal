//
//  HeavyMetalShader.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

/**
 A value type responsible for encapsulating the raw Metal shader source code.
 */
public struct UIHeavyMetalShader {
    public let sourceCode: String
    
    init(raw sourceCode: String) {
        self.sourceCode = sourceCode
    }
}
