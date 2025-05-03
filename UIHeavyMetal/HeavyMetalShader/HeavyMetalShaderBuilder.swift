//
//  HeavyMetalShaderBuilder.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

import Foundation

public class HeavyMetalShaderBuilder {
    private var bodyLines: [String] = []
    private var headers: [String] = []
    
    init() {}
    
    @discardableResult
    public func code(_ code: String) -> Self {
        bodyLines.append(code)
        return self
    }
    @discardableResult
    public func declare(_ type: String, _ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        expressionBuilder.setType(type)
        code(expressionBuilder.build())
        return self
    }
    public func assign(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment())
        return self
    }
    public func increment(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment(type: "+"))
        return self
    }
    public func decrement(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment(type: "-"))
        return self
    }
    public func header(_ code: String) -> Self {
        headers.append(code)
        return self
    }
    public func float(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        declare("float", expressionBuilder)
        return self
    }
    public func float2(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        declare("float2", expressionBuilder)
        return self
    }
    public func float3(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        declare("float3", expressionBuilder)
        return self
    }
    public func float4(_ expressionBuilder: HeavyMetalExpressionBuilder) -> Self {
        declare("float4", expressionBuilder)
        return self
    }
    
    public func build(float4expr: String) -> HeavyMetalShader {
        var shaderParts: [String] = []
        
        if !headers.isEmpty {
            shaderParts.append(headers.joined(separator: "\n"))
        }
        
        shaderParts.append("""
        fragment float4 pixel_main(VertexOut in [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(1)]])
        {
            float2 uv = in.uv;
            float time = uniforms.time;
            float2 resolution = uniforms.resolution;
        """)
        
        shaderParts.append(bodyLines.joined(separator: "\n"))
        shaderParts.append("return float4(\(float4expr));")
        shaderParts.append("}") // close pixel_main
        
        print("@>> SHADER SCRIPT: \(shaderParts.joined(separator: "\n\n"))")
        return HeavyMetalShader(raw: shaderParts.joined(separator: "\n\n"))
    }
    
    public func build(float4: HeavyMetalExpressionBuilder) -> HeavyMetalShader {
        return build(float4expr: float4.build())
    }
}
