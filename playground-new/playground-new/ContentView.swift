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

                // Toggle button - moved to bottom for easier tapping
                VStack {
                    Spacer()
                    HStack {
                        Button(action: { showTuning.toggle() }) {
                            Text(showTuning ? "Performance Test" : "Tuning Mode")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 30)
                        Spacer()
                    }
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

// MARK: - Heart Shape and Glow

struct HeartStaticView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Heart glow (background)
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
                        endRadius: size.width * 0.2
                    )
                )
                .frame(width: size.width * 0.4, height: size.height * 0.2)
                .blur(radius: 20)
                .position(x: size.width * 0.5, y: size.height * 0.5)

            // Subtle heart hint (two lobes with visible dip between)
            ZStack {
                // Left lobe
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.3, y: 0.4),
                            startRadius: 0,
                            endRadius: size.width * 0.08
                        )
                    )
                    .frame(width: size.width * 0.16, height: size.height * 0.128)
                    .blur(radius: 10)
                    .offset(x: -size.width * 0.035, y: -size.height * 0.015)

                // Right lobe
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.7, y: 0.4),
                            startRadius: 0,
                            endRadius: size.width * 0.08
                        )
                    )
                    .frame(width: size.width * 0.16, height: size.height * 0.128)
                    .blur(radius: 10)
                    .offset(x: size.width * 0.035, y: -size.height * 0.015)
            }
            .position(x: size.width * 0.5, y: size.height * 0.5)

            // Heart center - PULSING SHARP LIGHT
            HeartCenterPulsingView(size: size)
                .position(x: size.width * 0.5, y: size.height * 0.5)
        }
    }
}

// MARK: - Pulsing Heart Center
// Animates between "Sharp" (dull) and "Max Bright" (peak)

struct HeartCenterPulsingView: View {
    let size: CGSize
    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 2.5) // 2.5 second cycle
            let progress = CGFloat(cycle / 2.5) // 0 to 1

            ZStack {
                // Outer glow layer (soft)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 1.0, green: 250/255, blue: 240/255).opacity(0.8), location: 0),
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.4), location: 0.5),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.06
                        )
                    )
                    .frame(width: size.width * 0.12, height: size.height * 0.06)
                    .blur(radius: interpolate(dull: 8, bright: 15, progress: progress))

                // Core light (SHARP - minimal blur)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white, location: 0),
                                .init(color: Color.white, location: 0.4),
                                .init(color: Color(red: 1.0, green: 250/255, blue: 240/255), location: 0.7),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.04
                        )
                    )
                    .frame(
                        width: size.width * interpolate(dull: 0.08, bright: 0.15, progress: progress),
                        height: size.height * interpolate(dull: 0.04, bright: 0.075, progress: progress)
                    )
                    .blur(radius: interpolate(dull: 1, bright: 5, progress: progress))
                    .brightness(interpolate(dull: 0.2, bright: 0.5, progress: progress))

                // Bright center spot (NO blur - pure white point)
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: size.width * interpolate(dull: 0.03, bright: 0.05, progress: progress),
                        height: size.height * interpolate(dull: 0.015, bright: 0.025, progress: progress)
                    )
                    .shadow(color: Color.white, radius: interpolate(dull: 15, bright: 25, progress: progress), x: 0, y: 0)
                    .shadow(color: Color.white, radius: interpolate(dull: 8, bright: 15, progress: progress), x: 0, y: 0)
                    .blendMode(.plusLighter)
            }
        }
    }

    // Interpolate between dull and bright values based on pulse progress
    func interpolate(dull: CGFloat, bright: CGFloat, progress: CGFloat) -> CGFloat {
        // Create a pulse curve: 0 -> peak at 10% -> back to 0
        let pulseIntensity: CGFloat
        if progress < 0.1 {
            // Rising to peak (0% to 10%)
            pulseIntensity = progress / 0.1
        } else {
            // Falling from peak (10% to 100%)
            pulseIntensity = 1.0 - ((progress - 0.1) / 0.9)
        }

        return dull + (bright - dull) * pulseIntensity
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
    @State private var outerBlur: Double = 8
    @State private var coreBlur: Double = 1
    @State private var brightness: Double = 0.2
    @State private var coreSize: Double = 0.08
    @State private var spotSize: Double = 0.03
    @State private var useBlendMode: Bool = true

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

                    // Heart center - SHARP LIGHT (3-layer)
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(red: 1.0, green: 250/255, blue: 240/255).opacity(0.8), location: 0),
                                        .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.4), location: 0.5),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 30)
                            .blur(radius: outerBlur)

                        // Sharp core
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white, location: 0),
                                        .init(color: Color.white, location: 0.4),
                                        .init(color: Color(red: 1.0, green: 250/255, blue: 240/255), location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: coreSize * 500, height: coreSize * 250)
                            .blur(radius: coreBlur)
                            .brightness(brightness)

                        // Bright spot (NO blur - pure white)
                        Circle()
                            .fill(Color.white)
                            .frame(width: spotSize * 500, height: spotSize * 250)
                            .shadow(color: Color.white, radius: 15)
                            .shadow(color: Color.white, radius: 8)
                            .blendMode(useBlendMode ? .plusLighter : .normal)
                    }
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
                            Text("Outer Blur: \(String(format: "%.1f", outerBlur))")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Slider(value: $outerBlur, in: 0...15)
                        }

                        HStack {
                            Text("Core Blur: \(String(format: "%.1f", coreBlur))")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Slider(value: $coreBlur, in: 0...5)
                        }

                        HStack {
                            Text("Brightness: \(String(format: "%.2f", brightness))")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Slider(value: $brightness, in: 0...0.5)
                        }

                        HStack {
                            Text("Core Size: \(String(format: "%.2f", coreSize))")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Slider(value: $coreSize, in: 0.04...0.15)
                        }

                        HStack {
                            Text("Spot Size: \(String(format: "%.2f", spotSize))")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Slider(value: $spotSize, in: 0.005...0.05)
                        }

                        HStack {
                            Text("Blend Mode")
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .leading)
                                .font(.caption)
                            Toggle("", isOn: $useBlendMode)
                                .labelsHidden()
                            Text(useBlendMode ? "Bright" : "Normal")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                    }

                    // Presets
                    Text("Presets:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button("Fairy ✨") {
                                outerBlur = 8
                                coreBlur = 0.5
                                brightness = 0.25
                                coreSize = 0.06
                                spotSize = 0.025
                                useBlendMode = true
                            }
                            .buttonStyle(.bordered)
                            .tint(.yellow)

                            Button("Sharp 💎") {
                                outerBlur = 8
                                coreBlur = 1
                                brightness = 0.2
                                coreSize = 0.08
                                spotSize = 0.03
                                useBlendMode = true
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)

                            Button("Star ⭐") {
                                outerBlur = 10
                                coreBlur = 0
                                brightness = 0.3
                                coreSize = 0.05
                                spotSize = 0.02
                                useBlendMode = true
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)

                            Button("Soft 🌙") {
                                outerBlur = 12
                                coreBlur = 3
                                brightness = 0.1
                                coreSize = 0.1
                                spotSize = 0.035
                                useBlendMode = false
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)

                            Button("CSS Match") {
                                outerBlur = 8
                                coreBlur = 2
                                brightness = 0.15
                                coreSize = 0.08
                                spotSize = 0.025
                                useBlendMode = false
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                    }

                    // Code output
                    Text("Copy these values:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("""
                    outerBlur: \(String(format: "%.1f", outerBlur))
                    coreBlur: \(String(format: "%.1f", coreBlur))
                    brightness: \(String(format: "%.2f", brightness))
                    coreSize: \(String(format: "%.2f", coreSize))
                    spotSize: \(String(format: "%.3f", spotSize))
                    blendMode: \(useBlendMode ? ".plusLighter" : ".normal")
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
