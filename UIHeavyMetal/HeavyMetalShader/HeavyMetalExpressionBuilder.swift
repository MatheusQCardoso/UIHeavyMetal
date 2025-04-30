//
//  HeavyMetalExpressionBuilder.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

import Foundation

public class HeavyMetalExpressionBuilder {
    
    private let name: String
    private var preffixLines: [String] = []
    
    private var type: String?
    private var value: String?
    
    private init(name: String) {
        self.name = name
    }
    
    public static func named(_ name: String) -> HeavyMetalExpressionBuilder {
        return HeavyMetalExpressionBuilder(name: name)
    }
    
    func setType(_ type: String) {
        self.type = type
    }
    
    func buildAssignment() -> String {
        guard let value else {
            print("HeavyMetalExpressionBuilder: Invalid or null VALUE passed to variable '\(name)' definition.")
            return ""
        }
        return "\(name) = \(value);"
    }
    
    func build() -> String {
        guard let type else {
            print("HeavyMetalExpressionBuilder: Invalid or null TYPE passed to variable '\(name)'s definition.")
            return ""
        }
        guard let value else {
            print("HeavyMetalExpressionBuilder: Invalid or null VALUE passed to variable '\(type) \(name)' definition.")
            return ""
        }
        
        let preffix = preffixLines.joined(separator: "\n")
        return "\(preffix)\n\(type) \(name) = \(type)(\(value));"
    }

    private func generateMetalValidVariableName(length: Int = 8) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lettersAndDigits = letters + "0123456789_"
        
        guard length > 0 else { return "_" }
        
        let firstChar = letters.randomElement()!
        let remainingChars = (0..<(length - 1)).compactMap { _ in lettersAndDigits.randomElement() }
        
        return String(firstChar) + String(remainingChars)
    }
}

extension HeavyMetalExpressionBuilder {
    @discardableResult
    public func expression(_ expression: String) -> Self {
        self.value = expression
        return self
    }
    
    @discardableResult
    public func circle(at center: SIMD2<Float>, radius: Float, smoothEdge: Bool = true) -> Self {
        let smooth = smoothEdge ? "smoothstep" : "step"
        
        let preffixVarName = generateMetalValidVariableName()
        preffixLines.append(
            "float \(preffixVarName) = distance(uv, float2(\(center.x), \(center.y)));"
        )
        
        self.value = "\(smooth)(\(radius), \(radius) - 0.01, \(preffixVarName))"
        return self
    }
    
    @discardableResult
    public func waveX(frequency: Float = 10.0, speed: Float = 1.0) -> Self {
        self.value = "sin(uv.x * \(frequency) + time * \(speed))"
        return self
    }
    
    @discardableResult
    public func waveY(frequency: Float = 10.0, speed: Float = 1.0) -> Self {
        self.value = "sin(uv.y * \(frequency) + time * \(speed))"
        return self
    }
    
    @discardableResult
    public func noise2D(scale: Float = 10.0) -> Self {
        let preffixVarName = generateMetalValidVariableName()
        preffixLines.append(
            "float \(preffixVarName) = sin(dot(uv * \(scale), float2(12.9898,78.233))) * 43758.5453;"
        )
        
        self.value = "fract(\(preffixVarName))"
        return self
    }
}
