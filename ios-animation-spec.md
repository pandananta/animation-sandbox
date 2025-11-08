# iOS Heart Animation Specification - Red-Leaning Variant

This document specifies the exact implementation details for the red-leaning heart chakra animation (Variant 7) from the HTML version.

## Canvas / Background

**Background Gradient:**
- Type: Radial gradient (ellipse)
- Center position: 40% horizontal, 45% vertical from top-left
- Colors:
  - Inner: rgb(35, 18, 55) - dark purple
  - Outer: rgb(5, 2, 15) - nearly black

## Layer Hierarchy (Z-Index Order - Bottom to Top)

1. Background canvas
2. Flow bands (flow-1, flow-2, flow-3, flow-4)
3. Diagonal mist
4. Particles (p1, p2, p3)
5. Pulse echo (z-index: 9)
6. Heart glow (z-index: 10)
7. Heart shape (z-index: 11)
8. Heart center (z-index: 12)

---

## 1. Heart Glow

**Position:**
- Centered absolutely: 50% left, 50% top
- Transform: translate(-50%, -50%)

**Size:**
- Width: 40% of canvas width
- Height: 20% of canvas height

**Gradient:**
- Type: Radial gradient (ellipse)
- Color stops:
  - 0%: rgba(255, 230, 120, 0.6) - warm yellow glow
  - 60%: rgba(255, 100, 180, 0.4) - pink
  - 90%: transparent

**Filter:**
- Blur: 20px

**Animation:** `heartGlowPulse`
- Duration: 2.5s
- Easing: ease-out
- Infinite loop
- Keyframes:
  - 0%, 100%: blur(20px) brightness(1), opacity: 0.6
  - 10%: blur(24px) brightness(1.2), opacity: 0.75

---

## 2. Heart Shape

**Position:**
- Centered absolutely: 50% left, 50% top
- Transform: translate(-50%, -50%)

**Size:**
- Width: 24% of canvas width
- Height: 12% of canvas height

**Construction:**
The heart is made of two pseudo-elements (::before and ::after) creating the top lobes:

### Left Lobe (::before)
**Position:**
- Top: 0
- Left: 0
- Width: 50% of heart width
- Height: 80% of heart height

**Shape:**
- Border-radius: 50% 50% 0 0 (rounded top, flat bottom)

**Gradient:**
- Type: Radial gradient (circle)
- Center: 30% horizontal, 40% vertical
- Color stops:
  - 0%: rgb(255, 250, 240) - nearly white
  - 40%: rgb(255, 230, 120) - warm yellow
  - 80%: rgb(255, 100, 180) - bright pink
  - 100%: rgb(220, 80, 160) - deeper pink

**Filter:**
- Blur: 8px

**Shadow:**
- Box-shadow: 0 0 40px rgba(255, 100, 180, 0.9)

### Right Lobe (::after)
**Position:**
- Top: 0
- Right: 0
- Width: 50% of heart width
- Height: 80% of heart height

**Shape:**
- Border-radius: 50% 50% 0 0

**Gradient:**
- Type: Radial gradient (circle)
- Center: 70% horizontal, 40% vertical
- Color stops: (same as left lobe)
  - 0%: rgb(255, 250, 240)
  - 40%: rgb(255, 230, 120)
  - 80%: rgb(255, 100, 180)
  - 100%: rgb(220, 80, 160)

**Filter:**
- Blur: 8px

**Shadow:**
- Box-shadow: 0 0 40px rgba(255, 100, 180, 0.9)

---

## 3. Heart Center

**Position:**
- Centered absolutely: 50% left, 50% top
- Transform: translate(-50%, -50%)

**Size:**
- Width: 12% of canvas width
- Height: 6% of canvas height

**Shape:**
- Border-radius: 50% (perfect circle)

**Gradient:**
- Type: Radial gradient (circle)
- Color stops:
  - 0%: rgb(255, 255, 255) - pure white
  - 50%: rgb(255, 250, 240) - warm white
  - 100%: rgb(255, 230, 120) - warm yellow

**Filter:**
- Blur: 4px

**Shadow:**
- Box-shadow: 0 0 35px rgba(255, 250, 240, 1)

**Animation:** `heartCenterPulse`
- Duration: 2.5s
- Easing: ease-out
- Infinite loop
- Keyframes:
  - 0%, 100%: blur(4px) brightness(1), scale(1)
  - 10%: blur(6px) brightness(1.3), scale(1.08)

---

## 4. Pulse Echo (Red-Leaning Variant)

**Position:**
- Centered absolutely: 50% left, 50% top

**Size:**
- Width: 28% of canvas width
- Height: 14% of canvas height

**Shape:**
- Border-radius: 50% (ellipse)

**Gradient:**
- Type: Radial gradient (circle)
- Color stops:
  - 0-32%: transparent
  - 40%: rgba(230, 50, 140, 0.9) - **RED-LEANING MAGENTA** (bright)
  - 46%: rgba(210, 40, 130, 0.7) - **RED-LEANING MAGENTA** (softer)
  - 52%+: transparent

**Filter:**
- Blur: 2px

**Animation:** `pulseRingSlow`
- Duration: 2.5s
- Easing: ease-out
- Infinite loop
- Keyframes:
  - 0%: scale(0.6), opacity: 0, translate(-50%, -50%)
  - 12%: opacity: 0.6
  - 100%: scale(10), opacity: 0, translate(-50%, -50%)

---

## 5. Flow Bands

### Flow-1 (Top, Teal - Drifts Right)

**Position:**
- Top: 22% from top
- Left: 0
- Width: 100%
- Height: 16%

**Gradient:**
- Type: Linear gradient (horizontal, left to right)
- Color stops:
  - 0%: transparent
  - 50%: rgba(100, 220, 220, 0.28) - teal/cyan
  - 100%: transparent

**Filter:**
- Blur: 39px

**Animations:**
1. `driftRightWobble1`
   - Duration: 48s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 2s
   - Fill-mode: backwards
   - Keyframes:
     - 0%: translate(-100%, 0), opacity: 0
     - 5%: opacity: 1
     - 20%: translate(-25%, -2%)
     - 40%: translate(50%, 0)
     - 60%: translate(125%, 1%)
     - 75%: translate(200%, 0), opacity: 1
     - 80%: opacity: 0
     - 100%: translate(200%, 0), opacity: 0

2. `colorCycleTeal1`
   - Duration: 192s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle:
     - 0%, 100%: rgba(100, 220, 220, 0.28)
     - 25%: rgba(60, 160, 240, 0.28)
     - 50%: rgba(80, 200, 220, 0.35)
     - 75%: rgba(100, 100, 240, 0.28)

### Flow-2 (Upper Middle, Teal - Drifts Right)

**Position:**
- Top: 35% from top
- Left: 0
- Width: 100%
- Height: 14%

**Gradient:**
- Type: Linear gradient (horizontal)
- Color stops:
  - 0%: transparent
  - 50%: rgba(100, 220, 220, 0.22) - teal (lighter opacity)
  - 100%: transparent

**Filter:**
- Blur: 42px

**Animations:**
1. `driftRightWobble2`
   - Duration: 37s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 11s
   - Fill-mode: backwards
   - Keyframes:
     - 0%: translate(-100%, 0), opacity: 0
     - 6%: opacity: 1
     - 25%: translate(-40%, 1.5%)
     - 50%: translate(20%, -1%)
     - 72%: translate(200%, 0), opacity: 1
     - 78%: opacity: 0
     - 100%: translate(200%, 0), opacity: 0

2. `colorCycleTeal2`
   - Duration: 148s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle:
     - 0%, 100%: rgba(100, 220, 220, 0.22)
     - 25%: rgba(60, 160, 240, 0.22)
     - 50%: rgba(80, 200, 220, 0.28)
     - 75%: rgba(100, 100, 240, 0.22)

### Flow-3 (Lower Middle, Magenta - Drifts Left)

**Position:**
- Bottom: 25% from bottom
- Left: 0
- Width: 100%
- Height: 18%

**Gradient:**
- Type: Linear gradient (horizontal)
- Color stops:
  - 0%: transparent
  - 50%: rgba(100, 100, 240, 0.29) - indigo/blue
  - 100%: transparent

**Filter:**
- Blur: 39px

**Animations:**
1. `driftLeftWobble1`
   - Duration: 54s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 5s
   - Fill-mode: backwards
   - Keyframes:
     - 0%: translate(100%, 0), opacity: 0
     - 5%: opacity: 1
     - 20%: translate(25%, 1%)
     - 40%: translate(-50%, 0)
     - 60%: translate(-125%, -1.5%)
     - 75%: translate(-200%, 0), opacity: 1
     - 80%: opacity: 0
     - 100%: translate(-200%, 0), opacity: 0

2. `colorCycleMagenta1`
   - Duration: 108s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle:
     - 0%: rgba(100, 100, 240, 0.29)
     - 40%: rgba(100, 100, 240, 0.29)
     - 60%: rgba(255, 140, 60, 0.29) - orange
     - 100%: rgba(100, 100, 240, 0.29)

### Flow-4 (Bottom, Magenta - Drifts Left)

**Position:**
- Bottom: 38% from bottom
- Left: 0
- Width: 100%
- Height: 15%

**Gradient:**
- Type: Linear gradient (horizontal)
- Color stops:
  - 0%: transparent
  - 50%: rgba(100, 100, 240, 0.23) - indigo (lighter)
  - 100%: transparent

**Filter:**
- Blur: 44px

**Animations:**
1. `driftLeftWobble2`
   - Duration: 41s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 17s
   - Fill-mode: backwards
   - Keyframes:
     - 0%: translate(100%, 0), opacity: 0
     - 7%: opacity: 1
     - 28%: translate(30%, -1%)
     - 52%: translate(-40%, 1%)
     - 73%: translate(-200%, 0), opacity: 1
     - 80%: opacity: 0
     - 100%: translate(-200%, 0), opacity: 0

2. `colorCycleMagenta2`
   - Duration: 82s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle:
     - 0%: rgba(100, 100, 240, 0.23)
     - 40%: rgba(100, 100, 240, 0.23)
     - 60%: rgba(255, 140, 60, 0.23)
     - 100%: rgba(100, 100, 240, 0.23)

---

## 6. Diagonal Mist

**Position:**
- Top: 20% from top
- Left: -10% (extends beyond left edge)
- Width: 80% of canvas
- Height: 70% of canvas

**Gradient:**
- Type: Linear gradient (diagonal, top-left to bottom-right)
- Color stops:
  - 0%: rgba(100, 220, 220, 0.25) - teal
  - 60%: rgba(100, 100, 240, 0.2) - indigo
  - 90%: transparent

**Filter:**
- Blur: 50px

**Transform:**
- Rotate: -15deg (counterclockwise)

**Animations:**
1. `slowRotate`
   - Duration: 45s
   - Easing: linear
   - Infinite loop
   - Keyframes:
     - 0%: rotate(0deg)
     - 100%: rotate(360deg)

2. `atmosphereFade`
   - Duration: 28s
   - Easing: ease-in-out
   - Infinite loop
   - Keyframes:
     - 0%: opacity: 0.25
     - 50%: opacity: 0.35
     - 100%: opacity: 0.25

3. `colorCycleDiagonalMist`
   - Duration: 135s
   - Easing: ease-in-out
   - Infinite loop
   - Color transitions:
     - 0%: teal → indigo
     - 30%: teal → indigo
     - 50%: blue → orange
     - 70%: teal-cyan → indigo
     - 100%: teal → indigo

---

## 7. Particles

All particles:
- Shape: Perfect circle (border-radius: 50%)
- Base filter: Blur 12px (from .particle class)

### Particle 1 (Teal)

**Position:**
- Bottom: 15% from bottom
- Left: 12% from left
- Width: 10% of canvas
- Height: 5% of canvas

**Gradient:**
- Type: Radial gradient (circle)
- Colors:
  - Center: rgba(100, 220, 220, 0.45) - teal
  - Edge: transparent

**Animations:**
1. `diagonalDriftUpRight`
   - Duration: 12s
   - Easing: ease-in-out
   - Infinite loop
   - Keyframes:
     - 0%: translate(0, 0)
     - 100%: translate(80%, -180%)

2. `particleFade`
   - Duration: 12s
   - Easing: ease-in-out
   - Infinite loop
   - Keyframes:
     - 0%: opacity: 0.2
     - 30%: opacity: 0.8
     - 70%: opacity: 0.7
     - 100%: opacity: 0

3. `colorCycleParticleTeal`
   - Duration: 192s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle through teal variants

4. `twinkle`
   - Duration: 5s
   - Easing: ease-in-out
   - Infinite loop
   - Keyframes:
     - 0%: opacity: 0.3
     - 50%: opacity: 0.9
     - 100%: opacity: 0.3

### Particle 2 (Yellow)

**Position:**
- Bottom: 20% from bottom
- Left: 18% from left
- Width: 9% of canvas
- Height: 4.5% of canvas

**Gradient:**
- Type: Radial gradient (circle)
- Colors:
  - Center: rgba(255, 200, 80, 0.45) - yellow/gold
  - Edge: transparent

**Animations:**
1. `diagonalDriftUpRight`
   - Duration: 14s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 3s
   - Fill-mode: backwards
   - Keyframes: (same as particle 1)

2. `particleFade`
   - Duration: 14s
   - Delay: 3s
   - Fill-mode: backwards
   - (same keyframes as above)

3. `twinkle`
   - Duration: 4.5s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 1s
   - (same keyframes as above)

### Particle 3 (Indigo)

**Position:**
- Bottom: 25% from bottom
- Left: 25% from left
- Width: 11% of canvas
- Height: 5.5% of canvas

**Gradient:**
- Type: Radial gradient (circle)
- Colors:
  - Center: rgba(100, 100, 240, 0.45) - indigo/purple
  - Edge: transparent

**Animations:**
1. `diagonalDriftUpRight`
   - Duration: 13s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 6s
   - Fill-mode: backwards
   - Keyframes: (same as particle 1)

2. `particleFade`
   - Duration: 13s
   - Delay: 6s
   - Fill-mode: backwards
   - (same keyframes as above)

3. `colorCycleParticleMagenta`
   - Duration: 104s
   - Easing: ease-in-out
   - Infinite loop
   - Color cycle through magenta/indigo/orange

4. `twinkle`
   - Duration: 5.5s
   - Easing: ease-in-out
   - Infinite loop
   - Delay: 2s
   - (same keyframes as above)

---

## Animation Timing Summary

| Element | Animation | Duration | Easing | Delay | Loop |
|---------|-----------|----------|--------|-------|------|
| Heart Center | heartCenterPulse | 2.5s | ease-out | 0s | ∞ |
| Heart Glow | heartGlowPulse | 2.5s | ease-out | 0s | ∞ |
| Pulse Echo | pulseRingSlow | 2.5s | ease-out | 0s | ∞ |
| Flow-1 | driftRightWobble1 | 48s | ease-in-out | 2s | ∞ |
| Flow-1 | colorCycleTeal1 | 192s | ease-in-out | 0s | ∞ |
| Flow-2 | driftRightWobble2 | 37s | ease-in-out | 11s | ∞ |
| Flow-2 | colorCycleTeal2 | 148s | ease-in-out | 0s | ∞ |
| Flow-3 | driftLeftWobble1 | 54s | ease-in-out | 5s | ∞ |
| Flow-3 | colorCycleMagenta1 | 108s | ease-in-out | 0s | ∞ |
| Flow-4 | driftLeftWobble2 | 41s | ease-in-out | 17s | ∞ |
| Flow-4 | colorCycleMagenta2 | 82s | ease-in-out | 0s | ∞ |
| Diagonal Mist | slowRotate | 45s | linear | 0s | ∞ |
| Diagonal Mist | atmosphereFade | 28s | ease-in-out | 0s | ∞ |
| Diagonal Mist | colorCycleDiagonalMist | 135s | ease-in-out | 0s | ∞ |
| Particle 1 | diagonalDriftUpRight | 12s | ease-in-out | 0s | ∞ |
| Particle 1 | particleFade | 12s | ease-in-out | 0s | ∞ |
| Particle 1 | colorCycleParticleTeal | 192s | ease-in-out | 0s | ∞ |
| Particle 1 | twinkle | 5s | ease-in-out | 0s | ∞ |
| Particle 2 | diagonalDriftUpRight | 14s | ease-in-out | 3s | ∞ |
| Particle 2 | particleFade | 14s | ease-in-out | 3s | ∞ |
| Particle 2 | twinkle | 4.5s | ease-in-out | 1s | ∞ |
| Particle 3 | diagonalDriftUpRight | 13s | ease-in-out | 6s | ∞ |
| Particle 3 | particleFade | 13s | ease-in-out | 6s | ∞ |
| Particle 3 | colorCycleParticleMagenta | 104s | ease-in-out | 0s | ∞ |
| Particle 3 | twinkle | 5.5s | ease-in-out | 2s | ∞ |

---

## Key Color Palette (Red-Leaning Variant)

**Pulse Echo (Distinguishing Feature):**
- Primary: rgba(230, 50, 140, 0.9) - bright red-leaning magenta
- Secondary: rgba(210, 40, 130, 0.7) - softer red-leaning magenta

**Heart Shape:**
- Highlight: rgb(255, 250, 240) - warm white
- Mid-tone: rgb(255, 230, 120) - warm yellow
- Shadow 1: rgb(255, 100, 180) - bright pink
- Shadow 2: rgb(220, 80, 160) - deep pink

**Heart Center:**
- Core: rgb(255, 255, 255) - pure white
- Mid: rgb(255, 250, 240) - warm white
- Edge: rgb(255, 230, 120) - warm yellow

**Heart Glow:**
- Inner: rgba(255, 230, 120, 0.6) - warm yellow
- Outer: rgba(255, 100, 180, 0.4) - pink

**Flow Bands:**
- Teal: rgba(100, 220, 220, 0.28), rgba(100, 220, 220, 0.22)
- Indigo: rgba(100, 100, 240, 0.29), rgba(100, 100, 240, 0.23)
- Blue variant: rgba(60, 160, 240, ...)
- Cyan variant: rgba(80, 200, 220, ...)
- Orange (cycle): rgba(255, 140, 60, ...)

**Particles:**
- Teal: rgba(100, 220, 220, 0.45)
- Yellow: rgba(255, 200, 80, 0.45)
- Indigo: rgba(100, 100, 240, 0.45)

**Background:**
- Center: rgb(35, 18, 55) - dark purple
- Edge: rgb(5, 2, 15) - nearly black

---

## Notes on Implementation

1. **Coordinate System**: All percentages are relative to the canvas/container size
2. **Transform Origin**: Most transforms use the element's center as origin
3. **Blur Performance**: Heavy blur effects (39-50px) may require optimization on mobile
4. **Animation Fill Mode**: Several animations use `animation-fill-mode: backwards` to ensure proper initial state with delays
5. **Multiple Simultaneous Animations**: Many elements run 2-4 animations concurrently (position, opacity, color, rotation)
6. **Timing Independence**: Each animation loop is independent; they don't sync at a common interval
7. **Color Cycling**: Color animations cycle through 4 different color states smoothly
