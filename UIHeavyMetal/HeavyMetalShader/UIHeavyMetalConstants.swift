//
//  UIHeavyMetalConstants.swift
//  Pods
//
//  Created by Matheus Quirino Cardoso on 03/05/25.
//

struct UIHeavyMetalConstants {
    static let vertexShaderBaseSource =
    """
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
