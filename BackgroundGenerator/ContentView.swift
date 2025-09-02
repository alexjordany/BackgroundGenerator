//
//  ContentView.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 28/8/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    // MARK: - State
    @State private var baseColor: Color = Color(hue: 0.58, saturation: 0.75, brightness: 0.9)
    @State private var width: Int = 1170
    @State private var height: Int = 2532
    @State private var format: OutputFormat = .png
    @State private var colorScheme: ColorScheme = .light
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @State private var bgMode: BackgroundMode = .perceptual
    @State private var gradientColors: [Color] = [
        Color(hue: 0.58, saturation: 0.75, brightness: 0.9),
        Color(hue: 0.65, saturation: 0.70, brightness: 0.85),
        Color(hue: 0.75, saturation: 0.65, brightness: 0.80)
    ]
    @State private var addMaterial: Bool = true

    // dirección combinada: preset + ángulo (el último cambio gana)
    @State private var gradientDirection: GradientDirection = .preset(.topLeading)
    @State private var selectedPreset: GradientDirection.Preset = .topLeading
    @State private var gradientAngle: Double = 120

    let presets: [(String, Int, Int)] = [
        ("iPhone 15 Pro (1290×2796)", 1290, 2796),
        ("iPhone 14/13 (1170×2532)", 1170, 2532),
        ("iPad Pro 12.9 (2048×2732)", 2048, 2732),
        ("Mac 5K (5120×2880)", 5120, 2880),
        ("4K UHD (3840×2160)", 3840, 2160),
        ("8K UHD (7680×4320)", 7680, 4320),
    ]

    // MARK: - Body
    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationTitle("Background Generator")
        } detail: {
            detail
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            export()
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.down")
                        }
                    }
                }
        }
        .frame(minWidth: 980, minHeight: 620)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Sidebar (todos los controles aquí)
    private var sidebar: some View {
        List {
            Section("Background") {
                Picker("Mode", selection: $bgMode.animation(.easeInOut)) {
                    Text("Perceptual").tag(BackgroundMode.perceptual)
                    Text("Linear Gradient").tag(BackgroundMode.linearGradient)
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                if bgMode == .perceptual {
                    ColorPicker("Base Color", selection: $baseColor.animation(), supportsOpacity: false)
                }
            }

            if bgMode == .linearGradient {
                Section(content: {
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(gradientColors.indices, id: \.self) { i in
                                ColorPicker("", selection: Binding(
                                    get: { gradientColors[i] },
                                    set: { gradientColors[i] = $0 }
                                ), supportsOpacity: false)
                                .labelsHidden()
                                .frame(width: 40, height: 28)
                            }
                        }
                    }.animation(.easeInOut, value: gradientColors)

                    Picker(
                        "Direction",
                        selection: Binding(
                            get: {
                                if case .preset(let p) = gradientDirection { return p }
                                return .topLeading
                            },
                            set: { gradientDirection = .preset($0) }
                        ).animation()
                    ) {
                        ForEach(GradientDirection.Preset.allCases) { preset in
                            Text(preset.rawValue.capitalized).tag(preset)
                        }
                    }
                }, header: {
                    HStack{
                        Text("Gradient")
                        Spacer()
                        GlassEffectContainer(spacing: 22, content: {
                            HStack(content: {
                                Button(role: .confirm){
                                    withAnimation{
                                        gradientColors.append(.white)
                                    }
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.blue.gradient)
                                }

                                Button(role: .destructive) {
                                    withAnimation{
                                        if gradientColors.count > 2 { _ = gradientColors.popLast() }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.red.gradient)
                                }
                            }).buttonStyle(.glass)
                            
                        })
                        
                    }
                    
                })
            }

            Section("Overlay") {
                Toggle("Add Material overlay", isOn: $addMaterial.animation())
            }

            Section("Canvas") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack {
                            HStack {
                                Text("Width")
                                TextField("Width", value: $width.animation(), format: .number)
                                    .frame(width: 90)
                                Stepper("Width", value: $width.animation(), in: 64...16000).labelsHidden()
                            }
                            HStack {
                                Text("Height")
                                TextField("Height", value: $height.animation(), format: .number)
                                    .frame(width: 90)
                                Stepper("Height", value: $height.animation(), in: 64...16000).labelsHidden()
                            }
                        }

                        Spacer()

                        // Botón para intercambiar
                        Button {
                            withAnimation{
                                swap(&width, &height)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue.gradient)
                        }
                        .buttonStyle(.borderless) // para que no ocupe todo el HStack
                        .help("Intercambiar Width y Height")
                    }

                    Menu("Presets") {
                        ForEach(presets, id: \.0) { item in
                            Button(item.0) {
                                width = item.1
                                height = item.2
                            }
                        }
                    }
                }
            }


            Section("Appearance") {
                Picker("Mode", selection: $colorScheme) {
                    Text("Light").tag(ColorScheme.light)
                    Text("Dark").tag(ColorScheme.dark)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section("Output") {
                Picker("Format", selection: $format) {
                    ForEach(OutputFormat.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Button {
                    export()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Detail (solo preview limpio)
    private var detail: some View {
        ZStack {
            ScaledPreview(targetWidth: width, targetHeight: height) {
                previewBackground
            }
            .padding(20)

            Text("\(width) × \(height) px")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding(8)
                .background(.thinMaterial, in: Capsule())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }


    // MARK: - Preview builder
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

    // MARK: - Export
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
                colorScheme: colorScheme,
                addMaterial: addMaterial
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
