//
//  ContentView.swift
//  playground-new
//
//  Created by ananta on 11/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isPlaying = true  // Animation starts playing
    @State private var isDarkMode = true  // Dark mode by default

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HeartChakraTestView(size: geometry.size, isPlaying: $isPlaying, isDarkMode: $isDarkMode)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)

                // Light/dark mode toggle in top-right corner
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { isDarkMode.toggle() }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 160/255, green: 87/255, blue: 136/255)) // #a05788
                                .padding(20)
                        }
                    }
                    .padding(.top, 40)  // Move down into safe area
                    Spacer()
                }

                // Play/pause button centered in bottom 20%
                VStack {
                    Spacer()
                    Button(action: { isPlaying.toggle() }) {
                        ZStack {
                            // Transparent halo
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 70, height: 70)
                                .blur(radius: 8)

                            // Icon in app color
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 160/255, green: 87/255, blue: 136/255)) // #a05788
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.1)  // Center in bottom 20%
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Performance Test View
// This tests the 3 most expensive elements to verify iOS can handle the blur load

struct HeartChakraTestView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    @Binding var isDarkMode: Bool
    @State private var sceneOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            BackgroundGradientView(isDarkMode: isDarkMode)

            // All 4 flow bands with individual timing (always loop)
            FlowBandsView(size: size, isDarkMode: isDarkMode)

            // Diagonal mist with rotation and 50px blur (always loop)
            DiagonalMistView(size: size, isDarkMode: isDarkMode)

            // 3 Floating particles (always loop)
            ParticlesView(size: size, isDarkMode: isDarkMode)

            // Pulse echo - expanding ring (controlled by play/pause)
            PulseEchoView(size: size, isPlaying: $isPlaying, isDarkMode: isDarkMode)

            // Heart (controlled by play/pause)
            HeartStaticView(size: size, isPlaying: $isPlaying, isDarkMode: isDarkMode)
                .drawingGroup()
        }
        .opacity(sceneOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 2.0)) {
                sceneOpacity = 1.0
            }
        }
    }
}

// MARK: - Background Gradient

struct BackgroundGradientView: View {
    let isDarkMode: Bool

    var body: some View {
        if isDarkMode {
            // Dark mode: current purple gradient
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
        } else {
            // Light mode: warm beige
            Color(red: 245/255, green: 235/255, blue: 225/255) // #F5EBE1
                .ignoresSafeArea()
        }
    }
}

// MARK: - Flow Bands (All 4)

struct FlowBandsView: View {
    let size: CGSize
    let isDarkMode: Bool

    var body: some View {
        ZStack {
            // Flow-1: Top, teal/coral, drifts right
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.192),
                topPosition: 0.22,
                height: 0.06,
                blur: 45,
                duration: 72,
                delay: 15,
                direction: .right,
                colorCycleDuration: 192,
                colorCycleType: .teal1,
                isDarkMode: isDarkMode
            )

            // Flow-2: Upper middle, teal/golden, drifts right
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.151),
                topPosition: 0.35,
                height: 0.0525,
                blur: 50,
                duration: 56,
                delay: 35,
                direction: .right,
                colorCycleDuration: 148,
                colorCycleType: .teal2,
                isDarkMode: isDarkMode
            )

            // Flow-3: Lower middle, indigo/rose, drifts left (FIRST)
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.209),
                bottomPosition: 0.40,
                height: 0.135,
                blur: 45,
                duration: 81,
                delay: 0,
                direction: .left,
                colorCycleDuration: 108,
                colorCycleType: .magenta1,
                isDarkMode: isDarkMode
            )

            // Flow-4: Bottom, indigo/lavender, drifts left
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.166),
                bottomPosition: 0.53,
                height: 0.1125,
                blur: 52,
                duration: 62,
                delay: 27,
                direction: .left,
                colorCycleDuration: 82,
                colorCycleType: .magenta2,
                isDarkMode: isDarkMode
            )
        }
    }
}

enum FlowDirection {
    case left, right
}

enum FlowBandColorCycle {
    case teal1, teal2, magenta1, magenta2
}

struct FlowBand: View {
    let size: CGSize
    let color: Color
    var topPosition: CGFloat? = nil
    var bottomPosition: CGFloat? = nil
    let height: CGFloat
    let blur: CGFloat
    let duration: Double
    let delay: Double
    let direction: FlowDirection
    let colorCycleDuration: Double
    let colorCycleType: FlowBandColorCycle
    let isDarkMode: Bool

    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let adjustedTime = max(0, elapsed - delay)
            let progress = adjustedTime.truncatingRemainder(dividingBy: duration) / duration

            let offset: CGFloat = direction == .right ?
                -1.0 + (progress * 3.0) :  // Right: -1 to 2
                1.0 - (progress * 3.0)     // Left: 1 to -2

            // Vertical wobble - subtle up/down movement
            let wobbleOffset: CGFloat = {
                let keyframes: [(progress: Double, offset: CGFloat)] = [
                    (0.0, 0.0),
                    (0.07, -0.01),
                    (0.28, 0.01),
                    (0.52, -0.01),
                    (0.73, 0.01),
                    (1.0, 0.0)
                ]

                for i in 0..<(keyframes.count - 1) {
                    let current = keyframes[i]
                    let next = keyframes[i + 1]
                    if progress >= current.progress && progress < next.progress {
                        let segmentProgress = (progress - current.progress) / (next.progress - current.progress)
                        return current.offset + (next.offset - current.offset) * segmentProgress
                    }
                }
                return 0.0
            }()

            let opacity: Double = {
                if elapsed < delay {
                    return 0
                } else if progress < 0.05 {
                    return progress / 0.05
                } else if progress > 0.75 {
                    return 1.0 - ((progress - 0.75) / 0.25)
                } else {
                    return 1.0
                }
            }()

            // Color cycling
            let colorCycleProgress = elapsed.truncatingRemainder(dividingBy: colorCycleDuration) / colorCycleDuration
            let currentColor = getCycledFlowBandColor(baseColor: color, cycleType: colorCycleType, progress: colorCycleProgress)

            let baseY = topPosition != nil ? size.height * topPosition! : -(size.height * bottomPosition!)
            let finalY = baseY + (size.height * wobbleOffset)

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0),
                    .init(color: currentColor, location: 0.35),
                    .init(color: Color.clear, location: 0.65)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: size.width, height: size.height * height)
            .blur(radius: blur)
            .opacity(opacity)
            .offset(
                x: size.width * offset,
                y: finalY
            )
        }
    }

    func getCycledFlowBandColor(baseColor: Color, cycleType: FlowBandColorCycle, progress: Double) -> Color {
        let baseOpacity = UIColor(baseColor).cgColor.components?[3] ?? 0.2

        if isDarkMode {
            // Dark mode: cosmic purple/teal
            switch cycleType {
            case .teal1, .teal2:
                // Teal bands cycle through teal/cyan variants
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateFlowColor(
                        from: Color(red: 100/255, green: 220/255, blue: 220/255),
                        to: Color(red: 80/255, green: 240/255, blue: 240/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateFlowColor(
                        from: Color(red: 80/255, green: 240/255, blue: 240/255),
                        to: Color(red: 100/255, green: 220/255, blue: 220/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .magenta1, .magenta2:
                // Magenta bands cycle through indigo/magenta/orange
                if progress < 0.4 {
                    let t = progress / 0.4
                    return interpolateFlowColor(
                        from: Color(red: 100/255, green: 100/255, blue: 240/255),
                        to: Color(red: 150/255, green: 90/255, blue: 220/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else if progress < 0.6 {
                    let t = (progress - 0.4) / 0.2
                    return interpolateFlowColor(
                        from: Color(red: 150/255, green: 90/255, blue: 220/255),
                        to: Color(red: 255/255, green: 140/255, blue: 60/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.6) / 0.4
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 140/255, blue: 60/255),
                        to: Color(red: 100/255, green: 100/255, blue: 240/255),
                        progress: t
                    ).opacity(baseOpacity)
                }
            }
        } else {
            // Light mode: sunrise golden hour
            switch cycleType {
            case .teal1:
                // Peachy coral to warm honey
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 182/255, blue: 158/255), // #FFB69E peachy coral
                        to: Color(red: 255/255, green: 200/255, blue: 112/255), // #FFC870 golden honey
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 200/255, blue: 112/255),
                        to: Color(red: 255/255, green: 182/255, blue: 158/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .teal2:
                // Golden honey to soft peach
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 216/255, blue: 156/255), // #FFD89C warm honey
                        to: Color(red: 255/255, green: 167/255, blue: 133/255), // #FFA785 soft peach
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 167/255, blue: 133/255),
                        to: Color(red: 255/255, green: 216/255, blue: 156/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .magenta1:
                // Delicate rose cycling
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 179/255, blue: 186/255), // #FFB3BA soft rose
                        to: Color(red: 255/255, green: 157/255, blue: 166/255), // #FF9DA6 deeper rose
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateFlowColor(
                        from: Color(red: 255/255, green: 157/255, blue: 166/255),
                        to: Color(red: 255/255, green: 179/255, blue: 186/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .magenta2:
                // Lavender mist cycling
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateFlowColor(
                        from: Color(red: 230/255, green: 213/255, blue: 245/255), // #E6D5F5 lavender mist
                        to: Color(red: 212/255, green: 191/255, blue: 232/255), // #D4BFE8 deeper lavender
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateFlowColor(
                        from: Color(red: 212/255, green: 191/255, blue: 232/255),
                        to: Color(red: 230/255, green: 213/255, blue: 245/255),
                        progress: t
                    ).opacity(baseOpacity)
                }
            }
        }
    }

    func interpolateFlowColor(from: Color, to: Color, progress: Double) -> Color {
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress

        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Particles (All 3)

struct ParticlesView: View {
    let size: CGSize
    let isDarkMode: Bool

    var body: some View {
        ZStack {
            // Particle 1: Teal/Gold with color cycling
            Particle(
                size: size,
                color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.55),
                bottomPosition: 0.35,
                leftPosition: 0.12,
                width: 0.10,
                height: 0.05,
                driftDuration: 12,
                driftDelay: 0,
                twinkleDuration: 5,
                twinkleDelay: 0,
                colorCycleDuration: 192,
                colorCycleType: .teal,
                isDarkMode: isDarkMode
            )

            // Particle 2: Yellow/Peachy (no color cycling in dark, sparkly gold in light)
            Particle(
                size: size,
                color: Color(red: 255/255, green: 200/255, blue: 80/255).opacity(0.55),
                bottomPosition: 0.40,
                leftPosition: 0.18,
                width: 0.09,
                height: 0.045,
                driftDuration: 14,
                driftDelay: 3,
                twinkleDuration: 4.5,
                twinkleDelay: 1,
                colorCycleDuration: nil,
                colorCycleType: nil,
                isDarkMode: isDarkMode
            )

            // Particle 3: Indigo/Amber with color cycling
            Particle(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.55),
                bottomPosition: 0.45,
                leftPosition: 0.25,
                width: 0.11,
                height: 0.055,
                driftDuration: 13,
                driftDelay: 6,
                twinkleDuration: 5.5,
                twinkleDelay: 2,
                colorCycleDuration: 104,
                colorCycleType: .magenta,
                isDarkMode: isDarkMode
            )
        }
    }
}

enum ParticleColorCycle {
    case teal, magenta
}

struct Particle: View {
    let size: CGSize
    let color: Color
    let bottomPosition: CGFloat
    let leftPosition: CGFloat
    let width: CGFloat
    let height: CGFloat
    let driftDuration: Double
    let driftDelay: Double
    let twinkleDuration: Double
    let twinkleDelay: Double
    let colorCycleDuration: Double?
    let colorCycleType: ParticleColorCycle?
    let isDarkMode: Bool

    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)

            // Drift animation (diagonal up-right: 0,0 -> 80%, -180%)
            let driftElapsed = max(0, elapsed - driftDelay)
            let driftProgress = driftElapsed.truncatingRemainder(dividingBy: driftDuration) / driftDuration
            let xOffset = size.width * width * 0.8 * driftProgress
            let yOffset = -size.height * height * 1.8 * driftProgress

            // Particle fade (0.2 -> 0.8 -> 0.7 -> 0)
            let fadeOpacity: Double = {
                if elapsed < driftDelay {
                    return 0
                }
                if driftProgress < 0.3 {
                    return 0.2 + (0.6 * (driftProgress / 0.3))
                } else if driftProgress < 0.7 {
                    return 0.8 - (0.1 * ((driftProgress - 0.3) / 0.4))
                } else {
                    return 0.7 * (1.0 - ((driftProgress - 0.7) / 0.3))
                }
            }()

            // Twinkle animation (0.3 -> 0.65 -> 0.3) - reduced peak intensity
            let twinkleElapsed = max(0, elapsed - twinkleDelay)
            let twinkleProgress = twinkleElapsed.truncatingRemainder(dividingBy: twinkleDuration) / twinkleDuration
            let twinkleOpacity: Double = {
                if elapsed < twinkleDelay {
                    return 0.3
                }
                if twinkleProgress < 0.5 {
                    return 0.3 + (0.35 * (twinkleProgress / 0.5))
                } else {
                    return 0.65 - (0.35 * ((twinkleProgress - 0.5) / 0.5))
                }
            }()

            // Combined opacity
            let finalOpacity = fadeOpacity * twinkleOpacity

            // Color cycling
            let currentColor: Color = {
                if let duration = colorCycleDuration, let cycleType = colorCycleType {
                    let cycleProgress = elapsed.truncatingRemainder(dividingBy: duration) / duration
                    return getCycledColor(baseColor: color, cycleType: cycleType, progress: cycleProgress)
                } else {
                    return color
                }
            }()

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: currentColor, location: 0),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * width * 0.5
                    )
                )
                .frame(width: size.width * width, height: size.height * height)
                .blur(radius: 10)
                .opacity(finalOpacity)
                .offset(x: xOffset, y: yOffset)
                .position(
                    x: size.width * leftPosition,
                    y: size.height * (1 - bottomPosition)
                )
        }
    }

    func getCycledColor(baseColor: Color, cycleType: ParticleColorCycle, progress: Double) -> Color {
        let baseOpacity = 0.55

        if isDarkMode {
            // Dark mode: teal/magenta/orange
            switch cycleType {
            case .teal:
                // Teal particle cycles through teal variants
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateParticleColor(
                        from: Color(red: 100/255, green: 220/255, blue: 220/255),
                        to: Color(red: 80/255, green: 240/255, blue: 240/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateParticleColor(
                        from: Color(red: 80/255, green: 240/255, blue: 240/255),
                        to: Color(red: 100/255, green: 220/255, blue: 220/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .magenta:
                // Magenta particle cycles through indigo/magenta/orange
                if progress < 0.33 {
                    let t = progress / 0.33
                    return interpolateParticleColor(
                        from: Color(red: 100/255, green: 100/255, blue: 240/255),
                        to: Color(red: 200/255, green: 80/255, blue: 200/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else if progress < 0.66 {
                    let t = (progress - 0.33) / 0.33
                    return interpolateParticleColor(
                        from: Color(red: 200/255, green: 80/255, blue: 200/255),
                        to: Color(red: 255/255, green: 140/255, blue: 60/255),
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.66) / 0.34
                    return interpolateParticleColor(
                        from: Color(red: 255/255, green: 140/255, blue: 60/255),
                        to: Color(red: 100/255, green: 100/255, blue: 240/255),
                        progress: t
                    ).opacity(baseOpacity)
                }
            }
        } else {
            // Light mode: golden/peachy sparkles
            switch cycleType {
            case .teal:
                // Sparkly gold cycling
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateParticleColor(
                        from: Color(red: 255/255, green: 215/255, blue: 0/255), // #FFD700 sparkly gold
                        to: Color(red: 255/255, green: 195/255, blue: 77/255), // Warm golden
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateParticleColor(
                        from: Color(red: 255/255, green: 195/255, blue: 77/255),
                        to: Color(red: 255/255, green: 215/255, blue: 0/255),
                        progress: t
                    ).opacity(baseOpacity)
                }

            case .magenta:
                // Warm amber cycling
                if progress < 0.5 {
                    let t = progress * 2
                    return interpolateParticleColor(
                        from: Color(red: 255/255, green: 191/255, blue: 105/255), // #FFBF69 warm amber
                        to: Color(red: 255/255, green: 179/255, blue: 193/255), // #FFB3C1 soft peachy pink
                        progress: t
                    ).opacity(baseOpacity)
                } else {
                    let t = (progress - 0.5) * 2
                    return interpolateParticleColor(
                        from: Color(red: 255/255, green: 179/255, blue: 193/255),
                        to: Color(red: 255/255, green: 191/255, blue: 105/255),
                        progress: t
                    ).opacity(baseOpacity)
                }
            }
        }
    }

    func interpolateParticleColor(from: Color, to: Color, progress: Double) -> Color {
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress

        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Diagonal Mist
// 50px blur with rotation and color cycling

struct DiagonalMistView: View {
    let size: CGSize
    let isDarkMode: Bool
    @State private var rotation: Double = -15
    @State private var opacity: Double = 0.20
    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let colorCycle = elapsed.truncatingRemainder(dividingBy: 135) / 135

            let colors = getColors(progress: colorCycle)

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: colors.0, location: 0),
                    .init(color: colors.1, location: 0.6),
                    .init(color: Color.clear, location: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: size.width * 0.8, height: size.height * 0.7)
            .blur(radius: 40)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: size.width * 0.4, y: size.height * 0.55)
        }
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
                opacity = 0.28
            }
        }
    }

    func getColors(progress: Double) -> (Color, Color) {
        if isDarkMode {
            // Dark mode: teal/indigo cosmic mist
            if progress < 0.3 {
                return (
                    Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.25),
                    Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.2)
                )
            } else if progress < 0.5 {
                let t = (progress - 0.3) / 0.2
                let color1 = interpolateColor(
                    from: Color(red: 100/255, green: 220/255, blue: 220/255),
                    to: Color(red: 80/255, green: 120/255, blue: 255/255),
                    progress: t
                ).opacity(0.25)
                let color2 = interpolateColor(
                    from: Color(red: 100/255, green: 100/255, blue: 240/255),
                    to: Color(red: 255/255, green: 150/255, blue: 80/255),
                    progress: t
                ).opacity(0.2)
                return (color1, color2)
            } else if progress < 0.7 {
                let t = (progress - 0.5) / 0.2
                let color1 = interpolateColor(
                    from: Color(red: 80/255, green: 120/255, blue: 255/255),
                    to: Color(red: 80/255, green: 230/255, blue: 240/255),
                    progress: t
                ).opacity(0.25)
                let color2 = interpolateColor(
                    from: Color(red: 255/255, green: 150/255, blue: 80/255),
                    to: Color(red: 100/255, green: 100/255, blue: 240/255),
                    progress: t
                ).opacity(0.2)
                return (color1, color2)
            } else {
                let t = (progress - 0.7) / 0.3
                let color1 = interpolateColor(
                    from: Color(red: 80/255, green: 230/255, blue: 240/255),
                    to: Color(red: 100/255, green: 220/255, blue: 220/255),
                    progress: t
                ).opacity(0.25)
                let color2 = Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.2)
                return (color1, color2)
            }
        } else {
            // Light mode: golden hour mist - warm peachy/golden/rose
            if progress < 0.3 {
                return (
                    Color(red: 255/255, green: 200/255, blue: 150/255).opacity(0.25), // Warm golden
                    Color(red: 255/255, green: 179/255, blue: 186/255).opacity(0.2)   // Soft rose
                )
            } else if progress < 0.5 {
                let t = (progress - 0.3) / 0.2
                let color1 = interpolateColor(
                    from: Color(red: 255/255, green: 200/255, blue: 150/255),
                    to: Color(red: 255/255, green: 215/255, blue: 0/255),
                    progress: t
                ).opacity(0.25)
                let color2 = interpolateColor(
                    from: Color(red: 255/255, green: 179/255, blue: 186/255),
                    to: Color(red: 255/255, green: 191/255, blue: 105/255),
                    progress: t
                ).opacity(0.2)
                return (color1, color2)
            } else if progress < 0.7 {
                let t = (progress - 0.5) / 0.2
                let color1 = interpolateColor(
                    from: Color(red: 255/255, green: 215/255, blue: 0/255),
                    to: Color(red: 255/255, green: 182/255, blue: 158/255),
                    progress: t
                ).opacity(0.25)
                let color2 = interpolateColor(
                    from: Color(red: 255/255, green: 191/255, blue: 105/255),
                    to: Color(red: 230/255, green: 213/255, blue: 245/255),
                    progress: t
                ).opacity(0.2)
                return (color1, color2)
            } else {
                let t = (progress - 0.7) / 0.3
                let color1 = interpolateColor(
                    from: Color(red: 255/255, green: 182/255, blue: 158/255),
                    to: Color(red: 255/255, green: 200/255, blue: 150/255),
                    progress: t
                ).opacity(0.25)
                let color2 = Color(red: 255/255, green: 179/255, blue: 186/255).opacity(0.2)
                return (color1, color2)
            }
        }
    }

    func interpolateColor(from: Color, to: Color, progress: Double) -> Color {
        // Simple RGB interpolation (not perfect but works for our case)
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress

        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Pulse Echo (Red-Leaning Variant)

struct PulseEchoView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let isDarkMode: Bool
    @State private var startTime = Date()
    @State private var shouldAnimate = true

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
            let overallProgress = CGFloat(cycle / 3.5)

            // Delay ring start until heart reaches peak brightness (10% of cycle)
            // Map 10%-100% of overall cycle to 0%-100% of ring expansion
            let ringDelay: CGFloat = 0.1
            let progress = (overallProgress - ringDelay) / (1.0 - ringDelay)

            // Determine if we should show the ring
            let shouldShowRing = shouldAnimate && overallProgress >= ringDelay && progress < 0.6

            if shouldShowRing {
                // Apply easing to expansion - fast at first (matching pulse), then slow down
                let easedProgress = easeOutCubic(progress)

                // Calculate heart's current pulse scale to make ring "breathe" with it
                let heartPulseScale = calculateHeartPulseScale(overallProgress: overallProgress)

                // Interpolate colors from heart (yellow-pink) to magenta as ring expands
                let ringColors = getRingColors(progress: progress)

                // Base expansion scale (1.15 to 6)
                let baseScale = 1.15 + (easedProgress * 4.85)

                // Apply heart pulse breathing on top of base expansion
                let finalScale = baseScale * heartPulseScale

                Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.clear, location: 0.32),
                            .init(color: ringColors.0.opacity(0.9), location: 0.4),
                            .init(color: ringColors.1.opacity(0.7), location: 0.46),
                            .init(color: Color.clear, location: 0.52)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.14
                    )
                )
                .frame(width: size.width * 0.28, height: size.height * 0.14)
                .blur(radius: 4)  // Softer than original but still distinct
                .scaleEffect(finalScale)
                .opacity(calculateOpacity(progress: progress))
                .position(x: size.width * 0.5, y: size.height * 0.3)
            }
        }
        .onChange(of: isPlaying) {
            if isPlaying {
                // Reset timer and restart animation when play is pressed
                startTime = Date()
                shouldAnimate = true
            }
            // When paused: let current cycle complete, stop at beginning of next cycle
        }
        .task(id: isPlaying) {
            if !isPlaying && shouldAnimate {
                // Wait for cycle to complete (check every 50ms)
                while !isPlaying && shouldAnimate {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    let elapsed = Date().timeIntervalSince(startTime)
                    let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
                    let progress = cycle / 3.5
                    if progress < 0.05 {
                        // We're at the start of a new cycle, stop now
                        shouldAnimate = false
                        break
                    }
                }
            }
        }
    }

    // Ease-out cubic: fast start, slow end (matches heart pulse energy then decelerates)
    func easeOutCubic(_ t: CGFloat) -> CGFloat {
        let p = 1 - t
        return 1 - (p * p * p)
    }

    // Calculate the heart's pulse scale at the current moment
    // Same timing as HeartStaticView pulse
    func calculateHeartPulseScale(overallProgress: CGFloat) -> CGFloat {
        if overallProgress < 0.1 {
            // Rising to peak (0% to 10%)
            return 1.0 + (0.15 * (overallProgress / 0.1))
        } else if overallProgress < 0.3 {
            // Hold at peak (10% to 30%)
            return 1.15
        } else {
            // Slowly falling from peak (30% to 100%)
            return 1.15 - (0.15 * ((overallProgress - 0.3) / 0.7))
        }
    }

    func calculateOpacity(progress: CGFloat) -> Double {
        // Base opacity curve
        if progress < 0.05 {
            // 0 to 5%: fade in quickly to 0.7 (sync with heart pulse)
            return Double(progress / 0.05 * 0.7)
        } else if progress < 0.15 {
            // 5% to 15%: stay at peak while heart pulse peaks
            return 0.7
        } else if progress < 0.6 {
            // 15% to 60%: fade out faster with nice taper
            return Double(0.7 * (1 - (progress - 0.15) / 0.45))
        } else {
            // After 60%: fully transparent
            return 0
        }
    }

    func getRingColors(progress: CGFloat) -> (Color, Color) {
        if isDarkMode {
            // Dark mode: warm blend → mauve (current)
            let warmBlend1 = Color(red: 1.0, green: 180/255, blue: 130/255)  // Warm peachy-orange
            let warmBlend2 = Color(red: 1.0, green: 120/255, blue: 170/255)  // Warm coral-pink
            let mauve1 = Color(red: 180/255, green: 70/255, blue: 145/255)   // Rich mauve
            let mauve2 = Color(red: 160/255, green: 60/255, blue: 130/255)   // Deep mauve-wine

            let colorProgress = min(progress / 0.3, 1.0)
            let color1 = interpolateRingColor(from: warmBlend1, to: mauve1, progress: Double(colorProgress))
            let color2 = interpolateRingColor(from: warmBlend2, to: mauve2, progress: Double(colorProgress))
            return (color1, color2)
        } else {
            // Light mode: golden amber → rose gold halo
            let goldenAmber1 = Color(red: 255/255, green: 179/255, blue: 102/255)  // #FFB366 warm amber
            let goldenAmber2 = Color(red: 255/255, green: 200/255, blue: 120/255)  // Soft golden

            let roseGold1 = Color(red: 232/255, green: 158/255, blue: 142/255)    // #E89E8E rose gold
            let roseGold2 = Color(red: 220/255, green: 140/255, blue: 130/255)    // Soft coral rose

            let colorProgress = min(progress / 0.3, 1.0)
            let color1 = interpolateRingColor(from: goldenAmber1, to: roseGold1, progress: Double(colorProgress))
            let color2 = interpolateRingColor(from: goldenAmber2, to: roseGold2, progress: Double(colorProgress))
            return (color1, color2)
        }
    }

    func interpolateRingColor(from: Color, to: Color, progress: Double) -> Color {
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress

        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Heart Shape and Glow

struct HeartStaticView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let isDarkMode: Bool
    @State private var startTime = Date()
    @State private var shouldAnimate = true

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
            let progress = CGFloat(cycle / 3.5)

            // Calculate pulse scale with pause at peak and slower retraction
            // 0-10%: Rise to peak, 10-30%: Hold at peak, 30-100%: Slowly fall back
            let pulseScale: CGFloat = {
                if !shouldAnimate {
                    return 1.0  // Resting state when paused
                }
                if progress < 0.1 {
                    // Rising to peak (0% to 10%)
                    return 1.0 + (0.15 * (progress / 0.1))
                } else if progress < 0.3 {
                    // Hold at peak (10% to 30%)
                    return 1.15
                } else {
                    // Slowly falling from peak (30% to 100%)
                    return 1.15 - (0.15 * ((progress - 0.3) / 0.7))
                }
            }()

            ZStack {
                // Heart glow (background) - NOW PULSING
                Ellipse()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: isDarkMode ? [
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.6), location: 0),
                                .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.4), location: 0.6),
                                .init(color: Color.clear, location: 0.9)
                            ] : [
                                .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.6), location: 0),  // Golden amber
                                .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.4), location: 0.6),  // Soft peach
                                .init(color: Color.clear, location: 0.9)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.2
                        )
                    )
                    .frame(width: size.width * 0.4, height: size.height * 0.2)
                    .blur(radius: 20)
                    .scaleEffect(pulseScale)
                    .position(x: size.width * 0.5, y: size.height * 0.3)

                // Subtle heart hint (two lobes with visible dip between)
                ZStack {
                    // Left lobe
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: isDarkMode ? [
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                    .init(color: Color.clear, location: 1.0)
                                ] : [
                                    .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.35), location: 0),  // Golden
                                    .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.18), location: 0.6),  // Peach
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
                                gradient: Gradient(stops: isDarkMode ? [
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                    .init(color: Color.clear, location: 1.0)
                                ] : [
                                    .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.35), location: 0),  // Golden
                                    .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.18), location: 0.6),  // Peach
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
                .scaleEffect(pulseScale)
                .position(x: size.width * 0.5, y: size.height * 0.3)

                // Heart center - PULSING SHARP LIGHT
                HeartCenterPulsingView(size: size, isPlaying: $isPlaying, isDarkMode: isDarkMode)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
            }
        }
        .onChange(of: isPlaying) {
            if isPlaying {
                // Reset timer and restart animation when play is pressed
                startTime = Date()
                shouldAnimate = true
            }
            // When paused: let current cycle complete, stop at beginning of next cycle
        }
        .task(id: isPlaying) {
            if !isPlaying && shouldAnimate {
                // Wait for cycle to complete (check every 50ms)
                while !isPlaying && shouldAnimate {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    let elapsed = Date().timeIntervalSince(startTime)
                    let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
                    let progress = cycle / 3.5
                    if progress < 0.05 {
                        // We're at the start of a new cycle, stop now
                        shouldAnimate = false
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Pulsing Heart Center
// Animates between "Sharp" (dull) and "Max Bright" (peak)

struct HeartCenterPulsingView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let isDarkMode: Bool
    @State private var startTime = Date()
    @State private var shouldAnimate = true

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5) // 3.5 second cycle
            let progress = CGFloat(cycle / 3.5) // 0 to 1

            ZStack {
                // Outer glow layer (soft)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: isDarkMode ? [
                                .init(color: Color(red: 1.0, green: 250/255, blue: 240/255).opacity(0.8), location: 0),
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.4), location: 0.5),
                                .init(color: Color.clear, location: 1.0)
                            ] : [
                                .init(color: Color(red: 1.0, green: 245/255, blue: 230/255).opacity(0.8), location: 0),  // Warm white
                                .init(color: Color(red: 255/255, green: 210/255, blue: 140/255).opacity(0.4), location: 0.5),  // Soft golden
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.06
                        )
                    )
                    .frame(width: size.width * 0.12, height: size.height * 0.06)
                    .blur(radius: interpolate(dull: 8, bright: 15, progress: progress, shouldAnimate: shouldAnimate))

                // Core light (SHARP - minimal blur)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: isDarkMode ? [
                                .init(color: Color.white, location: 0),
                                .init(color: Color.white, location: 0.4),
                                .init(color: Color(red: 1.0, green: 250/255, blue: 240/255), location: 0.7),
                                .init(color: Color.clear, location: 1.0)
                            ] : [
                                .init(color: Color.white, location: 0),
                                .init(color: Color.white, location: 0.4),
                                .init(color: Color(red: 1.0, green: 245/255, blue: 220/255), location: 0.7),  // Warm white
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.04
                        )
                    )
                    .frame(
                        width: size.width * interpolate(dull: 0.08, bright: 0.15, progress: progress, shouldAnimate: shouldAnimate),
                        height: size.height * interpolate(dull: 0.04, bright: 0.075, progress: progress, shouldAnimate: shouldAnimate)
                    )
                    .blur(radius: interpolate(dull: 1, bright: 5, progress: progress, shouldAnimate: shouldAnimate))
                    .brightness(interpolate(dull: 0.2, bright: 0.5, progress: progress, shouldAnimate: shouldAnimate))

                // Bright center spot (NO blur - pure white point)
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: size.width * interpolate(dull: 0.03, bright: 0.05, progress: progress, shouldAnimate: shouldAnimate),
                        height: size.height * interpolate(dull: 0.015, bright: 0.025, progress: progress, shouldAnimate: shouldAnimate)
                    )
                    .shadow(color: Color.white, radius: interpolate(dull: 15, bright: 25, progress: progress, shouldAnimate: shouldAnimate), x: 0, y: 0)
                    .shadow(color: Color.white, radius: interpolate(dull: 8, bright: 15, progress: progress, shouldAnimate: shouldAnimate), x: 0, y: 0)
                    .blendMode(.plusLighter)
            }
        }
        .onChange(of: isPlaying) {
            if isPlaying {
                // Reset timer and restart animation when play is pressed
                startTime = Date()
                shouldAnimate = true
            }
            // When paused: let current cycle complete, stop at beginning of next cycle
        }
        .task(id: isPlaying) {
            if !isPlaying && shouldAnimate {
                // Wait for cycle to complete (check every 50ms)
                while !isPlaying && shouldAnimate {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    let elapsed = Date().timeIntervalSince(startTime)
                    let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
                    let progress = cycle / 3.5
                    if progress < 0.05 {
                        // We're at the start of a new cycle, stop now
                        shouldAnimate = false
                        break
                    }
                }
            }
        }
    }

    // Interpolate between dull and bright values based on pulse progress
    func interpolate(dull: CGFloat, bright: CGFloat, progress: CGFloat, shouldAnimate: Bool = true) -> CGFloat {
        if !shouldAnimate {
            return dull  // Return dull (resting state) when not animating
        }

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

#Preview {
    ContentView()
}
