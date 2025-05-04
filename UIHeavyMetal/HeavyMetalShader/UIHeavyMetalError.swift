//
//  UIHeavyMetalError.swift
//  Pods
//
//  Created by Matheus Quirino Cardoso on 03/05/25.
//

public enum UIHeavyMetalError: Error, LocalizedError {
    case failedToInitializePipelineState(shaderSource: String)
    case shaderCompilationError(stackTrace: String)
}
