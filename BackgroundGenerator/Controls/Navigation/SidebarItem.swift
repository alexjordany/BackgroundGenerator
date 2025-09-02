//
//  SidebarItem.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//

import Foundation
enum SidebarItem: Hashable, CaseIterable {
    case preview
    case background
    case gradient
    case dimensions
    case output
    case appearance
    case overlay
    case presets

    var title: String {
        switch self {
        case .preview:    return "Preview"
        case .background: return "Background"
        case .gradient:   return "Gradient"
        case .dimensions: return "Dimensions"
        case .output:     return "Output"
        case .appearance: return "Appearance"
        case .overlay:    return "Overlay"
        case .presets:    return "Presets"
        }
    }
}
