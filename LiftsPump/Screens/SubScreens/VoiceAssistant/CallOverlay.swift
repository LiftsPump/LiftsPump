//
//  CallOverlay.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 10/25/25.
//

import SwiftUI

// MARK: - Model
private struct Star: Identifiable {
    let id = UUID()
    // Unit space position centered at (0,0) so we can "breathe" in/out from center easily
    let ux: CGFloat   // -0.5 ... 0.5
    let uy: CGFloat   // -0.5 ... 0.5
    let size: CGFloat // px
    let baseOpacity: Double
    let phaseOffset: Double // random phase so stars don't flicker in sync
}

// MARK: - Breathing, flickering star field
private struct BreathingStarField: View {
    @State private var stars: [Star] = []
    @State private var patchSpeed: Double = 0.2 // cycles per second across the field

    // timeline start reference
    @State private var startTime: Date = Date()

    // Tuning
    let count: Int = 350              // number of dots
    let flickerPeriod: Double = 5.0   // seconds for full on->off->on
    let breatheAmplitude: CGFloat = 0.10 // scale +/- around 1.0

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                let now = timeline.date
                // seconds since appear
                let elapsed = now.timeIntervalSince(startTime)

                // t drives flicker/breathe. patchT drives patch sweep.
                let t = elapsed
                let patchT = elapsed * patchSpeed

                let w = geo.size.width
                let h = geo.size.height
                let center = CGPoint(x: w/2, y: h/2)
                ZStack {
                    // Soft haze like the screenshot
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.16),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: min(w, h) * 0.7
                    )
                    .blendMode(.screen)

                    // Stars
                    ForEach(stars) { s in
                        // Breathing scale: in/out from center with 5s period
                        let omega = 2 * .pi / flickerPeriod
                        let breathe = 1.0 + breatheAmplitude * CGFloat(sin(omega * t))

                        // Map unit space to pixels, then apply breathing
                        let px = center.x + (s.ux * w) * breathe
                        let py = center.y + (s.uy * h) * breathe


                        // Moving patches: compute two patch centers that sweep across unit space
                        let pTime = patchT
                        // Patch center 1 moves diagonally
                        let p1x = -0.6 + CGFloat((pTime.truncatingRemainder(dividingBy: 1.0)) * 1.2)
                        let p1y = -0.6 + CGFloat(((pTime * 0.8).truncatingRemainder(dividingBy: 1.0)) * 1.2)
                        // Patch center 2 moves the opposite diagonal
                        let p2x = 0.6 - CGFloat(((pTime * 1.1).truncatingRemainder(dividingBy: 1.0)) * 1.2)
                        let p2y = -0.6 + CGFloat(((pTime * 0.6).truncatingRemainder(dividingBy: 1.0)) * 1.2)

                        // Distance falloff from nearest patch center (unit space). Radius ~0.25
                        let d1 = hypot(s.ux - p1x, s.uy - p1y)
                        let d2 = hypot(s.ux - p2x, s.uy - p2y)
                        let d = min(d1, d2)
                        let radius: CGFloat = 0.25
                        let patchInfluence = max(0.0, 1.0 - (d / radius)) // 1 at center, 0 at edge

                        // Hard on/off blink over the 5s cycle.
                        // phaseOffset staggers stars so they don't all sync.
                        // blinkRaw goes 0...1 over the cycle. >0.5 means "on".
                        let blinkRaw = 0.5 + 0.5 * sin(omega * t + s.phaseOffset)
                        let isOn = blinkRaw > 0.5

                        // Optional smoothing using patchInfluence so patches still sweep.
                        // When off, alpha = 0. When on, brighten using patchInfluence.
                        let patchBoost = 0.5 + 0.5 * patchInfluence
                        let alpha = isOn
                            ? min(1.0, s.baseOpacity * patchBoost)
                            : 0.0

                        Circle()
                            .fill(Color.white)
                            .frame(width: s.size, height: s.size)
                            .position(x: px, y: py)
                            .opacity(alpha)
                            .shadow(color: Color.white.opacity(alpha), radius: 6)
                    }
                }
                .contentShape(Rectangle())
                .onAppear {
                    if stars.isEmpty {
                        // Distribute stars in a subtle grid-like scatter so it resembles the screenshot
                        var generated: [Star] = []
                        let cols = Int(sqrt(Double(count)) * 1.2)
                        let rows = max(1, count / max(1, cols))
                        for r in 0..<rows {
                            for c in 0..<cols {
                                if generated.count >= count { break }
                                // Grid in unit space [-0.45, 0.45] with tiny jitter to avoid perfect uniformity
                                let gx = -0.45 + (0.9 * (CGFloat(c) / CGFloat(max(1, cols - 1))))
                                let gy = -0.45 + (0.9 * (CGFloat(r) / CGFloat(max(1, rows - 1))))
                                let jx = CGFloat.random(in: -0.01...0.01)
                                let jy = CGFloat.random(in: -0.01...0.01)
                                let size = CGFloat.random(in: 1.6...2.6)
                                let base = Double.random(in: 0.6...0.95)
                                let phase = Double.random(in: 0...(2 * .pi))
                                generated.append(Star(ux: gx + jx, uy: gy + jy, size: size, baseOpacity: base, phaseOffset: phase))
                            }
                        }
                        stars = generated
                    }
                }
            }
            .onAppear {
                startTime = Date()
            }
        }
        // Drive time forward smoothly. We only need a monotonic value; TimelineView triggers frames.
        .drawingGroup()
    }
}

// MARK: - Single animated voice capsule bar
private struct VoiceCapsule: View {
    let index: Int
    let total: Int

    @State private var startTime = Date()

    // visual tuning
    let baseWidth: CGFloat = 8
    let corner: CGFloat = 4
    let maxHeight: CGFloat = 40
    let minHeight: CGFloat = 8
    let period: Double = 4 // seconds per bounce

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let t = now.timeIntervalSince(startTime)

            // give each bar a phase offset so they don't sync
            let phase = Double(index) * 0.6

            // normalized 0...1 bounce using abs(sin)
            let bounce = abs(sin((2 * .pi / period) * (t + phase)))

            // map bounce to height
            let h = minHeight + CGFloat(bounce) * (maxHeight - minHeight)

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color.white)
                .frame(width: baseWidth, height: h)
        }
        .onAppear { startTime = Date() }
    }
}

struct CallOverlay: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .opacity(0.8)

            BreathingStarField()
                .ignoresSafeArea()
                .opacity(0.9)
                .blendMode(.screen)

            // voice activity bars
            HStack(spacing: 6) {
                ForEach(0..<5) { i in
                    VoiceCapsule(index: i, total: 5)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.white.opacity(0.3), radius: 16)
            )
        }
    }
}

#Preview {
    CallOverlay()
}
