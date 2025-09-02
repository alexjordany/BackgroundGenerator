//
//  ScaledPreview.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//

import SwiftUI
import Foundation

struct ScaledPreview<Content: View>: View {
    let targetWidth: Int
    let targetHeight: Int
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let aspect = CGFloat(max(targetWidth, 1)) / CGFloat(max(targetHeight, 1))
            let maxW = geo.size.width
            let maxH = geo.size.height

            // Ajuste para encajar (letterbox si hace falta)
            let fitW = min(maxW, maxH * aspect)
            let fitH = fitW / aspect

            ZStack {
                content()
                    .frame(width: fitW, height: fitH)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08)))
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}
