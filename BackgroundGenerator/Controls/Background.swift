//
//  Background.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 28/8/25.
//


import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import CoreImage
import AppKit

// MARK: - Background (tu estructura, con mezcla perceptual)
struct Background: View {
    let color: Color
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        LinearGradient(
            colors: [
                color.opacity(0.9),
                blended(color).opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func blended(_ base: Color) -> Color {
        let target: Color = (scheme == .dark) ? .black : .white
        return base.mix(with: target, by: 0.55, in: .perceptual)
    }
}

// MARK: - Utilidades de exportación
enum OutputFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case heic = "HEIC"
    case jpeg = "JPEG"

    var id: String { rawValue }
    var utType: UTType {
        switch self {
        case .png:  return .png
        case .heic: return .heic   // "public.heic"
        case .jpeg: return .jpeg
        }
    }
    var fileExtension: String {
        switch self {
        case .png:  return "png"
        case .heic: return "heic"
        case .jpeg: return "jpg"
        }
    }
}

struct Exporter {
    @MainActor
    static func renderCGImage(
        width: Int,
        height: Int,
        color: Color,
        colorScheme: ColorScheme
    ) -> CGImage? {

        // Construyes la vista con material
        let content = Background(color: color)
            .environment(\.colorScheme, colorScheme)
            .frame(width: CGFloat(width), height: CGFloat(height))
            .overlay(.thinMaterial) // tu material
            .ignoresSafeArea()

        // Host de AppKit para controlar la apariencia
        let hosting = NSHostingView(rootView: AnyView(content))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        hosting.appearance = (colorScheme == .dark)
            ? NSAppearance(named: .darkAqua)
            : NSAppearance(named: .aqua)

        // Snapshot estable
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return nil }
        rep.size = NSSize(width: width, height: height)
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        return rep.cgImage
    }

    static func save(_ cgImage: CGImage, to url: URL, as format: OutputFormat, quality: Double = 0.95) throws {
        let supported = CGImageDestinationCopyTypeIdentifiers() as! [CFString]
        guard supported.contains(format.utType.identifier as CFString) else {
            throw NSError(domain: "WallpaperMaker", code: -10,
                          userInfo: [NSLocalizedDescriptionKey: "\(format.rawValue) no está soportado en este sistema."])
        }
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, format.utType.identifier as CFString, 1, nil) else {
            throw NSError(domain: "WallpaperMaker", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No se pudo crear el destino de imagen."])
        }
        var props: [CFString: Any] = [:]
        if format == .jpeg || format == .heic {
            props[kCGImageDestinationLossyCompressionQuality] = quality
        }
        CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        if !CGImageDestinationFinalize(dest) {
            throw NSError(domain: "WallpaperMaker", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "No se pudo escribir el archivo."])
        }
    }
}

