//
//  MeshGradientView.swift
//  ColourCam
//
//  Created by Jarrod Norwell on 6/5/2025.
//

import SwiftUI

struct MeshGradientView: View {
    private var colors: [Color] = [
        .init(red: 0.60, green: 0.80, blue: 1.00), // Soft sky blue
        .init(red: 0.40, green: 0.70, blue: 0.90), // Cool blue
        .init(red: 0.30, green: 0.60, blue: 0.80), // Muted teal-blue

        .init(red: 0.60, green: 0.60, blue: 0.95), // Lavender blue
        .init(red: 0.50, green: 0.50, blue: 0.80), // Dusty purple
        .init(red: 0.40, green: 0.40, blue: 0.70), // Deep violet

        .init(red: 0.25, green: 0.35, blue: 0.70), // Cool indigo
        .init(red: 0.10, green: 0.30, blue: 0.60), // Slate blue
        .init(red: 0.00, green: 0.20, blue: 0.50)  // Navy tone
    ]
    
    private let points: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5, 0.5), SIMD2<Float>(1.0, 0.5),
        SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(1.0, 1.0)
    ]
    
    init(_ colours: [String]? = nil) {
        if let colours {
            self.colors = colours.map { Color(uiColor: .fromHex(UInt32($0.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0x00)) }
        }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            MeshGradient(width: 3,
                         height: 3,
                         locations: .points(points),
                         colors: .colors(animatedColors(for: timeline.date)),
                         background: .black,
                         smoothsColors: true)
        }
        .ignoresSafeArea()
    }
    
    private func animatedColors(for date: Date) -> [Color] {
        let phase = CGFloat(date.timeIntervalSince1970)
        
        return colors.enumerated().map { index, color in
            let hueShift = cos(phase + Double(index) * 0.3) * 0.1
            return shiftHue(of: color, by: hueShift)
        }
    }
    
    private func shiftHue(of color: Color, by amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(color).getHue(&hue,
                              saturation: &saturation,
                              brightness: &brightness,
                              alpha: &alpha)
        
        hue += .init(amount)
        hue = hue.truncatingRemainder(dividingBy: 1.0)
        if hue < 0 { hue += 1 }
        
        return .init(hue: .init(hue),
                     saturation: .init(saturation),
                     brightness: .init(brightness),
                     opacity: .init(alpha))
    }
}
