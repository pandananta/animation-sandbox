//
//  ContentView.swift
//  playground-new
//
//  Created by ananta on 11/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            HeartChakraTestView(size: geometry.size)
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
    @State private var sceneOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            BackgroundGradientView()

            // All 4 flow bands with individual timing
            FlowBandsView(size: size)

            // Diagonal mist with rotation and 50px blur
            DiagonalMistView(size: size)

            // 3 Floating particles
            ParticlesView(size: size)

            // Pulse echo - expanding ring
            PulseEchoView(size: size)

            // Heart (static for now)
            HeartStaticView(size: size)
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

// MARK: - Flow Bands (All 4)

struct FlowBandsView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Flow-1: Top, teal, drifts right
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
                colorCycleType: .teal1
            )

            // Flow-2: Upper middle, teal lighter, drifts right
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
                colorCycleType: .teal2
            )

            // Flow-3: Lower middle, indigo, drifts left (FIRST)
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.209),
                bottomPosition: 0.25,
                height: 0.135,
                blur: 45,
                duration: 81,
                delay: 0,
                direction: .left,
                colorCycleDuration: 108,
                colorCycleType: .magenta1
            )

            // Flow-4: Bottom, indigo lighter, drifts left
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.166),
                bottomPosition: 0.38,
                height: 0.1125,
                blur: 52,
                duration: 62,
                delay: 27,
                direction: .left,
                colorCycleDuration: 82,
                colorCycleType: .magenta2
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
                // Indigo base
                let t = progress / 0.4
                return interpolateFlowColor(
                    from: Color(red: 100/255, green: 100/255, blue: 240/255),
                    to: Color(red: 150/255, green: 90/255, blue: 220/255),
                    progress: t
                ).opacity(baseOpacity)
            } else if progress < 0.6 {
                // To orange
                let t = (progress - 0.4) / 0.2
                return interpolateFlowColor(
                    from: Color(red: 150/255, green: 90/255, blue: 220/255),
                    to: Color(red: 255/255, green: 140/255, blue: 60/255),
                    progress: t
                ).opacity(baseOpacity)
            } else {
                // Back to indigo
                let t = (progress - 0.6) / 0.4
                return interpolateFlowColor(
                    from: Color(red: 255/255, green: 140/255, blue: 60/255),
                    to: Color(red: 100/255, green: 100/255, blue: 240/255),
                    progress: t
                ).opacity(baseOpacity)
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

    var body: some View {
        ZStack {
            // Particle 1: Teal with color cycling
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
                colorCycleType: .teal
            )

            // Particle 2: Yellow (no color cycling)
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
                colorCycleType: nil
            )

            // Particle 3: Indigo with color cycling
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
                colorCycleType: .magenta
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

        switch cycleType {
        case .teal:
            // Teal particle cycles through teal variants (simplified)
            if progress < 0.5 {
                // Teal to cyan
                let t = progress * 2
                return interpolateParticleColor(
                    from: Color(red: 100/255, green: 220/255, blue: 220/255),
                    to: Color(red: 80/255, green: 240/255, blue: 240/255),
                    progress: t
                ).opacity(baseOpacity)
            } else {
                // Cyan back to teal
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
                // Indigo to magenta
                let t = progress / 0.33
                return interpolateParticleColor(
                    from: Color(red: 100/255, green: 100/255, blue: 240/255),
                    to: Color(red: 200/255, green: 80/255, blue: 200/255),
                    progress: t
                ).opacity(baseOpacity)
            } else if progress < 0.66 {
                // Magenta to orange
                let t = (progress - 0.33) / 0.33
                return interpolateParticleColor(
                    from: Color(red: 200/255, green: 80/255, blue: 200/255),
                    to: Color(red: 255/255, green: 140/255, blue: 60/255),
                    progress: t
                ).opacity(baseOpacity)
            } else {
                // Orange back to indigo
                let t = (progress - 0.66) / 0.34
                return interpolateParticleColor(
                    from: Color(red: 255/255, green: 140/255, blue: 60/255),
                    to: Color(red: 100/255, green: 100/255, blue: 240/255),
                    progress: t
                ).opacity(baseOpacity)
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
        // Color cycle: 0-30% teal→indigo, 30-50% blue→orange, 50-70% teal-cyan→indigo, 70-100% teal→indigo
        if progress < 0.3 {
            // Teal → Indigo
            return (
                Color(red: 100/255, green: 220/255, blue: 220/255).opacity(0.25),
                Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.2)
            )
        } else if progress < 0.5 {
            // Transition to Blue → Orange
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
            // Transition to Teal-Cyan → Indigo
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
            // Transition back to Teal → Indigo
            let t = (progress - 0.7) / 0.3
            let color1 = interpolateColor(
                from: Color(red: 80/255, green: 230/255, blue: 240/255),
                to: Color(red: 100/255, green: 220/255, blue: 220/255),
                progress: t
            ).opacity(0.25)
            let color2 = Color(red: 100/255, green: 100/255, blue: 240/255).opacity(0.2)
            return (color1, color2)
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
    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
            let overallProgress = CGFloat(cycle / 3.5)

            // Delay ring start until heart reaches peak brightness (10% of cycle)
            // Map 10%-100% of overall cycle to 0%-100% of ring expansion
            let ringDelay: CGFloat = 0.1

            if overallProgress < ringDelay {
                // Don't show ring yet - waiting for heart to reach peak
                Color.clear
                    .frame(width: 0, height: 0)
            } else {
                let progress = (overallProgress - ringDelay) / (1.0 - ringDelay)

                // Skip rendering if ring is invisible (optimization)
                if progress >= 0.6 {
                    Color.clear
                        .frame(width: 0, height: 0)
                } else {
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
        // Start with a warm blended tone (orange-pink) that matches the heart's combined glow
        // Heart appears as yellow + magenta blended together = warm orange-pink
        let warmBlend1 = Color(red: 1.0, green: 180/255, blue: 130/255)  // Warm peachy-orange
        let warmBlend2 = Color(red: 1.0, green: 120/255, blue: 170/255)  // Warm coral-pink

        // Mauve-rose colors (at end) - aligned with app color #a05788
        // Richer, more saturated mauve (not pure pink)
        let mauve1 = Color(red: 180/255, green: 70/255, blue: 145/255)  // Rich mauve
        let mauve2 = Color(red: 160/255, green: 60/255, blue: 130/255)  // Deep mauve-wine

        // Transition happens over first 30% of expansion
        let colorProgress = min(progress / 0.3, 1.0)

        let color1 = interpolateRingColor(from: warmBlend1, to: mauve1, progress: Double(colorProgress))
        let color2 = interpolateRingColor(from: warmBlend2, to: mauve2, progress: Double(colorProgress))

        return (color1, color2)
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
    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
            let progress = CGFloat(cycle / 3.5)

            // Calculate pulse scale with pause at peak and slower retraction
            // 0-10%: Rise to peak, 10-30%: Hold at peak, 30-100%: Slowly fall back
            let pulseScale: CGFloat = {
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
                    .scaleEffect(pulseScale)
                    .position(x: size.width * 0.5, y: size.height * 0.3)

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
                .scaleEffect(pulseScale)
                .position(x: size.width * 0.5, y: size.height * 0.3)

                // Heart center - PULSING SHARP LIGHT
                HeartCenterPulsingView(size: size)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
            }
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
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5) // 3.5 second cycle
            let progress = CGFloat(cycle / 3.5) // 0 to 1

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

#Preview {
    ContentView()
}
