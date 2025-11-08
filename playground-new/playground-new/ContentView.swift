//
//  ContentView.swift
//  playground-new
//
//  Created by ananta on 11/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showTuning = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showTuning {
                    HeartCenterTuningView(size: geometry.size)
                } else {
                    HeartChakraTestView(size: geometry.size)
                }

                // Toggle button
                VStack {
                    HStack {
                        Button(action: { showTuning.toggle() }) {
                            Text(showTuning ? "Performance Test" : "Tuning Mode")
                                .font(.caption)
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Performance Test View
// This tests the 3 most expensive elements to verify iOS can handle the blur load

struct HeartChakraTestView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Background gradient
            BackgroundGradientView()

            // Flow band with heavy blur (39px) - PERFORMANCE CRITICAL
            FlowBandView(size: size)

            // Diagonal mist with rotation and 50px blur - PERFORMANCE CRITICAL
            DiagonalMistView(size: size)

            // Pulse echo - expanding ring
            PulseEchoView(size: size)

            // Heart (static for now)
            HeartStaticView(size: size)

            // FPS Counter
            FPSCounterView()
                .position(x: size.width - 50, y: 50)
        }
    }
}

// MARK: - Background Gradient

struct BackgroundGradientView: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 35/255, green: 18/255, blue: 55/255),
                Color(red: 5/255, green: 2/255, blue: 15/255)
            ]),
            center: UnitPoint(x: 0.4, y: 0.45),
            startRadius: 0,
            endRadius: 500
        )
        .ignoresSafeArea()
    }
}

// MARK: - Flow Band (PERFORMANCE TEST)
// This is the most expensive element - horizontal gradient with 39px blur moving across screen

struct FlowBandView: View {
    let size: CGSize
    @State private var offset: CGFloat = -1.0

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.clear, location: 0),
                .init(color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.28), location: 0.5),
                .init(color: Color.clear, location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: size.width, height: size.height * 0.16)
        .blur(radius: 39) // HEAVY BLUR - this is the test
        .offset(x: size.width * offset, y: size.height * 0.22)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 48)
                    .repeatForever(autoreverses: false)
            ) {
                offset = 2.0
            }
        }
    }
}

// MARK: - Diagonal Mist (PERFORMANCE TEST)
// 50px blur with rotation - very expensive

struct DiagonalMistView: View {
    let size: CGSize
    @State private var rotation: Double = -15
    @State private var opacity: Double = 0.25

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.25), location: 0),
                .init(color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.2), location: 0.6),
                .init(color: Color.clear, location: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: size.width * 0.8, height: size.height * 0.7)
        .blur(radius: 50) // HEAVIEST BLUR - this is the real test
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .position(x: size.width * 0.4, y: size.height * 0.55)
        .onAppear {
            // Rotation animation
            withAnimation(
                Animation.linear(duration: 45)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 345 // -15 + 360
            }

            // Opacity animation
            withAnimation(
                Animation.easeInOut(duration: 14)
                    .repeatForever(autoreverses: true)
            ) {
                opacity = 0.35
            }
        }
    }
}

// MARK: - Pulse Echo (Red-Leaning Variant)

struct PulseEchoView: View {
    let size: CGSize
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.clear, location: 0),
                        .init(color: Color.clear, location: 0.32),
                        .init(color: Color(red: 230/255, green: 50/255, blue: 140/255).opacity(0.9), location: 0.4),
                        .init(color: Color(red: 210/255, green: 40/255, blue: 130/255).opacity(0.7), location: 0.46),
                        .init(color: Color.clear, location: 0.52)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.14
                )
            )
            .frame(width: size.width * 0.28, height: size.height * 0.14)
            .blur(radius: 2)
            .scaleEffect(0.6 + (animationProgress * 9.4))  // 0.6 to 10
            .opacity(calculateOpacity(progress: animationProgress))
            .position(x: size.width * 0.5, y: size.height * 0.5)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    animationProgress = 1.0
                }
            }
    }

    func calculateOpacity(progress: CGFloat) -> Double {
        if progress < 0.12 {
            // 0 to 12%: fade in to 0.6
            return Double(progress / 0.12 * 0.6)
        } else {
            // 12% to 100%: fade out from 0.6 to 0
            return Double(0.6 * (1 - (progress - 0.12) / 0.88))
        }
    }
}

// MARK: - Heart (Static for now)

struct HeartStaticView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Heart glow
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.6), location: 0),
                            .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity( 0.4), location: 0.6),
                            .init(color: Color.clear, location: 0.9)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.2
                    )
                )
                .frame(width: size.width * 0.4, height: size.height * 0.2)
                .blur(radius: 20)
                .position(x: size.width * 0.5, y: size.height * 0.5)

            // Heart center - ENHANCED for crispness
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white, location: 0),
                            .init(color: Color.white, location: 0.3),  // More white core
                            .init(color: Color(red: 1.0, green: 250/255, blue: 240/255), location: 0.6),
                            .init(color: Color(red: 1.0, green: 230/255, blue: 120/255), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.06
                    )
                )
                .frame(width: size.width * 0.12, height: size.height * 0.06)
                .blur(radius: 3)  // Reduced from 4 for more crispness
                .shadow(color: Color(red: 1.0, green: 250/255, blue: 240/255).opacity(0.9), radius: 35)
                .shadow(color: Color.white, radius: 15)  // Extra bright core glow
                .brightness(0.1)  // Slight brightness boost
                .position(x: size.width * 0.5, y: size.height * 0.5)
        }
    }
}

// MARK: - FPS Counter
// This will show real-time FPS so you can see performance

struct FPSCounterView: View {
    @State private var fps: Double = 60
    @State private var lastUpdate = Date()
    @State private var frameCount = 0

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(Int(fps)) FPS")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(fpsColor)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)

            Text(performanceLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(fpsColor)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
        }
        .onAppear {
            startFPSCounter()
        }
    }

    var fpsColor: Color {
        if fps >= 55 {
            return .green
        } else if fps >= 40 {
            return .yellow
        } else {
            return .red
        }
    }

    var performanceLabel: String {
        if fps >= 55 {
            return "EXCELLENT"
        } else if fps >= 40 {
            return "GOOD"
        } else if fps >= 25 {
            return "POOR"
        } else {
            return "UNPLAYABLE"
        }
    }

    func startFPSCounter() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            frameCount += 1
            let now = Date()
            let elapsed = now.timeIntervalSince(lastUpdate)

            if elapsed >= 1.0 {
                fps = Double(frameCount) / elapsed
                frameCount = 0
                lastUpdate = now
            }
        }
    }
}

// MARK: - Tuning View
// Interactive tuning to match CSS exactly

struct HeartCenterTuningView: View {
    let size: CGSize
    @State private var blurRadius: Double = 3
    @State private var brightness: Double = 0.1
    @State private var whiteStop: Double = 0.3
    @State private var saturation: Double = 1.0

    var body: some View {
        ZStack {
            // Background
            Color(red: 5/255, green: 2/255, blue: 15/255).ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Preview
                ZStack {
                    // Heart glow
                    Ellipse()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.6), location: 0),
                                    .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.4), location: 0.6),
                                    .init(color: Color.clear, location: 0.9)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 100)
                        .blur(radius: 20)

                    // Heart center - TUNABLE
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white, location: 0),
                                    .init(color: Color.white, location: whiteStop),
                                    .init(color: Color(red: 1.0, green: 250/255, blue: 240/255), location: 0.6),
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255), location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 30)
                        .blur(radius: blurRadius)
                        .shadow(color: Color(red: 1.0, green: 250/255, blue: 240/255).opacity(0.9), radius: 35)
                        .shadow(color: Color.white, radius: 15)
                        .brightness(brightness)
                        .saturation(saturation)
                }
                .frame(height: 200)
                .padding(.top, 50)

                Spacer()

                // Controls
                VStack(alignment: .leading, spacing: 15) {
                    Text("Heart Center Tuning")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Blur: \(String(format: "%.1f", blurRadius))")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .leading)
                                .font(.caption)
                            Slider(value: $blurRadius, in: 0...8)
                        }

                        HStack {
                            Text("Bright: \(String(format: "%.2f", brightness))")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .leading)
                                .font(.caption)
                            Slider(value: $brightness, in: -0.2...0.5)
                        }

                        HStack {
                            Text("Core: \(String(format: "%.2f", whiteStop))")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .leading)
                                .font(.caption)
                            Slider(value: $whiteStop, in: 0...0.6)
                        }

                        HStack {
                            Text("Sat: \(String(format: "%.2f", saturation))")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .leading)
                                .font(.caption)
                            Slider(value: $saturation, in: 0.5...1.5)
                        }
                    }

                    // Presets
                    Text("Presets:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button("CSS") {
                                blurRadius = 4
                                brightness = 0
                                whiteStop = 0.5
                                saturation = 1.0
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)

                            Button("Crisp") {
                                blurRadius = 3
                                brightness = 0.1
                                whiteStop = 0.3
                                saturation = 1.1
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)

                            Button("Extra Crisp") {
                                blurRadius = 2
                                brightness = 0.15
                                whiteStop = 0.2
                                saturation = 1.2
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)

                            Button("Soft") {
                                blurRadius = 6
                                brightness = 0
                                whiteStop = 0.4
                                saturation = 0.9
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                        }
                    }

                    // Code output
                    Text("Copy these values:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("""
                    blur: \(String(format: "%.1f", blurRadius))
                    brightness: \(String(format: "%.2f", brightness))
                    whiteStop: \(String(format: "%.2f", whiteStop))
                    saturation: \(String(format: "%.2f", saturation))
                    """)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
