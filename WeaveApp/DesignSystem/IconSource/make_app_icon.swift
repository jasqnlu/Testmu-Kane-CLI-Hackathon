// Not part of the app target. Regenerates the AppIcon PNGs:
//   swift WeaveApp/DesignSystem/IconSource/make_app_icon.swift WeaveApp/DesignSystem/DesignAssets.xcassets/AppIcon.appiconset
// Draws the Weave app icon: three pastel rings, woven so each ring passes
// over one neighbour and under the other (Borromean pattern).
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

let size = 1024.0, radius = 176.0, line = 74.0, gap = 14.0, spread = 124.0
let mid = CGPoint(x: size / 2, y: size / 2 - 10)
// Ring centers on a triangle: top, lower right, lower left (CG y points up).
let centers = [90.0, -30.0, 210.0].map { deg -> CGPoint in
    let a = deg * .pi / 180
    return CGPoint(x: mid.x + spread * cos(a), y: mid.y + spread * sin(a))
}

func intersections(_ a: CGPoint, _ b: CGPoint) -> [CGPoint] {
    let dx = b.x - a.x, dy = b.y - a.y, d = (dx * dx + dy * dy).squareRoot()
    let h = (radius * radius - d * d / 4).squareRoot()
    let m = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    return [CGPoint(x: m.x + h * dy / d, y: m.y - h * dx / d), CGPoint(x: m.x - h * dy / d, y: m.y + h * dx / d)]
}

func render(background: CGColor, rings: [CGColor], to url: URL) {
    let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setFillColor(background); ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
    ctx.setLineCap(.round)

    func ring(_ i: Int, color: CGColor, width: CGFloat) {
        ctx.setStrokeColor(color); ctx.setLineWidth(width)
        ctx.strokeEllipse(in: CGRect(x: centers[i].x - radius, y: centers[i].y - radius, width: radius * 2, height: radius * 2))
    }

    for i in 0..<3 { ring(i, color: rings[i], width: line) }

    func ringPath(_ i: Int) -> CGPath {
        CGPath(ellipseIn: CGRect(x: centers[i].x - radius, y: centers[i].y - radius, width: radius * 2, height: radius * 2), transform: nil)
    }

    // Ring i goes over ring (i+1)%3 at both of their crossings.
    for i in 0..<3 {
        let under = (i + 1) % 3
        for p in intersections(centers[i], centers[under]) {
            let disk = CGRect(x: p.x - line * 1.5, y: p.y - line * 1.5, width: line * 3, height: line * 3)
            // 1. Cut a gap into the under ring only, so no seam lands on the background.
            ctx.saveGState()
            ctx.addEllipse(in: disk); ctx.clip()
            ctx.addPath(ringPath(under).copy(strokingWithWidth: line - 1, lineCap: .butt, lineJoin: .miter, miterLimit: 10)); ctx.clip()
            ring(i, color: background, width: line + 2 * gap)
            ctx.restoreGState()
            // 2. Redraw the over ring. Same color over itself, so the clip edge is invisible.
            ctx.saveGState()
            ctx.addEllipse(in: disk); ctx.clip()
            ring(i, color: rings[i], width: line)
            ctx.restoreGState()
        }
    }

    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil); CGImageDestinationFinalize(dest)
}

let out = URL(fileURLWithPath: CommandLine.arguments[1])
let pastels = [rgb(0x8EDCBC), rgb(0xA3ADFF), rgb(0xFFC98F)]   // mint, periwinkle, peach
render(background: rgb(0x2D6A4F), rings: pastels, to: out.appendingPathComponent("AppIcon.png"))
render(background: rgb(0x0B0B0C), rings: pastels, to: out.appendingPathComponent("AppIcon-Dark.png"))
render(background: rgb(0x000000), rings: [rgb(0xFFFFFF), rgb(0xC8C8C8), rgb(0x969696)],
       to: out.appendingPathComponent("AppIcon-Tinted.png"))
