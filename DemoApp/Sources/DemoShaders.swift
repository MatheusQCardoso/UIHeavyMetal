//
//  DemoShaders.swift
//  DemoApp
//
//  Created by Matheus Quirino Cardoso on 28/04/25.
//

import UIHeavyMetal

enum DemoShaders: CaseIterable {
    case goldenFlames
    case checkerboard
    case pulsatingRadial
    case electricGrid
    case tunnelWarp
    case hamsterWheel
    case oldTVStatic
    case parabolicWave
    case fractalBloom
    case approachingLight
    case spiralZoomOut
    
    var displayName: String {
        switch self {
        case .goldenFlames: "Golden Flames"
        case .checkerboard: "Checkerboard"
        case .pulsatingRadial: "Pulsating Radial"
        case .electricGrid: "Electric Grid"
        case .tunnelWarp: "Tunnel Warp"
        case .hamsterWheel: "Hamster Wheel"
        case .oldTVStatic: "Old Tube TV Static"
        case .parabolicWave: "Parabolic Wave"
        case .fractalBloom: "Fractal Bloom"
        case .approachingLight: "Approaching Light"
        case .spiralZoomOut: "Spiral Zoom Out"
        }
    }
    
    var shader: UIHeavyMetalShader {
        return switch self {
        case .goldenFlames:
            UIHeavyMetal.shaderBuilder()
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
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvs").expression("uv * float2(5.0, 10.0)"))
                .increment(.named("uvs").expression("time * 0.5"))
            
                .float(.named("checker").expression("step(0.5, fract(uvs.x)) + step(0.5, fract(uvs.y))"))
                .assign(.named("checker").expression("fmod(checker, 2.0)"))
            
                .float(.named("cv").expression("checker > 0.5 ? 1 : 0"))
                .build(float4expr: "cv, cv, cv, 1")
            
        case .pulsatingRadial:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("dist").expression("length(uvc)"))
                .float(.named("pulse").expression("sin(time * 5.0) * 0.5 + 0.5"))
                .float(.named("intensity").expression("smoothstep(0.2 + 0.1 * pulse, 0.0, dist)"))
                .build(float4expr: "intensity, intensity, intensity, 1.0")
        
        case .electricGrid:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvScaled").expression("uv * 20.0"))
                .float(.named("lineX").expression("step(0.02, fract(uvScaled.x))"))
                .float(.named("lineY").expression("step(0.02, fract(uvScaled.y))"))
                .float(.named("grid").expression("lineX * lineY"))
                
                .float(.named("glow").expression("sin(time * 10.0 + uv.x * 20.0) * 0.5 + 0.5"))
                .float(.named("intensity").expression("1.0 - grid * glow"))

                .float3(.named("color").expression("float3(0.0, 1.0, 1.0) * intensity"))
                .build(float4expr: "color, 1.0")

        case .tunnelWarp:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("angle").expression("atan2(uvc.y, uvc.x)"))
                .float(.named("radius").expression("length(uvc)"))

                .float(.named("warp").expression("sin(10.0 * radius - time * 5.0)"))
                .float(.named("shade").expression("0.5 + 0.5 * warp"))

                .float(.named("r").expression("0.5 + 0.5 * sin(angle + time)"))
                .float(.named("g").expression("0.5 + 0.5 * sin(angle + time + 2.0)"))
                .float(.named("b").expression("0.5 + 0.5 * sin(angle + time + 4.0)"))

                .build(float4expr: "shade * float3(r, g, b), 1.0")
            
        case .hamsterWheel:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("center").expression("float2(0.5, 0.5)"))
                .float2(.named("p").expression("uv - center"))
                .float(.named("r").expression("length(p) + 0.0001"))
                .float(.named("a").expression("atan2(p.y, p.x) + time * 1.0"))

                .float(.named("teeth").expression("16.0"))
                .float(.named("segment").expression("(a / (2.0 * 3.141592)) * teeth"))
                .float(.named("tooth").expression("step(0.5, fract(segment))"))

                .float(.named("outerRadius").expression("0.35"))
                .float(.named("innerRadius").expression("0.3"))
                .float(.named("gearMask").expression("smoothstep(outerRadius, outerRadius - 0.01, r) * tooth"))

                .float(.named("hub").expression("smoothstep(0.1, 0.08, r)"))

                .float3(.named("gearColor").expression("float3(0.7, 0.7, 0.75)"))
                .float3(.named("finalColor").expression("gearColor * gearMask"))

                .build(float4expr: "finalColor * (1.0 - hub), 1.0")

        case .oldTVStatic:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uv2").expression("uv"))
                .increment(.named("uv2.y").expression("sin(time * 20.0) * 0.01"))

                .float2(.named("noiseCoord").expression("uv2 * float2(320.0, 180.0)"))
                .float(.named("dotSeed").expression("dot(noiseCoord, float2(12.9898, 78.233))"))
                .float(.named("rawNoise").expression("sin(dotSeed) * 43758.5453 + time * 100.0"))
                .float(.named("staticNoise").expression("fract(rawNoise)"))

                .float(.named("scanline").expression("sin(uv2.y * 800.0) * 0.04 + 0.96"))

                .float(.named("intensity").expression("staticNoise * scanline"))
                .build(float4expr: "float3(intensity), 1.0")

            
        case .parabolicWave:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uv2").expression("uv - 0.5"))
                .float(.named("timeAdjusted").expression("time * 5.0"))
                .float(.named("waveFrequency").expression("10.0"))
                .float(.named("waveAmplitude").expression("0.3"))
                .float(.named("parabolaY").expression("sin(uv2.x * waveFrequency + timeAdjusted) * waveAmplitude"))
            
                .float(.named("lineHeight").expression("abs(uv2.y - parabolaY)"))
                .float(.named("threshold").expression("0.01"))
                .float(.named("isLine").expression("step(lineHeight, threshold)"))
                .float3(.named("color").expression("isLine > 0.5 ? float3(0.0, 1.0, 0.0) : float3(0.0, 0.0, 0.0)"))
                .build(float4expr: "color, 1.0")
            
        case .fractalBloom:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("angle").expression("atan2(uvc.y, uvc.x)"))
                .float(.named("radius").expression("length(uvc)"))
                .float(.named("frequency").expression("12.0"))
                .float(.named("fractal").expression("sin(frequency * angle + time * 2.0) * exp(-radius * 0.5)"))
                .float3(.named("baseColor").expression("float3(1.0, 0.4, 0.0)"))
                .float3(.named("finalColor").expression("baseColor * fract(fractal * 20.0)"))
                .build(float4expr: "finalColor, 1.0")

        case .approachingLight:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("dist").expression("length(uvc)"))
                .float(.named("noise").expression("fract(sin(uvc.x * 10.0 + time * 1.5) * 43758.5453)"))
                .float(.named("bubbleHeight").expression("sin(time * 4.0 + dist * 5.0) * 0.2 + noise * 0.1"))
                .float3(.named("lavaColor").expression("float3(1.0, 0.5, 0.0) * (1.0 - dist + bubbleHeight)"))
                .build(float4expr: "lavaColor, 1.0")
            
        case .spiralZoomOut:
            UIHeavyMetal.shaderBuilder()
                .float2(.named("uvc").expression("uv - 0.5"))
                .float(.named("angle").expression("atan2(uvc.y, uvc.x)"))
                .float(.named("radius").expression("length(uvc)"))
                .float(.named("speed").expression("time * 3.0"))
                .float(.named("twist").expression("angle + radius * speed"))
                .float(.named("brightness").expression("exp(-radius * 2.0)"))
                .float3(.named("color").expression("float3(1.0, 1.0, 1.0) * brightness * sin(twist)"))
                .build(float4expr: "color, 1.0")
        }
    }
}
