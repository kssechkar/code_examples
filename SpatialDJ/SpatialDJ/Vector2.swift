//
//  Vector2.swift
//  SpatialDJ
//
//  Created by Kosta Sechkar on 29.05.2023.
//


import Foundation
import CoreGraphics

public typealias Scalar = CGFloat

public struct Vector2: Hashable {
    public var x: Scalar
    public var y: Scalar
}

public extension Scalar {
    static let halfPi = pi / 2
    static let quarterPi = pi / 4
    static let twoPi = pi * 2
    static let degreesPerRadian = 180 / pi
    static let radiansPerDegree = pi / 180
    static let epsilon: Scalar = 0.0001

    static func ~= (lhs: Scalar, rhs: Scalar) -> Bool {
        return Swift.abs(lhs - rhs) < .epsilon
    }

    fileprivate var sign: Scalar {
        return self > 0 ? 1 : -1
    }
}

public extension Vector2 {
    static let zero = Vector2(0, 0)
    static let x = Vector2(1, 0)
    static let y = Vector2(0, 1)

    var cgVecotr: CGVector {
        return CGVector(dx: self.x, dy: self.y)
    }

    init(_ x: Scalar, _ y: Scalar) {
        self.init(x: x, y: y)
    }

    func rotated(by radians: Scalar) -> Vector2 {
        let cs = cos(radians)
        let sn = sin(radians)
        return Vector2(x * cs - y * sn, x * sn + y * cs)
    }

    func rotated(by radians: Scalar, around pivot: Vector2) -> Vector2 {
        return (self - pivot).rotated(by: radians) + pivot
    }

    func angelBetweenCurrentAnd(vector: Vector2) -> Scalar {
        let v1 = self.cgVecotr
        let v2 = vector.cgVecotr

        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        return angle
    }

    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }
}
