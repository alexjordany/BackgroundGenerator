//
//  LinearGradientBackground.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//


import SwiftUI

struct LinearGradientBackground: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    var addMaterial: Bool = true

    var body: some View {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
            .overlay(addMaterial ? AnyView(Rectangle().fill(.thinMaterial)) : AnyView(EmptyView()))
    }
}
