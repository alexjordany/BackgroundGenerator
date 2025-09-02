//
//  BackgroundMode.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//


enum BackgroundMode: String, CaseIterable, Identifiable {
    case perceptual // tu Background(color:)
    case linearGradient
    var id: String { rawValue }
}
