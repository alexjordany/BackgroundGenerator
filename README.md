# Background Generator

Background Generator is a macOS utility built with SwiftUI for crafting custom wallpapers. It lets you preview and export backgrounds using either a perceptual color blend or a multi-stop linear gradient.

## Features

- **Perceptual mode** – Generate a smooth top-to-bottom gradient from a base color, automatically mixing it with white or black depending on light or dark mode.
- **Linear gradient mode** – Use any number of color stops and select a preset direction or a custom angle.
- **Material overlay** – Optionally add a macOS material layer on top of the background for extra depth.
- **Custom sizes** – Specify the exact width and height or use built‑in presets for common device resolutions.
- **Multiple formats** – Export as PNG, HEIC, or JPEG.
- **Light and dark preview** – See how the background looks in either appearance before exporting.

## Requirements

- macOS
- Xcode

## Building

1. Open `BackgroundGenerator.xcodeproj` in Xcode.
2. Select the **BackgroundGenerator** target.
3. Build and run the app.

## Usage

1. Choose *Perceptual* or *Linear Gradient* as the background mode.
2. Adjust colors, direction, and other options.
3. Set the output dimensions and format.
4. Click **Export** to save the generated image.

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

