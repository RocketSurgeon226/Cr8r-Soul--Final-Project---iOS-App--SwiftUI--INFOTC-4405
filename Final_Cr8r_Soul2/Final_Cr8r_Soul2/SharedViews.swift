//
//  SharedViews.swift
//  Final_Cra8r_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI

// MARK: - Album Art Generator

enum PatternStyle { case wave, diamond, circle, burst, grid, lines }

struct AlbumArtGenerator {
    static func gradient(for elements: [Element], genre: String) -> LinearGradient {
        let colors: [Color] = elements.isEmpty
            ? genreFallback(genre)
            : elements.prefix(2).flatMap { [$0.primaryColor, $0.secondaryColor] } + [genreFallback(genre).first ?? .black]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func patternTag(for elements: [Element]) -> PatternStyle {
        let s = elements.map(\.rawValue).sorted().joined()
        if s.contains("Water") && s.contains("Air") {
            return .wave
        }
        if s.contains("Fire") && s.contains("Earth") {
            return .diamond
        }
        if s.contains("Water") {
            return .circle
        }
        if s.contains("Fire") {
            return .burst
        }
        if s.contains("Earth") {
            return .grid
        }
        if s.contains("Air") {
            return .lines
        }
        return .circle
    }

    static func genreFallback(_ genre: String) -> [Color] {
        switch genre {
        case "Hip-Hop": return [Color(red:0.10,green:0.10,blue:0.15), Color(red:0.30,green:0.20,blue:0.40)]
        case "R&B / Soul": return [Color(red:0.45,green:0.10,blue:0.25), Color(red:0.80,green:0.40,blue:0.20)]
        case "Jazz": return [Color(red:0.05,green:0.05,blue:0.20), Color(red:0.70,green:0.55,blue:0.10)]
        case "Funk": return [Color(red:0.55,green:0.10,blue:0.55), Color(red:0.95,green:0.70,blue:0.05)]
        case "Electronic": return [Color(red:0.00,green:0.60,blue:0.80), Color(red:0.10,green:0.00,blue:0.40)]
        case "Gospel": return [Color(red:0.70,green:0.55,blue:0.10), Color(red:0.95,green:0.90,blue:0.70)]
        case "Afrobeats / African": return [Color(red:0.85,green:0.45,blue:0.05), Color(red:0.20,green:0.60,blue:0.30)]
        case "Rock": return [Color(red:0.85,green:0.45,blue:0.05), Color(red:0.20,green:0.60,blue:0.30)]
        case "Classical": return [Color(red:0.85,green:0.45,blue:0.05), Color(red:0.20,green:0.60,blue:0.30)]
        default: return [Color(red:0.15,green:0.15,blue:0.15), Color(red:0.40,green:0.40,blue:0.40)]
        }
    }
}

// MARK: - Album Art Placeholder View

struct AlbumArtPlaceholderView: View {
    let elements: [Element]
    let genre: String
    let size: CGFloat

    var body: some View {
        ZStack {
            AlbumArtGenerator.gradient(for: elements, genre: genre)
            patternOverlay.opacity(0.18)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(elements.prefix(4)) { el in
                            Text(el.symbol).font(.system(size: size * 0.10))
                        }
                    }
                    .padding(6)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.08))
    }

    @ViewBuilder
    private var patternOverlay: some View {
        switch AlbumArtGenerator.patternTag(for: elements) {
        case .circle:
            Circle().stroke(Color.white, lineWidth: size * 0.04)
                .frame(width: size * 0.70, height: size * 0.70)
        case .wave:
            WaveShape()
                .stroke(Color.white, lineWidth: size * 0.03)
                .frame(width: size, height: size * 0.40)
                .offset(y: size * 0.10)
        case .diamond:
            Rectangle().stroke(Color.white, lineWidth: size * 0.03)
                .frame(width: size * 0.55, height: size * 0.55)
                .rotationEffect(.degrees(45))
        case .burst:
            ForEach(0..<8, id: \.self) { i in
                Rectangle().fill(Color.white)
                    .frame(width: size * 0.02, height: size * 0.35)
                    .offset(y: -size * 0.17)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        case .grid:
            Canvas { ctx, _ in
                let step = size / 5
                for i in 0...5 {
                    let x = CGFloat(i) * step
                    var v = Path(); v.move(to: CGPoint(x: x, y: 0)); v.addLine(to: CGPoint(x: x, y: size))
                    ctx.stroke(v, with: .color(.white), lineWidth: 1)
                    var h = Path(); h.move(to: CGPoint(x: 0, y: x)); h.addLine(to: CGPoint(x: size, y: x))
                    ctx.stroke(h, with: .color(.white), lineWidth: 1)
                }
            }.frame(width: size, height: size)
        case .lines:
            Canvas { ctx, _ in
                let step = size / 6
                for i in 0...6 {
                    var p = Path()
                    let y = CGFloat(i) * step
                    p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size, y: y))
                    ctx.stroke(p, with: .color(.white), lineWidth: 1.5)
                }
            }.frame(width: size, height: size)
        }
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height / 2))
        p.addCurve(
            to: CGPoint(x: rect.width, y: rect.height / 2),
            control1: CGPoint(x: rect.width * 0.25, y: 0),
            control2: CGPoint(x: rect.width * 0.75, y: rect.height)
        )
        return p
    }
}

// MARK: - Element Badge

struct ElementBadgeView: View {
    let element: Element
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Text(element.symbol).font(.system(size: compact ? 10 : 12))
            if !compact {
                Text(element.rawValue).font(.caption2).fontWeight(.semibold)
            }
        }
        .padding(.horizontal, compact ? 5 : 8)
        .padding(.vertical, compact ? 2 : 4)
        .background(element.primaryColor.opacity(0.20))
        .foregroundColor(element.primaryColor)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(element.primaryColor.opacity(0.50), lineWidth: 1))
    }
}

// MARK: - Format Badge

struct FormatBadgeView: View {
    let format: Format
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: format.icon).font(.caption2)
            Text(format.rawValue).font(.caption2).fontWeight(.medium)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color.secondary.opacity(0.15))
        .foregroundColor(.secondary)
        .clipShape(Capsule())
    }
}

// MARK: - Star Rating

struct StarRatingView: View {
    @Binding var rating: Int16
    var interactive: Bool = true
    var starSize: CGFloat = 22

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: Int(rating) >= star ? "star.fill" : "star")
                    .font(.system(size: starSize))
                    .foregroundColor(Int(rating) >= star ? .yellow : .gray.opacity(0.40))
                    .onTapGesture {
                        if interactive {
                            rating = Int(rating) == star ? 0 : Int16(star)
                        }
                    }
            }
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search artist or title...", text: $text)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isActive: Bool
    var activeColor: Color = .indigo
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isActive ? activeColor.opacity(0.20) : Color(.tertiarySystemBackground))
                .foregroundColor(isActive ? activeColor : .secondary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isActive ? activeColor : Color.clear, lineWidth: 1))
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            Cr8View()
                .tabItem { Label("Cr8", systemImage: "square.stack.3d.up") }
            Cr8ShipmentView()
                .tabItem { Label("Shipment", systemImage: "shippingbox") }
            DigModeView()
                .tabItem { Label("Dig", systemImage: "shuffle") }
            DashboardView()
                .tabItem { Label("Soul Stats", systemImage: "chart.bar.xaxis") }
        }
        .tint(.indigo)
    }
}
