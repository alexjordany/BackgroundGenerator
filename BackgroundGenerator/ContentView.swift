//
//  ContentView.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 28/8/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var baseColor: Color = Color(hue: 0.58, saturation: 0.75, brightness: 0.9)
    @State private var width: Int = 1170   // iPhone 13, 14
    @State private var height: Int = 2532
    @State private var format: OutputFormat = .png
    @State private var colorScheme: ColorScheme = .light
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let presets: [(String, Int, Int)] = [
        ("iPhone 15 Pro (1290×2796)", 1290, 2796),
        ("iPhone 14/13 (1170×2532)", 1170, 2532),
        ("iPad Pro 12.9 (2048×2732)", 2048, 2732),
        ("Mac 5K (5120×2880)", 5120, 2880),
        ("4K UHD (3840×2160)", 3840, 2160),
        ("8K UHD (7680×4320)", 7680, 4320)
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Scaled preview
            AppearancePreview(colorScheme: colorScheme) {
                ZStack {
                    Background(color: baseColor)
                        .environment(\.colorScheme, colorScheme)
                        .frame(maxWidth: .infinity, maxHeight: 240)
                        .overlay(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08)))

                    Text("\(width) × \(height) px")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(8)
                        .background(.thinMaterial, in: Capsule())
                }
                .frame(height: 240)
            }

            // Controls
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Base Color")
                        .font(.headline)
                    ColorPicker("Base Color", selection: $baseColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 160)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Dimensions (px)").font(.headline)
                    HStack {
                        TextField("Width", value: $width, format: .number)
                            .frame(width: 80)
                        Stepper("Width", value: $width, in: 64...16000, step: 1).labelsHidden()
                        TextField("Height", value: $height, format: .number)
                            .frame(width: 80)
                        Stepper("Height", value: $height, in: 64...16000, step: 1).labelsHidden()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Format").font(.headline)
                    Picker("Format", selection: $format) {
                        ForEach(OutputFormat.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mode").font(.headline)
                    Picker("Mode", selection: $colorScheme) {
                        Text("Light").tag(ColorScheme.light)
                        Text("Dark").tag(ColorScheme.dark)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }

            HStack {
                Menu("Presets") {
                    ForEach(presets, id: \.0) { item in
                        Button(item.0) {
                            width = item.1
                            height = item.2
                        }
                    }
                }

                Spacer()

                Button {
                    export()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 860)
        .alert("Error", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(alertMessage)
        })
    }

    @MainActor
    private func export() {
        // Prevent NSSavePanel in Xcode Previews
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            alertMessage = "File saving is not available in Preview."
            showAlert = true
            return
        }

        guard width > 0, height > 0 else {
            alertMessage = "Dimensions must be greater than zero."
            showAlert = true
            return
        }

        guard let cg = Exporter.renderCGImage(
            width: width,
            height: height,
            color: baseColor,
            colorScheme: colorScheme
        ) else {
            alertMessage = "Failed to render the image."
            showAlert = true
            return
        }

        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = defaultFileName()
        panel.directoryURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first

        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [format.utType]
        } else {
            panel.allowedFileTypes = [format.fileExtension]
        }

        if panel.runModal() == .OK, var url = panel.url {
            if url.pathExtension.isEmpty {
                url.appendPathExtension(format.fileExtension)
            }
            do {
                try Exporter.save(cg, to: url, as: format, quality: 0.97)
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func defaultFileName() -> String {
        "Wallpaper_\(width)x\(height).\(format.fileExtension)"
    }
}

#Preview {
    ContentView()
}
