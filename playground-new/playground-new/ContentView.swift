import SwiftUI

struct ContentView: View {
    @State private var isPlaying = true  // Animation starts playing
    @Environment(\.colorScheme) var colorScheme  // System color scheme (light/dark)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HeartChakraTestView(size: geometry.size, isPlaying: $isPlaying, colorScheme: colorScheme)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)

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

// MARK: - Heart Chakra Animation View

struct HeartChakraTestView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let colorScheme: ColorScheme
    @State private var sceneOpacity: Double = 0

    var body: some View {
        ZStack {
            BackgroundGradientView(colorScheme: colorScheme)
            FlowBandsView(size: size, colorScheme: colorScheme)
            DiagonalMistView(size: size, colorScheme: colorScheme)
            ParticlesView(size: size, colorScheme: colorScheme)
            PulseEchoView(size: size, isPlaying: $isPlaying, colorScheme: colorScheme)
            HeartStaticView(size: size, isPlaying: $isPlaying, colorScheme: colorScheme)
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
    let colorScheme: ColorScheme

    var body: some View {
        if colorScheme == .dark {
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
            // Sunset Teal Warm: peachy-teal/mint gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 255/255, green: 220/255, blue: 200/255),
                    Color(red: 220/255, green: 240/255, blue: 235/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Flow Bands

struct FlowBandsView: View {
    let size: CGSize
    let colorScheme: ColorScheme

    var body: some View {
        let isDark = colorScheme == .dark

        ZStack {
            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(isDark ? 0.192 : 0.55),
                topPosition: 0.22,
                height: 0.06,
                blur: 45,
                duration: 72,
                delay: 15,
                direction: .right,
                colorCycleDuration: 192,
                colorCycleType: .teal1,
                colorScheme: colorScheme
            )

            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 220/255, blue: 220/255).opacity(isDark ? 0.151 : 0.45),
                topPosition: 0.35,
                height: 0.0525,
                blur: 50,
                duration: 56,
                delay: 35,
                direction: .right,
                colorCycleDuration: 148,
                colorCycleType: .teal2,
                colorScheme: colorScheme
            )

            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(isDark ? 0.209 : 0.60),
                bottomPosition: 0.40,
                height: 0.135,
                blur: 45,
                duration: 81,
                delay: 0,
                direction: .left,
                colorCycleDuration: 108,
                colorCycleType: .magenta1,
                colorScheme: colorScheme
            )

            FlowBand(
                size: size,
                color: Color(red: 100/255, green: 100/255, blue: 240/255).opacity(isDark ? 0.166 : 0.50),
                bottomPosition: 0.53,
                height: 0.1125,
                blur: 52,
                duration: 62,
                delay: 27,
                direction: .left,
                colorCycleDuration: 82,
                colorCycleType: .magenta2,
                colorScheme: colorScheme
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
    let colorScheme: ColorScheme

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

        if colorScheme == .dark {
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
            // Light mode: Sunset Teal Warm with enhanced magenta
            switch cycleType {
            case .teal1:
                // Vibrant teal with peachy-mint accents
                return cycleBetween(
                    Color(red: 140/255, green: 225/255, blue: 215/255), // Rich teal
                    Color(red: 110/255, green: 240/255, blue: 225/255), // Bright peachy-mint
                    progress: progress
                ).opacity(baseOpacity)
            case .teal2:
                // Softer teal with warmth
                return cycleBetween(
                    Color(red: 155/255, green: 220/255, blue: 210/255), // Warm sage teal
                    Color(red: 125/255, green: 235/255, blue: 220/255), // Peachy-teal
                    progress: progress
                ).opacity(baseOpacity)
            case .magenta1:
                // Enhanced magenta-coral with app color influence
                return cycleBetween(
                    Color(red: 240/255, green: 140/255, blue: 190/255), // Vibrant magenta (closer to app #a05788)
                    Color(red: 255/255, green: 170/255, blue: 155/255), // Peachy-coral
                    progress: progress
                ).opacity(baseOpacity)
            case .magenta2:
                // Rich peachy-magenta blend
                return cycleBetween(
                    Color(red: 250/255, green: 160/255, blue: 180/255), // Bright peachy-magenta
                    Color(red: 230/255, green: 130/255, blue: 170/255), // Deep magenta-rose
                    progress: progress
                ).opacity(baseOpacity)
            }
        }
    }

    func cycleBetween(_ color1: Color, _ color2: Color, progress: Double) -> Color {
        if progress < 0.5 {
            return interpolateFlowColor(from: color1, to: color2, progress: progress * 2)
        } else {
            return interpolateFlowColor(from: color2, to: color1, progress: (progress - 0.5) * 2)
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

// MARK: - Particles

struct ParticlesView: View {
    let size: CGSize
    let colorScheme: ColorScheme

    var body: some View {
        ZStack {
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
                colorScheme: colorScheme
            )

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
                colorScheme: colorScheme
            )

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
                colorScheme: colorScheme
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
    let colorScheme: ColorScheme

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
        let baseOpacity = colorScheme == .dark ? 0.55 : 0.75

        if colorScheme == .dark {
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
            // Light mode: Sunset Teal Warm with enhanced magenta sparkles
            switch cycleType {
            case .teal:
                // Vibrant teal sparkles
                return particleCycleBetween(
                    Color(red: 140/255, green: 235/255, blue: 220/255), // Bright teal
                    Color(red: 120/255, green: 245/255, blue: 230/255), // Luminous peachy-mint
                    progress: progress
                ).opacity(baseOpacity)
            case .magenta:
                // Enhanced magenta sparkles with app color influence
                return particleCycleBetween(
                    Color(red: 245/255, green: 150/255, blue: 195/255), // Bright magenta (influenced by app #a05788)
                    Color(red: 255/255, green: 175/255, blue: 160/255), // Peachy-coral
                    progress: progress
                ).opacity(baseOpacity)
            }
        }
    }


    func particleCycleBetween(_ color1: Color, _ color2: Color, progress: Double) -> Color {
        if progress < 0.5 {
            return interpolateParticleColor(from: color1, to: color2, progress: progress * 2)
        } else {
            return interpolateParticleColor(from: color2, to: color1, progress: (progress - 0.5) * 2)
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

struct DiagonalMistView: View {
    let size: CGSize
    let colorScheme: ColorScheme
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
        if colorScheme == .dark {
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
            // Light mode: Sunset Teal Warm with enhanced magenta mist
            // Enhanced color cycling with vibrant teal and prominent magenta accents
            let colors: [(Color, Color)] = [
                // Cycle 1: Vibrant teal to bright magenta
                (Color(red: 145/255, green: 235/255, blue: 225/255), Color(red: 245/255, green: 155/255, blue: 200/255)),
                // Cycle 2: Peachy-mint to peachy-magenta blend
                (Color(red: 125/255, green: 245/255, blue: 230/255), Color(red: 255/255, green: 180/255, blue: 170/255)),
                // Cycle 3: Rich teal to deep magenta-rose
                (Color(red: 155/255, green: 230/255, blue: 220/255), Color(red: 235/255, green: 145/255, blue: 190/255))
            ]
            return cycleMistColors(colors, progress: progress, opacities: (0.50, 0.55))  // Higher magenta opacity for prominence
        }
    }

    func cycleMistColors(_ colors: [(Color, Color)], progress: Double, opacities: (CGFloat, CGFloat)) -> (Color, Color) {
        let count = colors.count
        let position = progress * Double(count)
        let index = Int(position) % count
        let nextIndex = (index + 1) % count
        let t = position - Double(Int(position))

        let color1 = interpolateColor(from: colors[index].0, to: colors[nextIndex].0, progress: t).opacity(opacities.0)
        let color2 = interpolateColor(from: colors[index].1, to: colors[nextIndex].1, progress: t).opacity(opacities.1)
        return (color1, color2)
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

// MARK: - Pulse Echo

struct PulseEchoView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let colorScheme: ColorScheme
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

                // Base expansion scale (1.15 to 6)
                let baseScale = 1.15 + (easedProgress * 4.85)

                // Apply heart pulse breathing on top of base expansion
                let finalScale = baseScale * heartPulseScale

                let ringColors = getRingColors(progress: progress)

                Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: colorScheme == .dark ? [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.clear, location: 0.32),
                            .init(color: ringColors.0.opacity(0.9), location: 0.4),
                            .init(color: ringColors.1.opacity(0.7), location: 0.46),
                            .init(color: Color.clear, location: 0.52)
                        ] : [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.clear, location: 0.38),
                            .init(color: ringColors.0.opacity(0.8), location: 0.42),
                            .init(color: ringColors.1.opacity(0.7), location: 0.44),
                            .init(color: Color.clear, location: 0.48)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.14
                    )
                )
                .frame(width: size.width * 0.28, height: size.height * 0.14)
                .blur(radius: colorScheme == .dark ? 4 : 3)
                .scaleEffect(finalScale)
                .opacity(calculateOpacity(progress: progress))
                .blendMode(colorScheme == .dark ? .normal : .plusLighter)
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
    // Same timing as HeartStaticView pulse - gentler for reduced eye strain
    func calculateHeartPulseScale(overallProgress: CGFloat) -> CGFloat {
        if overallProgress < 0.1 {
            // Rising to peak (0% to 10%) - gentler easing
            let t = overallProgress / 0.1
            let eased = easeInOutCubic(t)
            return 1.0 + (0.10 * eased)  // Reduced from 0.15 to 0.10
        } else if overallProgress < 0.3 {
            // Hold at peak (10% to 30%)
            return 1.10  // Reduced from 1.15
        } else {
            // Slowly falling from peak (30% to 100%) - gentler easing
            let t = (overallProgress - 0.3) / 0.7
            let eased = easeInOutCubic(t)
            return 1.10 - (0.10 * eased)  // Reduced from 0.15
        }
    }

    // Smooth easing function for gentler transitions
    func easeInOutCubic(_ t: CGFloat) -> CGFloat {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
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
        if colorScheme == .dark {
            let warmBlend1 = Color(red: 1.0, green: 180/255, blue: 130/255)
            let warmBlend2 = Color(red: 1.0, green: 120/255, blue: 170/255)
            let mauve1 = Color(red: 180/255, green: 70/255, blue: 145/255)
            let mauve2 = Color(red: 160/255, green: 60/255, blue: 130/255)

            let colorProgress = min(progress / 0.3, 1.0)
            let color1 = interpolateRingColor(from: warmBlend1, to: mauve1, progress: Double(colorProgress))
            let color2 = interpolateRingColor(from: warmBlend2, to: mauve2, progress: Double(colorProgress))
            return (color1, color2)
        } else {
            let goldenAmber = Color(red: 255/255, green: 200/255, blue: 120/255)
            let softPeach = Color(red: 255/255, green: 160/255, blue: 130/255)
            return (goldenAmber, softPeach)
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
    let colorScheme: ColorScheme
    @State private var startTime = Date()
    @State private var shouldAnimate = true

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5)
            let progress = CGFloat(cycle / 3.5)

            // Calculate pulse scale with pause at peak and slower retraction
            // Gentler pulse for reduced eye strain
            let pulseScale: CGFloat = {
                if !shouldAnimate {
                    return 1.0  // Resting state when paused
                }
                if progress < 0.1 {
                    // Rising to peak (0% to 10%) - smooth easing
                    let t = progress / 0.1
                    let eased = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
                    return 1.0 + (0.10 * eased)  // Reduced from 0.15 to 0.10
                } else if progress < 0.3 {
                    // Hold at peak (10% to 30%)
                    return 1.10  // Reduced from 1.15
                } else {
                    // Slowly falling from peak (30% to 100%) - smooth easing
                    let t = (progress - 0.3) / 0.7
                    let eased = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
                    return 1.10 - (0.10 * eased)  // Reduced from 0.15
                }
            }()

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: colorScheme == .dark ? [
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.6), location: 0),
                                .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.4), location: 0.6),
                                .init(color: Color.clear, location: 0.9)
                            ] : [
                                .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.6), location: 0),
                                .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.4), location: 0.6),
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

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: colorScheme == .dark ? [
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                    .init(color: Color.clear, location: 1.0)
                                ] : [
                                    .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.18), location: 0.6),
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

                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: colorScheme == .dark ? [
                                    .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.18), location: 0.6),
                                    .init(color: Color.clear, location: 1.0)
                                ] : [
                                    .init(color: Color(red: 255/255, green: 200/255, blue: 120/255).opacity(0.35), location: 0),
                                    .init(color: Color(red: 255/255, green: 160/255, blue: 130/255).opacity(0.18), location: 0.6),
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

                HeartCenterPulsingView(size: size, isPlaying: $isPlaying, colorScheme: colorScheme)
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

struct HeartCenterPulsingView: View {
    let size: CGSize
    @Binding var isPlaying: Bool
    let colorScheme: ColorScheme
    @State private var startTime = Date()
    @State private var shouldAnimate = true

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.5) // 3.5 second cycle
            let progress = CGFloat(cycle / 3.5) // 0 to 1

            // Warm ivory color for gentler eye impact (reduces blue light)
            let warmIvory = Color(red: 1.0, green: 250/255, blue: 235/255)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: colorScheme == .dark ? [
                                .init(color: Color(red: 1.0, green: 245/255, blue: 230/255).opacity(0.7), location: 0),
                                .init(color: Color(red: 1.0, green: 230/255, blue: 120/255).opacity(0.35), location: 0.5),
                                .init(color: Color.clear, location: 1.0)
                            ] : [
                                .init(color: Color(red: 1.0, green: 242/255, blue: 225/255).opacity(0.7), location: 0),
                                .init(color: Color(red: 255/255, green: 210/255, blue: 140/255).opacity(0.35), location: 0.5),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.06
                        )
                    )
                    .frame(width: size.width * 0.12, height: size.height * 0.06)
                    .blur(radius: interpolate(dull: 8, bright: 12, progress: progress, shouldAnimate: shouldAnimate))

                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: colorScheme == .dark ? [
                                .init(color: warmIvory, location: 0),
                                .init(color: warmIvory.opacity(0.9), location: 0.4),
                                .init(color: Color(red: 1.0, green: 245/255, blue: 225/255), location: 0.7),
                                .init(color: Color.clear, location: 1.0)
                            ] : [
                                .init(color: warmIvory, location: 0),
                                .init(color: warmIvory.opacity(0.9), location: 0.4),
                                .init(color: Color(red: 1.0, green: 240/255, blue: 215/255), location: 0.7),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.04
                        )
                    )
                    .frame(
                        width: size.width * interpolate(dull: 0.08, bright: 0.13, progress: progress, shouldAnimate: shouldAnimate),
                        height: size.height * interpolate(dull: 0.04, bright: 0.065, progress: progress, shouldAnimate: shouldAnimate)
                    )
                    .blur(radius: interpolate(dull: 2, bright: 6, progress: progress, shouldAnimate: shouldAnimate))
                    .brightness(interpolate(dull: 0.15, bright: 0.30, progress: progress, shouldAnimate: shouldAnimate))

                Circle()
                    .fill(warmIvory)
                    .frame(
                        width: size.width * interpolate(dull: 0.03, bright: 0.045, progress: progress, shouldAnimate: shouldAnimate),
                        height: size.height * interpolate(dull: 0.015, bright: 0.0225, progress: progress, shouldAnimate: shouldAnimate)
                    )
                    .shadow(color: warmIvory.opacity(0.8), radius: interpolate(dull: 12, bright: 18, progress: progress, shouldAnimate: shouldAnimate), x: 0, y: 0)
                    .shadow(color: warmIvory.opacity(0.6), radius: interpolate(dull: 6, bright: 10, progress: progress, shouldAnimate: shouldAnimate), x: 0, y: 0)
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
    // Uses gentle easing for reduced eye strain
    func interpolate(dull: CGFloat, bright: CGFloat, progress: CGFloat, shouldAnimate: Bool = true) -> CGFloat {
        if !shouldAnimate {
            return dull  // Return dull (resting state) when not animating
        }

        // Create a pulse curve with smooth easing: 0 -> peak at 10% -> back to 0
        let pulseIntensity: CGFloat
        if progress < 0.1 {
            // Rising to peak (0% to 10%) - smooth ease in-out
            let t = progress / 0.1
            pulseIntensity = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
        } else {
            // Falling from peak (10% to 100%) - smooth ease in-out
            let t = (progress - 0.1) / 0.9
            pulseIntensity = 1.0 - (t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2)
        }

        return dull + (bright - dull) * pulseIntensity
    }
}

#Preview {
    ContentView()
}
