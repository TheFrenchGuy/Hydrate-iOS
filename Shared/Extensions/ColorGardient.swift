//
//  ColorGardient.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 10/02/2021.
//

import SwiftUI

public struct ColorGradient: Equatable {
    public let startColor: Color
    public let endColor: Color

    public init(_ color: Color) {
        self.startColor = color
        self.endColor = color
    }
    
    public init (_ startColor: Color, _ endColor: Color) {
        self.startColor = startColor
        self.endColor = endColor
    }

    public var gradient: Gradient {
        return Gradient(colors: [startColor, endColor])
    }
}

extension ColorGradient {
    /// Convenience method to return a LinearGradient from the ColorGradient
    /// - Parameters:
    ///   - startPoint: starting point
    ///   - endPoint: ending point
    /// - Returns: a Linear gradient
    public func linearGradient(from startPoint: UnitPoint, to endPoint: UnitPoint) -> LinearGradient {
        return LinearGradient(gradient: self.gradient, startPoint: startPoint, endPoint: endPoint)
    }
}
