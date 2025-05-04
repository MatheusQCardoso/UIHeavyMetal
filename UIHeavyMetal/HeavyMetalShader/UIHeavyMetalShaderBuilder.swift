//
//  HeavyMetalShaderBuilder.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

import Foundation

/**
 A builde that facilitates creating complete UIHeavyMetal shaders using chained expressions.
 */
public class UIHeavyMetalShaderBuilder {
    private var bodyLines: [String] = []
    private var headers: [String] = []
    
    init() {}
}

// MARK: - PUBLIC

extension UIHeavyMetalShaderBuilder {
    
    //MARK: - Operations
    
    /**
     Adds raw shader code to the pixel shader body.
     - Parameter code: A raw string of shader code.
     - Returns: The builder instance.
     */
    @discardableResult
    public func code(_ code: String) -> Self {
        bodyLines.append(code)
        return self
    }
    
    /**
    Declares a new manually-typed variable inside of the shader function's body.
     - Parameter type: The type to attribute to the new variable declaration (case-sensitive).
     - Parameter expressionBuilder: The variable's naming and value builder.
     */
    @discardableResult
    public func declare(_ type: String, _ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        expressionBuilder.setType(type)
        code(expressionBuilder.build())
        return self
    }
    
    /**
     Assigns a new value to an **existing ** variable.
     */
    public func assign(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment())
        return self
    }
    
    /**
     Increments the value of an existing variable by the specified expression. **Equals to '+='**
     */
    public func increment(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment(type: "+"))
        return self
    }
    
    /**
     Decrements the value of an existing variable by the specified expression. **Equals to '-='**
     */
    public func decrement(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        code(expressionBuilder.buildAssignment(type: "-"))
        return self
    }
    
    /**
     Allows the addition of any code **BEFORE** the shader function's declaration.
     Ex.: 'include' and 'using namespace' statements, and even custom structure declarations.
     */
    public func header(_ code: String) -> Self {
        headers.append(code)
        return self
    }
    
    /**
     Adds a float declaration to the shader code from an expression builder.
     */
    public func float(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        declare("float", expressionBuilder)
        return self
    }
    /**
     Adds a float2 declaration to the shader code from an expression builder.
     */
    public func float2(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        declare("float2", expressionBuilder)
        return self
    }
    
    /**
     Adds a float3 declaration to the shader code from an expression builder.
     */
    public func float3(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        declare("float3", expressionBuilder)
        return self
    }
    
    /**
     Adds a float4 declaration to the shader code from an expression builder.
     */
    public func float4(_ expressionBuilder: UIHeavyMetalExpressionBuilder) -> Self {
        declare("float4", expressionBuilder)
        return self
    }
}

extension UIHeavyMetalShaderBuilder {
    
    // MARK: - String Builders
    
    /**
     Finalizes the shader and returns a UIHeavyMetalShader from a float4 string expression.
     - Parameter float4expr: The string expression returning a float4 color.
     - Returns: A complete `UIHeavyMetalShader` object.
     */
    public func build(float4expr: String) -> UIHeavyMetalShader {
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
        
        let shaderScript = shaderParts.joined(separator: "\n\n")
        UIHeavyMetal.log(ofType: .debug, message: "BUILT PIXEL SHADER FUNCTION: `\(shaderScript)`")
        return UIHeavyMetalShader(raw: shaderScript)
    }
    
    /**
     Finalizes the shader using an expression builder returning a float4.
     - Parameter float4: The expression builder.
     - Returns: A complete `UIHeavyMetalShader` object.
     */
    public func build(float4: UIHeavyMetalExpressionBuilder) -> UIHeavyMetalShader {
        return build(float4expr: float4.build())
    }
    
}
