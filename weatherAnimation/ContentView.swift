//
//  ContentView.swift
//  weatherAnimation
//
//  Created by Alex & Diora on 20/04/26.
//

import SceneKit
import SwiftUI

struct SceneKitView: View {
    var scene: SCNScene {
        let scene = SCNScene(named: "demo.dae")!

        scene.rootNode.childNodes.forEach {
            $0.scale = SCNVector3(0.5, 0.5, 0.5)
        }

        return scene
    }

    var body: some View {
        SceneView(
            scene: scene,
            options: [.autoenablesDefaultLighting]
        )
    }
}



enum WeatherCondition {
    case clear
    case rain
    case clouds
}


// Main View
struct ContentView: View {
    @State private var condition: WeatherCondition = .clear

    var body: some View {
        ZStack {
            WeatherAnimationView(condition: condition)

            VStack {
                Spacer()

                HStack {
                    Button("Clear") { condition = .clear }
                    Button("Clouds") { condition = .clouds }
                    Button("Rain") { condition = .rain }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 40)
            }
        }
    }
}

// Animation Container
struct WeatherAnimationView: View {
    let condition: WeatherCondition

    var body: some View {
        ZStack {
            SkyLayer(condition: condition)
            WeatherEffectLayer(condition: condition)
            CharacterLayer(condition: condition)
            
        }
        .animation(.easeInOut(duration: 0.5), value: condition)
    }
}

//  Sky
struct SkyLayer: View {
    let condition: WeatherCondition

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var colors: [Color] {
        switch condition {
        case .clear:
            return [.blue.opacity(0.8), .cyan]
        case .clouds:
            return [.gray.opacity(0.7), .blue]
        case .rain:
            return [.gray, .black]
        }
    }
}

// Weather Effects
struct WeatherEffectLayer: View {
    let condition: WeatherCondition

    var body: some View {
        switch condition {
        case .clear:
            SunView()
        case .clouds:
            CloudsView()
        case .rain:
            RainView()
        }
    }
}

//  Sun
struct SunView: View {
    @State private var rotate = false

    var body: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotate = true
                }
            }
            .position(x: 300, y: 80)
    }
}

// Clouds
struct CloudsView: View {
    @State private var move = false

    var body: some View {
        
        HStack {
            ForEach(0..<3) { i in
                Cloud()
                    .offset(x: move ? 200 : -200)
                    .animation(
                        .linear(duration: Double(10 + i * 2))
                        .repeatForever(autoreverses: false),
                        value: move
                    )
            }
        }
        .onAppear { move = true }
    }
}

struct Cloud: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.8))
            .frame(width: 100, height: 60)
            .padding(10)
    }
}

//  Rain
struct RainView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<60) { i in
                RainDrop()
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: -200...geo.size.height)
                    )
            }
        }
    }
}

struct RainDrop: View {
    @State private var fall = false

    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: 10)
            .offset(y: fall ? 400 : -200)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 0.5...1.2))
                    .repeatForever(autoreverses: false)
                ) {
                    fall = true
                }
            }
    }
}

// Character
struct CharacterLayer: View {
    let condition: WeatherCondition

    var body: some View {
        Image(characterImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 240, height: 240)
            .offset(y: 100)
            .transition(.scale)
    }

    var characterImageName: String {
        switch condition {
        case .clear:
            return "sun"
        case .clouds:
            return "cold"
        case .rain:
            return "rain"
        }
    }
}

#Preview {
    ContentView()
}
