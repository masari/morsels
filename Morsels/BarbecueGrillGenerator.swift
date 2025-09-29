import SpriteKit
import UIKit

class BarbecueGrillGenerator {
    static let shared = BarbecueGrillGenerator()
    
    private init() {}
    
    private var animationCache: [String: (background: [SKTexture], foreground: [SKTexture])] = [:]

    // New public method to generate layered animation frames
    func generateLayeredAnimationFrames(size: CGSize, frameCount: Int = 4) -> (background: [SKTexture], foreground: [SKTexture]) {
        let cacheKey = "grill_layered_anim_\(Int(size.width))x\(Int(size.height))"
        if let cachedFrames = animationCache[cacheKey] {
            return cachedFrames
        }

        var backgroundFrames: [SKTexture] = []
        var foregroundFrames: [SKTexture] = []

        for _ in 0..<frameCount {
            let (bgTexture, fgTexture) = createLayeredGrillTexture(size: size, isAnimated: true)
            backgroundFrames.append(bgTexture)
            foregroundFrames.append(fgTexture)
        }

        let result = (background: backgroundFrames, foreground: foregroundFrames)
        animationCache[cacheKey] = result
        return result
    }

    // Creates a pair of textures for a single animation frame
    private func createLayeredGrillTexture(size: CGSize, isAnimated: Bool) -> (background: SKTexture, foreground: SKTexture) {
        let renderer = UIGraphicsImageRenderer(size: size)

        // --- Create Background Texture ---
        let backgroundImage = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
            drawBrickBase(ctx: ctx, size: size)
            drawGrillTop(ctx: ctx, size: size)
            // Draw only the background flames
            drawWallOfFire(ctx: ctx, size: size, isAnimated: isAnimated, layer: .background)
        }

        // --- Create Foreground Texture (Transparent) ---
        let foregroundImage = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
            // Draw only the foreground flames
            drawWallOfFire(ctx: ctx, size: size, isAnimated: isAnimated, layer: .foreground)
        }

        return (background: SKTexture(image: backgroundImage), foreground: SKTexture(image: foregroundImage))
    }

    private func drawBrickBase(ctx: CGContext, size: CGSize) {
        let brickRect = CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.4)
        let colors = [
            UIColor(red: 0.7, green: 0.25, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.9, green: 0.4, blue: 0.25, alpha: 1.0).cgColor
        ]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
        ctx.drawLinearGradient(gradient, start: CGPoint(x: brickRect.midX, y: brickRect.minY), end: CGPoint(x: brickRect.midX, y: brickRect.maxY), options: [])
        drawBrickPattern(ctx: ctx, in: brickRect)
        ctx.setStrokeColor(UIColor(red: 0.5, green: 0.15, blue: 0.1, alpha: 1.0).cgColor)
        ctx.setLineWidth(3)
        ctx.stroke(brickRect)
    }
    
    private func drawBrickPattern(ctx: CGContext, in rect: CGRect) {
        let brickWidth: CGFloat = rect.width / 8
        let brickHeight: CGFloat = rect.height / 4
        ctx.setStrokeColor(UIColor(red: 0.4, green: 0.1, blue: 0.05, alpha: 0.8).cgColor)
        ctx.setLineWidth(2)
        for row in 0..<4 {
            let y = rect.minY + (CGFloat(row) * brickHeight)
            let offset = (row % 2 == 0) ? 0 : brickWidth / 2
            ctx.move(to: CGPoint(x: rect.minX, y: y))
            ctx.addLine(to: CGPoint(x: rect.maxX, y: y))
            ctx.strokePath()
            var x = rect.minX + offset
            while x < rect.maxX {
                ctx.move(to: CGPoint(x: x, y: y))
                ctx.addLine(to: CGPoint(x: x, y: y + brickHeight))
                ctx.strokePath()
                x += brickWidth
            }
        }
    }
    
    private func drawGrillTop(ctx: CGContext, size: CGSize) {
        let grateRect = CGRect(x: size.width * 0.02, y: size.height * 0.38, width: size.width * 0.96, height: size.height * 0.05)
        ctx.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
        ctx.fill(grateRect)
        ctx.setStrokeColor(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
        ctx.setLineWidth(2)
        let barSpacing = grateRect.width / 15
        for i in 0...15 {
            let x = grateRect.minX + CGFloat(i) * barSpacing
            ctx.move(to: CGPoint(x: x, y: grateRect.minY))
            ctx.addLine(to: CGPoint(x: x, y: grateRect.maxY))
            ctx.strokePath()
        }
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(2)
        ctx.stroke(grateRect)
    }
    
    private enum FlameLayer { case background, foreground }
    
    private func drawWallOfFire(ctx: CGContext, size: CGSize, isAnimated: Bool, layer: FlameLayer) {
        let flameBaseY = size.height * 0.30
        let flameHeight = size.height * 0.65

        // Define all flames and assign them to a layer
        let flames = [
            // Background Flames
            FlameConfig(x: 0.5, width: 0.4, heightRatio: 1.0, color: UIColor(red: 0.9, green: 0.35, blue: 0.0, alpha: 0.85), layer: .background),
            FlameConfig(x: 0.15, width: 0.25, heightRatio: 0.8, color: UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 0.9), layer: .background),
            FlameConfig(x: 0.85, width: 0.25, heightRatio: 0.8, color: UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 0.9), layer: .background),
            FlameConfig(x: 0.5, width: 0.2, heightRatio: 0.7, color: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0), layer: .background),
            
            // Foreground Flames
            FlameConfig(x: 0.3, width: 0.3, heightRatio: 0.9, color: UIColor(red: 0.9, green: 0.3, blue: 0.0, alpha: 0.8), layer: .foreground),
            FlameConfig(x: 0.7, width: 0.3, heightRatio: 0.9, color: UIColor(red: 0.9, green: 0.3, blue: 0.0, alpha: 0.8), layer: .foreground),
            FlameConfig(x: 0.35, width: 0.2, heightRatio: 0.65, color: UIColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1.0), layer: .foreground),
            FlameConfig(x: 0.65, width: 0.2, heightRatio: 0.65, color: UIColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1.0), layer: .foreground),
        ]
        
        // Filter and draw only the flames for the specified layer
        for flame in flames where flame.layer == layer {
            let heightFlicker = isAnimated ? 1.0 + CGFloat.random(in: -0.2...0.2) : 1.0
            let widthFlicker = isAnimated ? 1.0 + CGFloat.random(in: -0.15...0.15) : 1.0
            let xFlicker = isAnimated ? CGFloat.random(in: -8...8) : 0
            
            drawOrganicFlame(ctx: ctx,
                             centerX: (size.width * flame.x) + xFlicker,
                             baseY: flameBaseY,
                             width: (size.width * flame.width) * widthFlicker,
                             height: (flameHeight * flame.heightRatio) * heightFlicker,
                             color: flame.color)
        }
    }
    
    private struct FlameConfig {
        let x, width, heightRatio: CGFloat
        let color: UIColor
        let layer: FlameLayer
    }
    
    private func drawOrganicFlame(ctx: CGContext, centerX: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        ctx.setFillColor(color.cgColor)
        let path = CGMutablePath()

        let peakPoint = CGPoint(x: centerX, y: baseY + height)
        let leftBasePoint = CGPoint(x: centerX - width / 2, y: baseY)
        let rightBasePoint = CGPoint(x: centerX + width / 2, y: baseY)

        // Lower the control points slightly from the peak to create a gentle curve
        let peakYControl = peakPoint.y - height * 0.2
        let peakControlOffset = width * 0.3

        path.move(to: leftBasePoint)
        
        path.addCurve(to: peakPoint,
                      control1: CGPoint(x: centerX - width * 0.4, y: baseY + height * 0.25),
                      control2: CGPoint(x: peakPoint.x - peakControlOffset, y: peakYControl))
        
        path.addCurve(to: rightBasePoint,
                      control1: CGPoint(x: peakPoint.x + peakControlOffset, y: peakYControl),
                      control2: CGPoint(x: centerX + width * 0.4, y: baseY + height * 0.25))

        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}