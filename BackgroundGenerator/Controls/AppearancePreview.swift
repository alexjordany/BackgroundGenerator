//
//  AppearancePreview.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 28/8/25.
//


import SwiftUI
import AppKit

struct AppearancePreview<Content: View>: NSViewRepresentable {
    var colorScheme: ColorScheme
    @ViewBuilder var content: () -> Content

    func makeNSView(context: Context) -> NSHostingView<Content> {
        let v = NSHostingView(rootView: content())
        v.appearance = (colorScheme == .dark)
            ? NSAppearance(named: .darkAqua)
            : NSAppearance(named: .aqua)
        return v
    }

    func updateNSView(_ v: NSHostingView<Content>, context: Context) {
        v.rootView = content()
        v.appearance = (colorScheme == .dark)
            ? NSAppearance(named: .darkAqua)
            : NSAppearance(named: .aqua)
    }
}
