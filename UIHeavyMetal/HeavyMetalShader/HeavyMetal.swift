//
//  HeavyMetal.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

import Metal

public class HeavyMetal {
    static let shared = HeavyMetal()
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    private init() {
        if device == nil {
            device = MTLCreateSystemDefaultDevice()
        }
        if commandQueue == nil {
            commandQueue = device.makeCommandQueue()
        }
    }
    
    public static func shaderBuilder() -> HeavyMetalShaderBuilder {
        return HeavyMetalShaderBuilder()
    }
    
    public static func shaderFrom(rawSource: String) -> HeavyMetalShader {
        return HeavyMetalShader(raw: rawSource)
    }
}
