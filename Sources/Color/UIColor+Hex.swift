//
//  UIColor+Hex.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 08/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import UIKit

public extension UIColor {
    public enum HexPrefix {
        case pound
        case hexadecimal
        case custom(String)

        var rawValue: String {
            switch self {
            case .pound:
                return "#"
            case .hexadecimal:
                return "0x"
            case .custom(let prefix):
                return prefix
            }
        }
    }

    public func hex(withAlpha: Bool = false, prefix: HexPrefix = .custom("")) -> String {
        let rgb = rgbInt32(withAlpha: withAlpha)
        let byteCount: UInt8 = withAlpha ? 8 : 6
        let format = "\(prefix.rawValue)%0\(byteCount)x"

        return String(format: format, rgb)
    }

    public func rgbInt32(withAlpha: Bool = false) -> UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Clamp to sRGB
        red = max(0.0, min(red, 1.0))
        green = max(0.0, min(green, 1.0))
        blue = max(0.0, min(blue, 1.0))

        var rgb = UInt32(round(red * 255)) << 16
            | UInt32(round(green * 255)) << 8
            | UInt32(round(blue * 255))

        if withAlpha {
            rgb = (rgb << 8) | UInt32(round(alpha * 255))
        }

        return rgb
    }

    private static let hexRegex: NSRegularExpression = {
        let pattern = "^.*?([0-9a-fA-F]{6,8})"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    public convenience init?(hexString: String) {
        let regex = UIColor.hexRegex
        let fullRange = NSMakeRange(0, hexString.count)

        guard let match = regex.firstMatch(in: hexString, options: [], range: fullRange), match.numberOfRanges == 2 else {
            return nil
        }

        // First match is whole matched string, second is hex characters
        let hexRange = match.range(at: 1)
        let hexBegin = hexString.index(hexString.startIndex, offsetBy: hexRange.location)
        let hexEnd = hexString.index(hexBegin, offsetBy: hexRange.length)
        let hex = String(hexString[hexBegin ..< hexEnd])

        var hexInt: UInt32 = 0
        let scanner = Scanner(string: hex)
        scanner.scanHexInt32(&hexInt)

        let withAlpha = hex.count > 6
        if !withAlpha {
            // When alpha is not present, shift left as if alpha was there so we have a single codepath
            hexInt = hexInt << 8
        }

        let red = CGFloat((hexInt & 0xff000000) >> 24) / 255.0
        let green = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let blue = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let alpha = withAlpha ? CGFloat(hexInt & 0xff) / 255.0 : 1.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
