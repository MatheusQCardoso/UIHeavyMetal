//
//  UIHeavyMetalShaderView.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 26/04/25.
//

import UIKit
import Metal
import MetalKit

/**
 A UIView subclass that renders (Heavy)Metal shaders.
 */
public class UIHeavyMetalShaderView: UIView {
    
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var metalLayer: CAMetalLayer!
    private var pipelineState: MTLRenderPipelineState?
    private var shaderSource: String
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var uniformsBuffer: MTLBuffer!
    
    private var targetFPS: Int
    private var lastUpdateTime: CFTimeInterval = 0
    
    /**
         Initializes a new instance of UIHeavyMetalShaderView with an existing UIHeavyMetalShader.
         - Parameters:
           - shader: The shader object containing Metal source code.
           - targetFPS: Desired frame rate for rendering updates. Default is 24.
         */
    public init(shader: UIHeavyMetalShader, targetFPS: Int = 24) {
        self.shaderSource = shader.sourceCode
        self.targetFPS = targetFPS
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateDrawableSize()
        if window != nil && displayLink == nil {
            startDisplayLink()
        } else if window == nil {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateDrawableSize()
    }
    
    private func setup() {
        device = UIHeavyMetal.shared.device
        commandQueue = UIHeavyMetal.shared.commandQueue
        
        metalLayer = self.layer as? CAMetalLayer
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.contentsScale = UIScreen.main.scale
        
        createUniformBuffer()
        compileShader()
    }
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(redraw))
        displayLink?.preferredFramesPerSecond = targetFPS
        displayLink?.add(to: .main, forMode: .default)
    }
    
    private func updateDrawableSize() {
        metalLayer.drawableSize = bounds.size
    }
    
    private func createUniformBuffer() {
        let bufferSize = MemoryLayout<Uniforms>.size
        uniformsBuffer = device.makeBuffer(length: bufferSize, options: [])
    }
    
    private func compileShader() {
        let fullSource = UIHeavyMetalConstants.vertexShaderBaseSource + shaderSource
        
        do {
            let library = try device.makeLibrary(source: fullSource, options: nil)
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "pixel_main")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            if pipelineState == nil {
                throw UIHeavyMetalError.failedToInitializePipelineState(shaderSource: shaderSource)
            }
        } catch {
            if let heavyMetalError = error as? UIHeavyMetalError {
                UIHeavyMetal.log(ofType: .error, message: "\(error.localizedDescription)")
                UIHeavyMetal.error(heavyMetalError)
            } else {
                UIHeavyMetal.log(ofType: .error, message: "Compilation Error: `\(error.localizedDescription)`")
                UIHeavyMetal.error(.shaderCompilationError(stackTrace: error.localizedDescription))
            }
        }
    }
    
    @objc private func redraw() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - lastUpdateTime
        let targetInterval = 1.0 / Double(targetFPS)
        if elapsedTime >= targetInterval {
            guard let drawable = metalLayer.nextDrawable() else { return }
            
            updateUniforms()
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
            
            guard let pipelineState else { return }
            
            renderEncoder.setRenderPipelineState(pipelineState)
            
            renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 1)
            
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            lastUpdateTime = currentTime
        }
    }
    
    private func updateUniforms() {
        let elapsed = Float(CACurrentMediaTime() - startTime)
        let size = bounds.size
        var uniforms = Uniforms(time: elapsed, resolution: SIMD2<Float>(Float(size.width), Float(size.height)))
        
        memcpy(uniformsBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.size)
    }
}

fileprivate struct Uniforms {
    var time: Float
    var resolution: SIMD2<Float>
}
