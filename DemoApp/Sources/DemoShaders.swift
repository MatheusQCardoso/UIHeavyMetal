//
//  DemoShaders.swift
//  DemoApp
//
//  Created by Matheus Quirino Cardoso on 28/04/25.
//

import UIHeavyMetal

enum DemoShaders: CaseIterable {
    case nebula
    case goldenFlames
    case checkerboard
    case pulsatingRadial
    case scrollingWaves
    
    var shader: HeavyMetalShader {
        return switch self {
        case .nebula:
            HeavyMetal.shaderBuilder()
                .float2(.named("uvi").expression("uv * 2.0 - 1.0"))
                .float(.named("t").expression("time * 0.5"))
            
                .float(.named("v1").expression("sin(uv.x * 10.0 + t)"))
                .float(.named("v2").expression("sin(uv.y * 10.0 + t)"))
                .float(.named("v3").expression("sin((uv.x + uv.y) * 10.0 + t)"))
                .float(.named("v").expression("v1 + v2 + v3"))
                .assign(.named("v").expression("v / 3.0"))
            
                .float(.named("c1").expression("0.5 + 0.5 * sin(3.0 * v + t)"))
                .float(.named("c2").expression("0.5 + 0.5 * sin(3.0 * v + t + 2.0)"))
                .float(.named("c3").expression("0.5 + 0.5 * sin(3.0 * v + t + 4.0)"))
                .float3(.named("color").expression("c1, c2, c3"))
            
                .build(float4expr: "color, 1.0")
            
        case .goldenFlames:
            HeavyMetal.shaderBuilder()
                .float2(.named("uv2").expression("uv"))
                .increment(.named("uv2.y").expression("time * 0.3"))
                .increment(.named("uv2.x").expression("sin(uv2.y * 18.0 + time * 5.0) * 0.05"))

                .float(.named("noiseX").expression("sin((uv2.x + time * 0.5) * 10.0)"))
                .float(.named("noiseY").expression("sin((uv2.y + time * 0.3) * 20.0)"))
                .float(.named("n").expression("noiseX * noiseY"))

                .float(.named("flameMask").expression("smoothstep(1.1, 0.0, uv.y + n * 0.3)"))

                .float3(.named("bottomColor").expression("float3(1.0, 0.2, 0.0)"))
                .float3(.named("middleColor").expression("float3(1.0, 0.8, 0.0)"))
                .float3(.named("topColor").expression("float3(1.0, 1.0, 1.0)"))

                .float3(.named("warmColor").expression("mix(bottomColor, middleColor, uv.y)"))
                .float(.named("tipIntensity").expression("pow(flameMask, 8.0)"))
                .float3(.named("finalColor").expression("mix(warmColor, topColor, tipIntensity)"))

                .build(float4expr: "finalColor * flameMask, flameMask")


            
        case .checkerboard:
            HeavyMetal.shaderBuilder()
                .float2(.named("uvs").expression("uv * float2(5.0, 10.0)"))
                .increment(.named("uvs").expression("time * 0.5"))
            
                .float(.named("checker").expression("step(0.5, fract(uvs.x)) + step(0.5, fract(uvs.y))"))
                .assign(.named("checker").expression("fmod(checker, 2.0)"))
            
                .float(.named("cv").expression("checker > 0.5 ? 1 : 0"))
                .build(float4expr: "cv, cv, cv, 1")
            
        case .pulsatingRadial:
            HeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("dist").expression("length(uvc)"))
                .float(.named("pulse").expression("sin(time * 5.0) * 0.5 + 0.5"))
                .float(.named("intensity").expression("smoothstep(0.2 + 0.1 * pulse, 0.0, dist)"))
                .build(float4expr: "intensity, intensity, intensity, 1.0")
            
        case .scrollingWaves:
            HeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv * 0.5"))
                .float(.named("dist").expression("length(uvc) * 50.0"))
                .float(.named("rings").expression("sin(dist - time * 5.0)"))
            
                .float(.named("c1").expression("0.5 + 0.5 * sin(rings + 0.0)"))
                .float(.named("c2").expression("0.5 + 0.5 * sin(rings + 2.0)"))
                .float(.named("c3").expression("0.5 + 0.5 * sin(rings + 4.0)"))
            
                .build(float4expr: "c1, c2, c3, 1")
            
        }
    }
}
