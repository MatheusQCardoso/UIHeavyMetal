//
//  HeavyMetalShaderView.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 26/04/25.
//

import UIKit
import Metal
import MetalKit

public class HeavyMetalShaderView: UIView {
    
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var metalLayer: CAMetalLayer!
    private var pipelineState: MTLRenderPipelineState!
    private var shaderSource: String
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var uniformsBuffer: MTLBuffer!
    
    private var targetFPS: Int
    private var lastUpdateTime: CFTimeInterval = 0
    
    public init(shader: HeavyMetalShader, targetFPS: Int = 24) {
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
        device = HeavyMetal.shared.device
        commandQueue = HeavyMetal.shared.commandQueue
        
        metalLayer = self.layer as? CAMetalLayer
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.contentsScale = UIScreen.main.scale
        
        createUniformBuffer()
        loadShader()
    }
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(redraw))
        
        // Set display link frame rate based on target FPS
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
    
    private func loadShader() {
        let fullSource = HeavyMetalShaderView.vertexShaderSource + shaderSource
        
        do {
            let library = try device.makeLibrary(source: fullSource, options: nil)
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "pixel_main")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to compile Metal shader: \(error)")
        }
    }
    
    @objc private func redraw() {
        // Calculate elapsed time since last update
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - lastUpdateTime
        
        // Only update based on the desired FPS
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
            
            renderEncoder.setRenderPipelineState(pipelineState)
            
            renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 1)
            
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            // Update the last time we drew
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

private struct Uniforms {
    var time: Float
    var resolution: SIMD2<Float>
}

extension HeavyMetalShaderView {
    static let vertexShaderSource = """
    using namespace metal;
    #include <metal_stdlib>

    struct VertexOut {
        float4 position [[position]];
        float2 uv;
    };

    struct Uniforms {
        float time;
        float2 resolution;
    };

    vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                                  constant Uniforms &uniforms [[buffer(1)]]) {
        float2 positions[3] = {
            float2(-1.0, -1.0),
            float2( 3.0, -1.0),
            float2(-1.0,  3.0)
        };
        
        VertexOut out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.uv = (positions[vertexID] + 1.0) * 0.5;
        return out;
    }
    """
}
