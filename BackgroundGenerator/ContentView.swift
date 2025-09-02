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
    @State private var width: Int = 1170
    @State private var height: Int = 2532
    @State private var format: OutputFormat = .png
    @State private var colorScheme: ColorScheme = .light
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    // Nuevo estado para el gradiente
    @State private var bgMode: BackgroundMode = .perceptual
    @State private var gradientColors: [Color] = [
        Color(hue: 0.58, saturation: 0.75, brightness: 0.9),
        Color(hue: 0.65, saturation: 0.70, brightness: 0.85),
        Color(hue: 0.75, saturation: 0.65, brightness: 0.80)
    ]
    @State private var gradientAngle: Double = 120 // grados
    @State private var addMaterial: Bool = true

    let presets: [(String, Int, Int)] = [
        ("iPhone 15 Pro (1290×2796)", 1290, 2796),
        ("iPhone 14/13 (1170×2532)", 1170, 2532),
        ("iPad Pro 12.9 (2048×2732)", 2048, 2732),
        ("Mac 5K (5120×2880)", 5120, 2880),
        ("4K UHD (3840×2160)", 3840, 2160),
        ("8K UHD (7680×4320)", 7680, 4320),
    ]
    
    @State private var gradientDirection: GradientDirection = .preset(.topLeading)
    @State private var selectedPreset: GradientDirection.Preset = .topLeading

    var body: some View {
        VStack(spacing: 16) {
            // Preview
            AppearancePreview(colorScheme: colorScheme) {
                ZStack {
                    previewBackground
                        .frame(maxWidth: .infinity, maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08)))

                    Text("\(width) × \(height) px")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(8)
                        .background(.thinMaterial, in: Capsule())
                }
                .frame(height: 240)
            }

            // Controles
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Background").font(.headline)
                    Picker("Background", selection: $bgMode) {
                        Text("Perceptual").tag(BackgroundMode.perceptual)
                        Text("Linear Gradient").tag(BackgroundMode.linearGradient)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)
                    .labelsHidden()
                }

                if bgMode == .perceptual {
                    VStack(alignment: .leading) {
                        Text("Base Color").font(.headline)
                        ColorPicker("Base Color", selection: $baseColor, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 160)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gradient Stops").font(.headline)
                        HStack {
                            ForEach(gradientColors.indices, id: \.self) { i in
                                ColorPicker("", selection: Binding(
                                    get: { gradientColors[i] },
                                    set: { gradientColors[i] = $0 }
                                ), supportsOpacity: false)
                                .labelsHidden()
                                .frame(width: 40)
                            }
                            Button {
                                gradientColors.append(.white)
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .help("Agregar stop")
                            Button(role: .destructive) {
                                if gradientColors.count > 2 { _ = gradientColors.popLast() }
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .help("Quitar último stop")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Direction").font(.headline)
                            Picker("Direction", selection: Binding(
                                get: {
                                    if case .preset(let p) = gradientDirection { return p }
                                    return .topLeading
                                },
                                set: { gradientDirection = .preset($0) }
                            )) {
                                ForEach(GradientDirection.Preset.allCases) { preset in
                                    Text(preset.rawValue.capitalized).tag(preset)
                                }
                            }
                            .frame(width: 220)
                            .pickerStyle(.menu)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overlay").font(.headline)
                            Toggle("Add Material overlay", isOn: $addMaterial)
                                .toggleStyle(.switch)
                                .frame(width: 220)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Dimensions (px)").font(.headline)
                    HStack {
                        TextField("Width", value: $width, format: .number).frame(width: 80)
                        Stepper("Width", value: $width, in: 64...16000, step: 1).labelsHidden()
                        TextField("Height", value: $height, format: .number).frame(width: 80)
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
        .frame(minWidth: 960)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    @ViewBuilder
    private var previewBackground: some View {
        switch bgMode {
        case .perceptual:
            Background(color: baseColor)
                .environment(\.colorScheme, colorScheme)
                .overlay(addMaterial ? AnyView(Rectangle().fill(.thinMaterial)) : AnyView(EmptyView()))
        case .linearGradient:
            let se = gradientDirection.startEnd
            LinearGradientBackground(
                colors: gradientColors,
                startPoint: se.0,
                endPoint: se.1,
                addMaterial: addMaterial
            )
            .environment(\.colorScheme, colorScheme)
        }
    }



    @MainActor
    private func export() {
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

        let cg: CGImage?
        switch bgMode {
        case .perceptual:
            cg = Exporter.renderCGImage(
                width: width,
                height: height,
                color: baseColor,
                colorScheme: colorScheme, addMaterial: addMaterial
            )
        case .linearGradient:
            cg = Exporter.renderLinearGradientCGImage(
                width: width,
                height: height,
                colors: gradientColors,
                direction: gradientDirection,
                colorScheme: colorScheme,
                addMaterial: addMaterial
            )

        }

        guard let cg else {
            alertMessage = "Failed to render the image."
            showAlert = true
            return
        }

        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = defaultFileName()
        panel.directoryURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        panel.allowedContentTypes = [format.utType]
        if panel.runModal() == .OK, var url = panel.url {
            if url.pathExtension.isEmpty {
                url.appendPathExtension(format.fileExtension)
            }
            do { try Exporter.save(cg, to: url, as: format, quality: 0.97) }
            catch {
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
