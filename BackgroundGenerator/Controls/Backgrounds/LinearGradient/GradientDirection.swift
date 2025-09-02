//
//  GradientDirection.swift
//  BackgroundGenerator
//
//  Created by Alex Parrales on 1/9/25.
//
import SwiftUI

enum GradientDirection {
    case points(start: UnitPoint, end: UnitPoint)
    case preset(Preset)
    case angle(Double)

    enum Preset: String, CaseIterable, Identifiable {
        case top, bottom, leading, trailing
        case topLeading, topTrailing, bottomLeading, bottomTrailing

        var id: String { rawValue }

        var startEnd: (UnitPoint, UnitPoint) {
            switch self {
            case .top:            return (.top, .bottom)
            case .bottom:         return (.bottom, .top)
            case .leading:        return (.leading, .trailing)
            case .trailing:       return (.trailing, .leading)
            case .topLeading:     return (.topLeading, .bottomTrailing)
            case .topTrailing:    return (.topTrailing, .bottomLeading)
            case .bottomLeading:  return (.bottomLeading, .topTrailing)
            case .bottomTrailing: return (.bottomTrailing, .topLeading)
            }
        }
    }

    var startEnd: (UnitPoint, UnitPoint) {
        switch self {
        case .points(let s, let e):
            return (s, e)
        case .preset(let p):
            return p.startEnd
        case .angle(let degrees):
            let rad = degrees * .pi / 180
            let dx = cos(rad)
            let dy = sin(rad)
            let big: CGFloat = 10_000
            let cx: CGFloat = 0.5, cy: CGFloat = 0.5
            let start = UnitPoint(x: cx - big * dx, y: cy - big * dy)
            let end   = UnitPoint(x: cx + big * dx, y: cy + big * dy)
            return (start, end)
        }
    }
}

// MARK: - Equatable conformance
extension GradientDirection: Equatable {
    static func == (lhs: GradientDirection, rhs: GradientDirection) -> Bool {
        switch (lhs, rhs) {
        case let (.preset(lp), .preset(rp)):
            return lp == rp
        case let (.angle(la), .angle(ra)):
            return la == ra
        case let (.points(ls, le), .points(rs, re)):
            // UnitPoint doesn't conform to Equatable; compare by coordinates
            return ls.x == rs.x && ls.y == rs.y && le.x == re.x && le.y == re.y
        default:
            return false
        }
    }
}
