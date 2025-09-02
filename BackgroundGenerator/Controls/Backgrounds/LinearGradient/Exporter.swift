//
//  Exporter.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//

import Foundation
import SwiftUI
import AppKit
import CoreGraphics
import UniformTypeIdentifiers

extension Exporter {
    @MainActor
    static func renderLinearGradientCGImage(
        width: Int,
        height: Int,
        colors: [Color],
        direction: GradientDirection,
        colorScheme: ColorScheme,
        addMaterial: Bool = true
    ) -> CGImage? {

        let se = direction.startEnd
        let content = LinearGradientBackground(
            colors: colors,
            startPoint: se.0,
            endPoint: se.1,
            addMaterial: addMaterial
        )
        .environment(\.colorScheme, colorScheme)
        .frame(width: CGFloat(width), height: CGFloat(height))
        .ignoresSafeArea()

        let hosting = NSHostingView(rootView: AnyView(content))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        hosting.appearance = (colorScheme == .dark)
            ? NSAppearance(named: .darkAqua)
            : NSAppearance(named: .aqua)

        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return nil }
        rep.size = NSSize(width: width, height: height)
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        return rep.cgImage
    }
}
