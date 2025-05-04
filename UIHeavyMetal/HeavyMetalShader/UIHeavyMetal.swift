//
//  UIHeavyMetal.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 27/04/25.
//

import os
import Metal

/**
 Entry point for working with UIHeavyMetal shaders and global configuration options.
 */
public class UIHeavyMetal {
    /* MARK: PUBLIC API - */
    
    /**
     Starts building a new shader using a fluent builder interface.
     - Returns: An instance of `UIHeavyMetalShaderBuilder`.
     */
    public static func shaderBuilder() -> UIHeavyMetalShaderBuilder {
        UIHeavyMetalShaderBuilder()
    }

//  TODO: ADD SUPPORT FOR DIFFERENT PIXEL_MAIN CUSTOM DEFINITIONS
//    /**
//     Creates a shader instance from a raw Metal source code string.
//     - Parameter rawSource: Metal source code as a string.
//     - Returns: A `UIHeavyMetalShader` instance wrapping the code.
//     */
//    public static func shaderFrom(rawSource: String) -> UIHeavyMetalShader {
//        UIHeavyMetalShader(raw: rawSource)
//    }
    
    /**
     Retrieves the last error encountered within UIHeavyMetal's ecosystem.
     - Returns: A `UIHeavyMetalError` if one has been logged, otherwise nil.
     */
    public static func getLastError() -> UIHeavyMetalError? {
        shared.lastError
    }
    
    /**
     Sets a global error handler closure to receive future errors.
     - Parameter handler: A closure to be invoked when an error occurs.
     */
    public static func setErrorHandler(handler: @escaping (UIHeavyMetalError) -> Void) {
        shared.userDefinedErrorHandler = handler
    }
    
    /**
     Sets the logging level for shader system messages.
     - Parameter level: The desired log level.
     */
    public static func setLogLevel(to level: UIHeavyMetalLogLevel) {
        shared.logLevel = level
    }
        
    /* MARK: - INTERNAL */
    
   public enum UIHeavyMetalLogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case all = 4
        
        var name: String {
            switch self {
            case .debug: "DEBUG"
            case .info: "INFO"
            case .warning: "WARNING"
            case .error: "ERROR"
            case .all: ""
            }
        }
    }
    
    static let shared = UIHeavyMetal()
    
    let logger: Logger = .init(subsystem: "quirino.matheus.uiheavymetal", category: "uiheavymetal")
    var logLevel: UIHeavyMetalLogLevel = .warning
    
    var lastError: UIHeavyMetalError? = nil
    var userDefinedErrorHandler: ((UIHeavyMetalError) -> Void)? = nil
    
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
    
    static func log(ofType type: UIHeavyMetalLogLevel, message: String) {
        guard shared.logLevel.rawValue >= type.rawValue else { return }
        print("UIHeavyMetal | \(type.name) | \(message)")
    }
    
    static func error(_ err: UIHeavyMetalError) {
        shared.lastError = err
        shared.userDefinedErrorHandler?(err)
    }
}
