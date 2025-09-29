import SpriteKit
import UIKit

class PigpenGenerator {
    static let shared = PigpenGenerator()
    private var textureCache: SKTexture?

    private init() {}

    /// Generates and caches a texture for the pigpen.
    func generatePigpenTexture(size: CGSize) -> SKTexture {
        if let cachedTexture = textureCache {
            return cachedTexture
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Flip coordinates for SpriteKit's bottom-left origin
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)

            drawClouds(ctx: ctx, size: size)
            drawFence(ctx: ctx, size: size)
        }

        let texture = SKTexture(image: image)
        textureCache = texture
        return texture
    }

    /// Draws a series of fluffy clouds to serve as the base of the pigpen.
    private func drawClouds(ctx: CGContext, size: CGSize) {
        let cloudColor = UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 0.9)
        ctx.setFillColor(cloudColor.cgColor)

        // Draw multiple overlapping ellipses to create a cloud shape
        let cloudPositions = [
            CGRect(x: size.width * 0.05, y: size.height * 0.1, width: size.width * 0.3, height: size.height * 0.5),
            CGRect(x: size.width * 0.25, y: size.height * 0.05, width: size.width * 0.5, height: size.height * 0.6),
            CGRect(x: size.width * 0.6, y: size.height * 0.1, width: size.width * 0.35, height: size.height * 0.45),
            CGRect(x: size.width * 0.4, y: size.height * 0.2, width: size.width * 0.2, height: size.height * 0.4)
        ]

        for rect in cloudPositions {
            ctx.fillEllipse(in: rect)
        }
    }

    /// Draws a simple wooden fence on top of the clouds.
    private func drawFence(ctx: CGContext, size: CGSize) {
        let woodColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        let darkWoodColor = UIColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
        
        ctx.setStrokeColor(darkWoodColor.cgColor)
        ctx.setLineWidth(4)
        ctx.setLineCap(.round)

        let fenceHeight = size.height * 0.6
        let postWidth: CGFloat = 15
        let postCount = 6
        let postSpacing = (size.width - (CGFloat(postCount) * postWidth)) / CGFloat(postCount - 1)

        // Draw vertical fence posts
        for i in 0..<postCount {
            let x = (postWidth + postSpacing) * CGFloat(i) + (postWidth / 2)
            let postRect = CGRect(x: x, y: fenceHeight, width: postWidth, height: size.height * 0.3)
            ctx.setFillColor(woodColor.cgColor)
            ctx.fill(postRect)
            ctx.stroke(postRect)
        }
        
        // Draw horizontal fence rails
        let railRect1 = CGRect(x: 0, y: fenceHeight + 10, width: size.width, height: postWidth)
        let railRect2 = CGRect(x: 0, y: fenceHeight + 40, width: size.width, height: postWidth)
        
        ctx.setFillColor(woodColor.cgColor)
        ctx.fill(railRect1)
        ctx.stroke(railRect1)
        ctx.fill(railRect2)
        ctx.stroke(railRect2)
    }
}