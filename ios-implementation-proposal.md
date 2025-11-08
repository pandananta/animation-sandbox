# iOS Implementation Proposal - Heart Chakra Animation

## Executive Summary

This document outlines the implementation strategy for recreating the red-leaning heart chakra animation in Swift for iOS. The implementation will use **SwiftUI** with **Core Animation** for complex animations, targeting **iOS 15+**.

---

## Technology Stack

### Recommended Approach: SwiftUI + Core Animation Hybrid

**Primary Framework: SwiftUI**
- Modern, declarative UI
- Built-in animation support
- Easy layout with relative positioning (GeometryReader)
- Good performance for most effects

**Secondary Framework: Core Animation (CALayer)**
- Complex blur effects (CAFilter)
- Multiple simultaneous animations
- Precise timing control
- Better performance for continuous animations

**Why Not UIKit Alone?**
- More verbose code for relative positioning
- SwiftUI's declarative syntax is cleaner for this use case

**Why Not SpriteKit/SceneKit?**
- Overkill for 2D effects
- Less integration with standard iOS UI
- Animation is not particle-based (no physics needed)

---

## Architecture Overview

```
HeartChakraView (SwiftUI)
├── BackgroundGradientView
├── FlowBandsLayer (CALayer - 4 bands)
├── DiagonalMistView (SwiftUI + CALayer for rotation)
├── ParticlesLayer (CALayer - 3 particles)
├── PulseEchoView (SwiftUI repeating animation)
├── HeartGlowView (SwiftUI)
├── HeartShapeView (SwiftUI custom shape)
└── HeartCenterView (SwiftUI)
```

---

## Implementation Details by Component

### 1. Container View (`HeartChakraView`)

```swift
struct HeartChakraView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundGradientView()
                FlowBandsView(size: geometry.size)
                DiagonalMistView(size: geometry.size)
                ParticlesView(size: geometry.size)
                PulseEchoView(size: geometry.size)
                HeartGlowView(size: geometry.size)
                HeartShapeView(size: geometry.size)
                HeartCenterView(size: geometry.size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
```

**Key Points:**
- Use `GeometryReader` to get actual canvas size
- Pass size down to child views for percentage-based calculations
- `ZStack` automatically layers in order (bottom to top)

---

### 2. Background Gradient

**Implementation: SwiftUI**

```swift
struct BackgroundGradientView: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 35/255, green: 18/255, blue: 55/255),
                Color(red: 5/255, green: 2/255, blue: 15/255)
            ]),
            center: UnitPoint(x: 0.4, y: 0.45),
            startRadius: 0,
            endRadius: 300  // Adjust based on screen size
        )
        .ignoresSafeArea()
    }
}
```

**Challenge:**
- SwiftUI's `RadialGradient` uses `startRadius` and `endRadius` (not percentage)
- Solution: Calculate radius based on `geometry.size`

---

### 3. Heart Shape

**Implementation: SwiftUI Custom Shape**

Create a custom `Shape` struct that draws the heart using two circles (lobes) and fills them with gradient.

```swift
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Left lobe (rounded rectangle top)
        let leftLobe = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: width * 0.5,
            height: height * 0.8
        )

        // Right lobe
        let rightLobe = CGRect(
            x: rect.midX,
            y: rect.minY,
            width: width * 0.5,
            height: height * 0.8
        )

        // Draw rounded tops for lobes
        path.addPath(
            RoundedRectangle(cornerRadius: width * 0.25)
                .path(in: leftLobe)
        )
        path.addPath(
            RoundedRectangle(cornerRadius: width * 0.25)
                .path(in: rightLobe)
        )

        return path
    }
}
```

**For Gradient Fill:**
Use `AngularGradient` or `RadialGradient` with `.mask()` modifier:

```swift
struct HeartShapeView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Left lobe
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 250/255, blue: 240/255),
                    Color(red: 1.0, green: 230/255, blue: 120/255),
                    Color(red: 1.0, green: 100/255, blue: 180/255),
                    Color(red: 220/255, green: 80/255, blue: 160/255)
                ]),
                center: UnitPoint(x: 0.3, y: 0.4),
                startRadius: 0,
                endRadius: size.width * 0.12
            )
            .frame(width: size.width * 0.12, height: size.height * 0.096)
            .blur(radius: 8)
            .shadow(color: Color(red: 1.0, green: 100/255, blue: 180/255).opacity(0.9), radius: 20)
            .offset(x: -size.width * 0.06)

            // Right lobe (similar)
            // ... (mirrored)
        }
        .frame(width: size.width * 0.24, height: size.height * 0.12)
        .position(x: size.width * 0.5, y: size.height * 0.5)
    }
}
```

**Challenge:**
- CSS gradients with `at 30% 40%` need translation to SwiftUI's center point
- Multiple shadows may need `CALayer` for better performance

**Alternative Approach:**
Use `CAShapeLayer` with `CAGradientLayer` mask for more precise control over gradient positioning.

---

### 4. Heart Center

**Implementation: SwiftUI**

```swift
struct HeartCenterView: View {
    let size: CGSize
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 1.0, green: 250/255, blue: 240/255),
                        Color(red: 1.0, green: 230/255, blue: 120/255)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.06
                )
            )
            .frame(width: size.width * 0.12, height: size.height * 0.06)
            .blur(radius: pulse ? 6 : 4)
            .brightness(pulse ? 0.3 : 0)
            .scaleEffect(pulse ? 1.08 : 1.0)
            .shadow(color: Color(red: 1.0, green: 250/255, blue: 240/255), radius: 35)
            .position(x: size.width * 0.5, y: size.height * 0.5)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    pulse = true
                }
            }
    }
}
```

**Animation Strategy:**
- Use `@State` variable to trigger animation
- `withAnimation` with custom curve matching CSS `ease-out`
- `.repeatForever()` for infinite loop
- Keyframe at 10% requires `KeyframeAnimator` (iOS 17+) or custom `CAKeyframeAnimation`

**For iOS 15/16 Compatibility:**
Use explicit keyframe animation with `CAKeyframeAnimation`:

```swift
let animation = CAKeyframeAnimation(keyPath: "transform.scale")
animation.values = [1.0, 1.08, 1.0]
animation.keyTimes = [0, 0.1, 1.0]
animation.duration = 2.5
animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
animation.repeatCount = .infinity
layer.add(animation, forKey: "heartCenterPulse")
```

---

### 5. Heart Glow

**Implementation: SwiftUI**

```swift
struct HeartGlowView: View {
    let size: CGSize
    @State private var pulse = false

    var body: some View {
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
            .blur(radius: pulse ? 24 : 20)
            .brightness(pulse ? 0.2 : 0)
            .opacity(pulse ? 0.75 : 0.6)
            .position(x: size.width * 0.5, y: size.height * 0.5)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    pulse = true
                }
            }
    }
}
```

**Keyframe Requirement:**
Same as Heart Center - needs keyframe at 10% for precise timing.

---

### 6. Pulse Echo

**Implementation: SwiftUI with Repeating Animation**

This is the **most challenging element** because it needs to:
1. Start from scale 0.6
2. Expand to scale 10
3. Fade from 0 → 0.6 → 0
4. Repeat infinitely every 2.5s

```swift
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
```

**Better Approach with CAKeyframeAnimation:**

For precise opacity control:

```swift
// In UIViewRepresentable wrapper
let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
scaleAnimation.values = [0.6, 10.0]
scaleAnimation.keyTimes = [0, 1.0]

let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
opacityAnimation.values = [0, 0.6, 0]
opacityAnimation.keyTimes = [0, 0.12, 1.0]

let group = CAAnimationGroup()
group.animations = [scaleAnimation, opacityAnimation]
group.duration = 2.5
group.timingFunction = CAMediaTimingFunction(name: .easeOut)
group.repeatCount = .infinity

layer.add(group, forKey: "pulseRing")
```

---

### 7. Flow Bands (4 Horizontal Bands)

**Implementation: CAGradientLayer with CAKeyframeAnimation**

This is complex due to:
1. Horizontal linear gradient
2. Movement animation (translate X and Y with wobble)
3. Color cycling animation (4 different colors over time)

**Recommended: CAGradientLayer**

```swift
class FlowBandLayer: CAGradientLayer {
    init(position: CGRect, initialColor: UIColor, config: FlowConfig) {
        super.init()

        self.frame = position
        self.type = .axial
        self.startPoint = CGPoint(x: 0, y: 0.5)
        self.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.locations = [0, 0.5, 1.0]
        self.colors = [
            UIColor.clear.cgColor,
            initialColor.cgColor,
            UIColor.clear.cgColor
        ]

        // Apply blur using CAFilter (private API - use UIVisualEffectView alternative)
        // OR: Use UIVisualEffectView with blur + layer mask

        addPositionAnimation(config: config)
        addColorAnimation(config: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addPositionAnimation(config: FlowConfig) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = createWobblePath(config: config)
        animation.duration = config.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + config.delay
        animation.fillMode = .backwards
        self.add(animation, forKey: "drift")
    }

    func addColorAnimation(config: FlowConfig) {
        let animation = CAKeyframeAnimation(keyPath: "colors")
        animation.values = config.colorCycle.map { [$0.clear, $0, $0.clear] }
        animation.keyTimes = config.colorKeyTimes
        animation.duration = config.colorDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        self.add(animation, forKey: "colorCycle")
    }

    func createWobblePath(config: FlowConfig) -> CGPath {
        let path = UIBezierPath()
        // Calculate path based on keyframe percentages
        // This requires converting CSS translate percentages to actual points
        path.move(to: config.startPoint)
        // Add curves for wobble motion
        path.addCurve(to: config.endPoint,
                      controlPoint1: config.control1,
                      controlPoint2: config.control2)
        return path.cgPath
    }
}
```

**Blur Challenge:**
CALayer doesn't have public blur API. Solutions:
1. **UIVisualEffectView** with `UIBlurEffect` + mask (performance cost)
2. **CIFilter** with `CIGaussianBlur` (rendering cost)
3. **Metal shader** (complex but performant)

**Recommended: CIFilter**

```swift
if let filter = CIFilter(name: "CIGaussianBlur") {
    filter.setValue(39.0, forKey: kCIInputRadiusKey)
    layer.filters = [filter]
}
```

⚠️ **Note**: `CALayer.filters` is macOS only. For iOS, need to use `UIVisualEffectView` or render to image with CIFilter.

**iOS Solution: Render Blur Manually**

Use `UIVisualEffectView` with custom `UIBlurEffect`:
- Not exact match for Gaussian blur
- Performance impact with multiple views

**Alternative: Pre-render Blur**
- Render gradient to image
- Apply CIGaussianBlur filter
- Use resulting image in UIImageView
- Animate the image view

---

### 8. Diagonal Mist

**Implementation: CAGradientLayer with CABasicAnimation**

```swift
struct DiagonalMistView: View {
    let size: CGSize
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.25

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: tealColor.opacity(0.25), location: 0),
                .init(color: indigoColor.opacity(0.2), location: 0.6),
                .init(color: Color.clear, location: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: size.width * 0.8, height: size.height * 0.7)
        .blur(radius: 50)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .offset(x: size.width * -0.1, y: size.height * 0.2)
        .onAppear {
            // Rotation animation
            withAnimation(
                Animation.linear(duration: 45)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }

            // Opacity animation
            withAnimation(
                Animation.easeInOut(duration: 28)
                    .repeatForever(autoreverses: true)
            ) {
                opacity = 0.35
            }

            // Color cycle animation - need custom implementation
        }
    }

    // Color cycling needs state management
    @State private var colorPhase: Int = 0

    var tealColor: Color {
        switch colorPhase {
        case 0: return Color(red: 100/255, green: 220/255, blue: 220/255)
        case 1: return Color(red: 60/255, green: 160/255, blue: 240/255)
        case 2: return Color(red: 80/255, green: 200/255, blue: 220/255)
        default: return Color(red: 100/255, green: 220/255, blue: 220/255)
        }
    }
}
```

**Challenge: Color Cycling**
SwiftUI doesn't support keyframe color animation directly. Options:
1. Use `Timer` to update `@State` colors
2. Use `CAKeyframeAnimation` with `UIViewRepresentable`
3. Use `TimelineView` (iOS 15+) for frame-by-frame updates

---

### 9. Particles (3 Floating Particles)

**Implementation: CALayer with CAAnimationGroup**

```swift
class ParticleLayer: CALayer {
    init(position: CGPoint, size: CGSize, color: UIColor, config: ParticleConfig) {
        super.init()

        self.frame = CGRect(origin: position, size: size)
        self.backgroundColor = UIColor.clear.cgColor

        // Create radial gradient sublayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.frame = bounds
        gradientLayer.colors = [color.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        addSublayer(gradientLayer)

        // Apply blur via filter or pre-render

        // Add animations
        addDriftAnimation(config: config)
        addFadeAnimation(config: config)
        addTwinkleAnimation(config: config)
        if config.hasColorCycle {
            addColorCycleAnimation(config: config)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addDriftAnimation(config: ParticleConfig) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let startPoint = position
        let endPoint = CGPoint(
            x: startPoint.x + config.driftDistance.x,
            y: startPoint.y + config.driftDistance.y
        )
        animation.values = [
            NSValue(cgPoint: startPoint),
            NSValue(cgPoint: endPoint)
        ]
        animation.duration = config.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + config.delay
        animation.fillMode = .backwards
        add(animation, forKey: "drift")
    }

    func addFadeAnimation(config: ParticleConfig) {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [0.2, 0.8, 0.7, 0]
        animation.keyTimes = [0, 0.3, 0.7, 1.0]
        animation.duration = config.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + config.delay
        animation.fillMode = .backwards
        add(animation, forKey: "fade")
    }

    func addTwinkleAnimation(config: ParticleConfig) {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [0.3, 0.9, 0.3]
        animation.keyTimes = [0, 0.5, 1.0]
        animation.duration = config.twinkleDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + config.twinkleDelay
        add(animation, forKey: "twinkle")
    }
}
```

**Challenge: Multiple Simultaneous Opacity Animations**

The particle has TWO opacity animations:
1. `particleFade` (12-14s duration)
2. `twinkle` (4.5-5.5s duration)

In CSS, both animations run simultaneously and their effects combine. In Core Animation, you can't animate the same property with multiple animations.

**Solution: Use CAAnimationGroup or Combine Effects**

Option 1: Animate different properties
- Use `opacity` for fade
- Use layer mask opacity for twinkle

Option 2: Manually calculate combined opacity
```swift
func calculateCombinedOpacity(time: TimeInterval) -> Float {
    let fadeOpacity = calculateFadeOpacity(time)
    let twinkleOpacity = calculateTwinkleOpacity(time)
    return fadeOpacity * twinkleOpacity  // Multiply effects
}
```

Option 3: Use two layers (one for each effect)

---

## Performance Optimization Strategies

### 1. Reduce Blur Rendering Cost

**Problem**: Real-time Gaussian blur on iOS is expensive, especially 39-50px radius.

**Solutions**:
- **Static Elements**: Pre-render blurred gradients to images
- **Dynamic Elements**: Use lower blur radius (20-30px) as compromise
- **Metal Shaders**: Implement custom blur shader for better performance
- **Layer Caching**: Use `shouldRasterize = true` on static layers

### 2. Animation Optimization

**Strategies**:
- Use `CADisplayLink` for synchronized animations instead of multiple timers
- Enable layer backing: `layer.drawsAsynchronously = true`
- Use `CAAnimationGroup` to batch animations
- Avoid animating `backgroundColor` directly; use `contents` instead

### 3. Memory Management

**Strategies**:
- Reuse `CALayer` objects for repeated animations
- Release unused gradient layer resources
- Use `autoreleasepool` for large gradient generation
- Profile with Instruments to identify leaks

---

## Project Structure

```
HeartChakraAnimation/
├── Views/
│   ├── HeartChakraView.swift              # Main container
│   ├── BackgroundGradientView.swift       # Background
│   ├── HeartShapeView.swift               # Heart shape + glow + center
│   ├── PulseEchoView.swift                # Pulsing ring
│   └── DiagonalMistView.swift             # Rotating mist
├── Layers/
│   ├── FlowBandLayer.swift                # CALayer for flow bands
│   ├── ParticleLayer.swift                # CALayer for particles
│   └── AnimationHelpers.swift             # Shared animation utilities
├── Models/
│   ├── AnimationConfig.swift              # Configuration structs
│   └── ColorPalette.swift                 # Color definitions
├── Extensions/
│   ├── Color+Extensions.swift             # Color convenience methods
│   └── CALayer+Blur.swift                 # Blur helper methods
└── Utilities/
    ├── AnimationKeyframes.swift           # Keyframe calculation helpers
    └── BezierPathBuilder.swift            # Path generation for animations
```

---

## Implementation Phases

### Phase 1: Static Rendering (1-2 days)
- ✅ Set up project structure
- ✅ Implement background gradient
- ✅ Create heart shape with gradients
- ✅ Add heart center and glow (static)
- ✅ Verify colors match specification exactly

### Phase 2: Simple Animations (2-3 days)
- ✅ Heart center pulse animation
- ✅ Heart glow pulse animation
- ✅ Pulse echo expanding ring
- ✅ Test timing synchronization

### Phase 3: Complex Animations (3-4 days)
- ✅ Implement all 4 flow bands with position animation
- ✅ Add color cycling to flow bands
- ✅ Diagonal mist rotation + fade + color cycle
- ✅ Optimize blur rendering

### Phase 4: Particles (2-3 days)
- ✅ Create 3 particle layers
- ✅ Diagonal drift animation
- ✅ Particle fade animation
- ✅ Twinkle animation
- ✅ Color cycling (particles 1 & 3)
- ✅ Solve multi-animation opacity challenge

### Phase 5: Refinement (2-3 days)
- ✅ Fine-tune timing to match HTML exactly
- ✅ Performance profiling and optimization
- ✅ Test on multiple device sizes (iPhone SE to Pro Max)
- ✅ Handle edge cases (app backgrounding, memory warnings)
- ✅ Add accessibility considerations

**Total Estimated Time: 10-15 days**

---

## Technical Challenges & Solutions

### Challenge 1: Blur Effects on iOS

**Problem**: No direct equivalent to CSS `filter: blur(39px)` in SwiftUI.

**Solution**:
```swift
// Option A: UIVisualEffectView (limited control)
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var intensity: CGFloat

    func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: effect)
        return view
    }
}

// Option B: CIFilter (more control, performance cost)
extension View {
    func gaussianBlur(radius: CGFloat) -> some View {
        self.modifier(GaussianBlurModifier(radius: radius))
    }
}

struct GaussianBlurModifier: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .drawingGroup()  // Render to image
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .modifier(CIFilterBlur(radius: radius))
                }
            )
    }
}
```

**Recommendation**: Use SwiftUI's built-in `.blur(radius:)` which uses Core Image under the hood. Performance is acceptable for this use case.

---

### Challenge 2: Color Cycling Animations

**Problem**: SwiftUI doesn't support smooth color keyframe animations.

**Solution**:
```swift
// Using TimelineView (iOS 15+)
struct ColorCyclingGradient: View {
    let duration: Double
    let colors: [Color]
    let keyTimes: [Double]

    var body: some View {
        TimelineView(.animation) { timeline in
            let progress = calculateProgress(date: timeline.date)
            let currentColor = interpolateColor(progress: progress)

            LinearGradient(
                colors: [.clear, currentColor, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    func calculateProgress(date: Date) -> Double {
        let elapsed = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
        return elapsed / duration
    }

    func interpolateColor(progress: Double) -> Color {
        // Interpolate between colors based on keyTimes
        // Linear interpolation between adjacent colors
    }
}
```

**Alternative**: Use `CAKeyframeAnimation` with `UIViewRepresentable` for better performance.

---

### Challenge 3: Transform Origin for Centered Scaling

**Problem**: CSS `translate(-50%, -50%)` centers element before scaling. SwiftUI's `.scaleEffect()` uses implicit center.

**Solution**:
```swift
// SwiftUI automatically scales from center, so this is simpler!
Circle()
    .scaleEffect(animationProgress)
    .position(x: size.width * 0.5, y: size.height * 0.5)
```

SwiftUI's `.position()` is equivalent to CSS `top: 50%; left: 50%; transform: translate(-50%, -50%)`.

---

### Challenge 4: Animation Delays with Fill Mode Backwards

**Problem**: CSS `animation-fill-mode: backwards` applies initial keyframe state during delay period.

**Solution**:
```swift
// CAAnimation approach
animation.beginTime = CACurrentMediaTime() + delay
animation.fillMode = .backwards  // Applies initial state during delay
animation.isRemovedOnCompletion = false

// SwiftUI approach - set initial state manually
@State private var position: CGPoint = initialPosition
@State private var opacity: Double = 0  // Initial state from keyframe 0%

var body: some View {
    element
        .position(position)
        .opacity(opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(...) {
                    position = finalPosition
                    opacity = 1.0
                }
            }
        }
}
```

---

### Challenge 5: Multiple Independent Animation Loops

**Problem**: Each element has different durations (2.5s, 12s, 48s, 192s, etc.). They don't sync.

**Solution**: Each animation runs independently with `.repeatForever()`. No synchronization needed.

```swift
// Each view manages its own animation state
struct FlowBand1: View {
    @State private var animating = false

    var body: some View {
        // ...
        .onAppear {
            withAnimation(.easeInOut(duration: 48).repeatForever(autoreverses: false)) {
                animating.toggle()
            }
        }
    }
}
```

iOS Core Animation handles multiple concurrent timelines efficiently.

---

## Testing Strategy

### Unit Tests
- Color conversion accuracy (RGB values)
- Percentage-to-point calculations
- Animation timing calculations
- Keyframe interpolation

### Visual Tests
- Side-by-side comparison with HTML version
- Screenshot comparison at key animation points
- Color accuracy validation with color picker

### Performance Tests
- FPS monitoring (should maintain 60fps on iPhone 12+)
- Memory usage (should stay under 100MB)
- Battery impact (should not cause significant drain)

### Device Testing
- iPhone SE (small screen)
- iPhone 14 Pro (standard)
- iPhone 14 Pro Max (large screen)
- iPad (different aspect ratio)

---

## Alternative Implementation: UIKit + Core Animation

For maximum performance and control, consider pure UIKit:

```swift
class HeartChakraViewController: UIViewController {
    private var containerView: UIView!
    private var flowBandLayers: [FlowBandLayer] = []
    private var particleLayers: [ParticleLayer] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()
        setupBackground()
        setupFlowBands()
        setupDiagonalMist()
        setupParticles()
        setupHeartLayers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAllAnimations()
    }

    private func setupFlowBands() {
        let band1Config = FlowConfig(
            duration: 48,
            delay: 2,
            colorDuration: 192,
            // ... other config
        )
        let band1 = FlowBandLayer(
            position: CGRect(x: 0, y: view.bounds.height * 0.22,
                           width: view.bounds.width, height: view.bounds.height * 0.16),
            initialColor: UIColor(red: 100/255, green: 220/255, blue: 220/255, alpha: 0.28),
            config: band1Config
        )
        view.layer.addSublayer(band1)
        flowBandLayers.append(band1)
    }
}
```

**Pros**:
- Better performance (direct layer manipulation)
- More control over animations
- Easier blur implementation with filters

**Cons**:
- More verbose code
- Manual layout calculations
- Less declarative than SwiftUI

---

## Recommended Tech Stack Decision

### For iOS 15+: **SwiftUI + CALayer Hybrid**

**Reasoning**:
1. SwiftUI for structure and simple animations (heart, background)
2. CALayer for complex animations (flow bands, particles)
3. Best balance of code clarity and performance
4. Future-proof (SwiftUI is the future of iOS development)

### For iOS 13-14: **Pure UIKit + Core Animation**

**Reasoning**:
1. SwiftUI animations less mature in iOS 13-14
2. Better performance on older devices
3. More predictable behavior

---

## Code Organization Pattern

Use **UIViewRepresentable** to wrap CALayer-based components:

```swift
struct FlowBandsView: UIViewRepresentable {
    let size: CGSize

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        // Create 4 flow band layers
        let band1 = FlowBandLayer(/* config */)
        let band2 = FlowBandLayer(/* config */)
        let band3 = FlowBandLayer(/* config */)
        let band4 = FlowBandLayer(/* config */)

        view.layer.addSublayer(band1)
        view.layer.addSublayer(band2)
        view.layer.addSublayer(band3)
        view.layer.addSublayer(band4)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}

// Use in SwiftUI
struct HeartChakraView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundGradientView()
                FlowBandsView(size: geometry.size)  // CALayer-based
                HeartShapeView(size: geometry.size)  // SwiftUI-based
            }
        }
    }
}
```

---

## Accessibility Considerations

1. **Reduce Motion Support**
   ```swift
   @Environment(\.accessibilityReduceMotion) var reduceMotion

   var animationDuration: Double {
       reduceMotion ? 0 : 2.5
   }
   ```

2. **Voice Over**: Add descriptive labels
   ```swift
   .accessibilityLabel("Heart chakra meditation animation")
   .accessibilityHidden(true)  // Purely decorative
   ```

3. **Battery Saver**: Reduce animation complexity when low power mode is enabled
   ```swift
   ProcessInfo.processInfo.isLowPowerModeEnabled
   ```

---

## Next Steps

1. **Validate specification** with stakeholder
2. **Choose tech stack** (SwiftUI hybrid vs UIKit)
3. **Create proof-of-concept** with one complete element (e.g., pulse echo)
4. **Performance benchmark** the POC
5. **Proceed with full implementation** based on phases outlined

---

## Questions to Answer Before Implementation

1. **Target iOS version**: iOS 15+, 16+, or 17+?
   - Affects animation API choices (KeyframeAnimator requires iOS 17)

2. **Device support**: iPhone only or iPad too?
   - Affects layout and performance optimization

3. **Orientation**: Portrait only or support landscape?
   - Affects percentage calculations

4. **Background behavior**: Should animation pause when app backgrounds?
   - Affects battery and resource management

5. **Performance target**: 60fps minimum or 30fps acceptable?
   - Affects blur quality and animation complexity

6. **Accessibility**: Full support for Reduce Motion and VoiceOver?
   - Affects implementation approach

---

## Estimated Resource Requirements

**Development**: 10-15 days (1 senior iOS developer)
**Design QA**: 2-3 days (visual accuracy verification)
**Performance Testing**: 2 days (device testing and optimization)
**Code Review**: 1 day

**Total**: ~15-20 working days

**Skills Required**:
- Advanced SwiftUI (geometryReader, custom layouts)
- Core Animation (CALayer, CAKeyframeAnimation)
- Core Graphics (bezier paths, gradients)
- Performance profiling (Instruments)
