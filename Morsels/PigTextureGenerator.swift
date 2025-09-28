import SpriteKit
import SwiftUI

class PigTextureGenerator {
    static let shared = PigTextureGenerator()
    
    private init() {}
    
    // Cache for generated textures to improve performance
    private var textureCache: [String: SKTexture] = [:]
    
    /// Device-appropriate size scaling
    private var deviceScale: CGFloat {
        let screenScale = UIScreen.main.scale
        let screenBounds = UIScreen.main.bounds
        let screenSize = max(screenBounds.width, screenBounds.height)
        
        // Scale based on device size and pixel density
        if screenSize >= 1024 { // iPad
            return screenScale * 1.2
        } else if screenSize >= 667 { // Large phones
            return screenScale
        } else { // Smaller phones
            return screenScale * 0.9
        }
    }
    
    /// Optimal pig size for current device
    var recommendedPigSize: CGSize {
        let baseSize: CGFloat = 80
        let scaledSize = baseSize * deviceScale / UIScreen.main.scale
        return CGSize(width: scaledSize, height: scaledSize)
    }
    
    /// Generates a texture for a pig with the given letter and size
    func generatePigTexture(for letter: Character, size: CGSize) -> SKTexture {
        let cacheKey = "\(letter)_\(Int(size.width))x\(Int(size.height))"
        
        // Return cached texture if available
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        // Create the texture using Core Graphics for reliability
        let texture = createPigTextureWithCoreGraphics(letter: letter, size: size)
        
        // Cache the texture
        textureCache[cacheKey] = texture
        
        return texture
    }
    
    /// Creates a pig texture using Core Graphics for better performance and reliability
    private func createPigTextureWithCoreGraphics(letter: Character, size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Clear background
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
            
            // Draw pig body (more oval, less circular)
            let bodyRect = CGRect(
                x: size.width * 0.1,
                y: size.height * 0.35,
                width: size.width * 0.8,
                height: size.height * 0.45
            )
            ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor) // Light pink
            ctx.fillEllipse(in: bodyRect)
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
            ctx.setLineWidth(1)
            ctx.strokeEllipse(in: bodyRect)
            
            // Draw pig head (more rounded, proper pig proportions)
            let headRect = CGRect(
                x: size.width * 0.2,
                y: size.height * 0.15,
                width: size.width * 0.6,
                height: size.height * 0.5
            )
            ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: headRect)
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
            ctx.strokeEllipse(in: headRect)
            
            // Draw proper pig snout (more prominent and pig-like)
            let snoutRect = CGRect(
                x: size.width * 0.35,
                y: size.height * 0.3,
                width: size.width * 0.3,
                height: size.height * 0.2
            )
            ctx.setFillColor(UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0).cgColor) // Darker pink
            ctx.fillEllipse(in: snoutRect)
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            ctx.setLineWidth(1)
            ctx.strokeEllipse(in: snoutRect)
            
            // Draw nostrils (larger and more pig-like)
            let nostrilSize = size.width * 0.025
            ctx.setFillColor(UIColor.black.cgColor)
            // Left nostril
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.42 - nostrilSize/2,
                y: size.height * 0.37,
                width: nostrilSize,
                height: nostrilSize * 0.7 // Oval nostrils
            ))
            // Right nostril
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.58 - nostrilSize/2,
                y: size.height * 0.37,
                width: nostrilSize,
                height: nostrilSize * 0.7
            ))
            
            // Draw pig eyes (smaller and more pig-like)
            let eyeSize = size.width * 0.06
            // Left eye white
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.35 - eyeSize/2,
                y: size.height * 0.22,
                width: eyeSize,
                height: eyeSize
            ))
            // Left eye pupil
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.35 - eyeSize/4,
                y: size.height * 0.24,
                width: eyeSize/2,
                height: eyeSize/2
            ))
            // Eye highlight
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.34,
                y: size.height * 0.23,
                width: eyeSize/4,
                height: eyeSize/4
            ))
            
            // Right eye white
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.65 - eyeSize/2,
                y: size.height * 0.22,
                width: eyeSize,
                height: eyeSize
            ))
            // Right eye pupil
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.65 - eyeSize/4,
                y: size.height * 0.24,
                width: eyeSize/2,
                height: eyeSize/2
            ))
            // Eye highlight
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(
                x: size.width * 0.64,
                y: size.height * 0.23,
                width: eyeSize/4,
                height: eyeSize/4
            ))
            
            // Draw pig ears (more triangular and droopy)
            let earWidth = size.width * 0.15
            let earHeight = size.height * 0.2
            ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
            
            // Left ear (triangle-ish)
            ctx.saveGState()
            ctx.translateBy(x: size.width * 0.25, y: size.height * 0.1)
            ctx.rotate(by: -0.3) // Tilt left
            let leftEarRect = CGRect(x: -earWidth/2, y: 0, width: earWidth, height: earHeight)
            ctx.fillEllipse(in: leftEarRect)
            ctx.restoreGState()
            
            // Right ear (triangle-ish)
            ctx.saveGState()
            ctx.translateBy(x: size.width * 0.75, y: size.height * 0.1)
            ctx.rotate(by: 0.3) // Tilt right
            let rightEarRect = CGRect(x: -earWidth/2, y: 0, width: earWidth, height: earHeight)
            ctx.fillEllipse(in: rightEarRect)
            ctx.restoreGState()
            
            // Draw curly pig tail
            drawCurlyTail(ctx: ctx, size: size)
            
            // Draw wings
            drawWing(ctx: ctx, size: size, isLeft: true, wingsUp: true)
            drawWing(ctx: ctx, size: size, isLeft: false, wingsUp: true)
            
            // Draw pig legs (more stubby and pig-like)
            let legWidth = size.width * 0.06
            ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
            
            // Draw legs with rounded caps (hooves)
            ctx.setLineCap(.round)
            ctx.setLineWidth(legWidth)
            ctx.setStrokeColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
            
            // Front left leg
            ctx.move(to: CGPoint(x: size.width * 0.32, y: size.height * 0.78))
            ctx.addLine(to: CGPoint(x: size.width * 0.32, y: size.height * 0.90))
            ctx.strokePath()
            
            // Front right leg
            ctx.move(to: CGPoint(x: size.width * 0.68, y: size.height * 0.78))
            ctx.addLine(to: CGPoint(x: size.width * 0.68, y: size.height * 0.90))
            ctx.strokePath()
            
            // Back left leg (partially hidden)
            ctx.move(to: CGPoint(x: size.width * 0.25, y: size.height * 0.78))
            ctx.addLine(to: CGPoint(x: size.width * 0.25, y: size.height * 0.88))
            ctx.strokePath()
            
            // Back right leg (partially hidden)
            ctx.move(to: CGPoint(x: size.width * 0.75, y: size.height * 0.78))
            ctx.addLine(to: CGPoint(x: size.width * 0.75, y: size.height * 0.88))
            ctx.strokePath()
            
            // Draw hooves
            ctx.setFillColor(UIColor.black.cgColor)
            let hoofSize = size.width * 0.04
            ctx.fillEllipse(in: CGRect(x: size.width * 0.32 - hoofSize/2, y: size.height * 0.88, width: hoofSize, height: hoofSize * 0.6))
            ctx.fillEllipse(in: CGRect(x: size.width * 0.68 - hoofSize/2, y: size.height * 0.88, width: hoofSize, height: hoofSize * 0.6))
            ctx.fillEllipse(in: CGRect(x: size.width * 0.25 - hoofSize/2, y: size.height * 0.86, width: hoofSize, height: hoofSize * 0.6))
            ctx.fillEllipse(in: CGRect(x: size.width * 0.75 - hoofSize/2, y: size.height * 0.86, width: hoofSize, height: hoofSize * 0.6))
            
            // Draw sign
            let signRect = CGRect(
                x: size.width * 0.1,
                y: size.height * 0.82,
                width: size.width * 0.8,
                height: size.height * 0.35
            )
            
            // Sign background (wood texture)
            ctx.setFillColor(UIColor(red: 0.85, green: 0.65, blue: 0.45, alpha: 1.0).cgColor)
            ctx.fill(signRect)
            
            // Sign border (thicker for better visibility)
            ctx.setStrokeColor(UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0).cgColor)
            ctx.setLineWidth(4)
            ctx.stroke(signRect)
            
            // Wood grain effect
            ctx.setStrokeColor(UIColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.6).cgColor)
            ctx.setLineWidth(1.5)
            for i in 0..<4 {
                let y = signRect.minY + signRect.height * (0.15 + CGFloat(i) * 0.25)
                ctx.move(to: CGPoint(x: signRect.minX + signRect.width * 0.05, y: y))
                ctx.addLine(to: CGPoint(x: signRect.maxX - signRect.width * 0.05, y: y))
                ctx.strokePath()
            }
            
            // Add wood corner details
            let cornerSize = size.width * 0.02
            ctx.setFillColor(UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)
            // Top corners
            ctx.fillEllipse(in: CGRect(x: signRect.minX + cornerSize, y: signRect.minY + cornerSize, width: cornerSize, height: cornerSize))
            ctx.fillEllipse(in: CGRect(x: signRect.maxX - cornerSize*2, y: signRect.minY + cornerSize, width: cornerSize, height: cornerSize))
            // Bottom corners
            ctx.fillEllipse(in: CGRect(x: signRect.minX + cornerSize, y: signRect.maxY - cornerSize*2, width: cornerSize, height: cornerSize))
            ctx.fillEllipse(in: CGRect(x: signRect.maxX - cornerSize*2, y: signRect.maxY - cornerSize*2, width: cornerSize, height: cornerSize))
            
            // Sign post (thicker and more visible)
            let postRect = CGRect(
                x: size.width * 0.45,
                y: size.height * 0.75,
                width: size.width * 0.1,
                height: size.height * 0.12
            )
            ctx.setFillColor(UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)
            ctx.fill(postRect)
            
            // Post highlights
            ctx.setStrokeColor(UIColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.8).cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: postRect.minX + postRect.width * 0.2, y: postRect.minY))
            ctx.addLine(to: CGPoint(x: postRect.minX + postRect.width * 0.2, y: postRect.maxY))
            ctx.strokePath()
        }
        
        // Add letter to image using UILabel
        let finalImage = addLetterToImage(image, letter: letter, size: size)
        
        let texture = SKTexture(image: finalImage)
        texture.filteringMode = .linear
        return texture
    }
    
    private func drawCurlyTail(ctx: CGContext, size: CGSize) {
        ctx.setStrokeColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
        ctx.setLineWidth(size.width * 0.02)
        ctx.setLineCap(.round)
        
        // Draw a curly tail starting from the back of the pig
        let startX = size.width * 0.85
        let startY = size.height * 0.5
        
        ctx.move(to: CGPoint(x: startX, y: startY))
        
        // Create a spiral/curly path
        let center = CGPoint(x: startX + size.width * 0.05, y: startY - size.height * 0.05)
        let radius1 = size.width * 0.04
        let radius2 = size.width * 0.02
        
        // First curl (outer)
        ctx.addQuadCurve(
            to: CGPoint(x: center.x + radius1, y: center.y),
            control: CGPoint(x: center.x + radius1, y: center.y - radius1)
        )
        
        // Second curl (inner)
        ctx.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y + radius2),
            control: CGPoint(x: center.x - radius1, y: center.y)
        )
        
        // Final curl tip
        ctx.addQuadCurve(
            to: CGPoint(x: center.x - radius2, y: center.y),
            control: CGPoint(x: center.x, y: center.y - radius2)
        )
        
        ctx.strokePath()
    }

    private func drawWing(ctx: CGContext, size: CGSize, isLeft: Bool, wingsUp: Bool) {
        let wingWidth = size.width * 0.3
        let wingHeight = size.height * 0.4
        let centerX = isLeft ? size.width * 0.2 : size.width * 0.8
        let centerY = size.height * 0.42
        
        // Create wing path
        ctx.saveGState()
        ctx.translateBy(x: centerX, y: centerY)
        
        let angle: CGFloat = wingsUp ? (isLeft ? -0.7 : 0.7) : (isLeft ? -0.1 : 0.1)
        ctx.rotate(by: angle)
        
        // Draw wing using enhanced feather design
        drawEnhancedFeatheredWing(ctx: ctx, width: wingWidth, height: wingHeight, isLeft: isLeft)
        
        ctx.restoreGState()
    }
    
    private func drawEnhancedFeatheredWing(ctx: CGContext, width: CGFloat, height: CGFloat, isLeft: Bool) {
        // Create more realistic wing shape with multiple feather sections
        
        // MAIN WING BODY
        let mainWingPath = CGMutablePath()
        mainWingPath.move(to: CGPoint(x: 0, y: height * 0.25))
        
        // Leading edge (top of wing) - smooth curve
        mainWingPath.addQuadCurve(
            to: CGPoint(x: width * 0.85, y: -height * 0.15),
            control: CGPoint(x: width * 0.45, y: -height * 0.45)
        )
        
        // Wing tip - sharp point
        mainWingPath.addQuadCurve(
            to: CGPoint(x: width * 0.95, y: height * 0.05),
            control: CGPoint(x: width * 1.02, y: -height * 0.05)
        )
        
        // Primary feathers trailing edge (scalloped)
        let primaryFeatherCount = 6
        for i in 0...primaryFeatherCount {
            let progress = CGFloat(i) / CGFloat(primaryFeatherCount)
            let x = width * 0.95 - progress * width * 0.45
            let baseY = height * 0.05 + progress * height * 0.15
            let featherDepth = height * 0.08 * (1.0 - progress * 0.3)
            
            if i == 0 {
                mainWingPath.addLine(to: CGPoint(x: x, y: baseY))
            } else {
                let prevProgress = CGFloat(i - 1) / CGFloat(primaryFeatherCount)
                let prevX = width * 0.95 - prevProgress * width * 0.45
                let midX = (x + prevX) / 2
                let midY = baseY - featherDepth
                
                mainWingPath.addQuadCurve(
                    to: CGPoint(x: x, y: baseY),
                    control: CGPoint(x: midX, y: midY)
                )
            }
        }
        
        // Secondary feathers section
        let secondaryFeatherCount = 8
        for i in 0...secondaryFeatherCount {
            let progress = CGFloat(i) / CGFloat(secondaryFeatherCount)
            let x = width * 0.5 - progress * width * 0.45
            let baseY = height * 0.2 + progress * height * 0.1
            let featherDepth = height * 0.06 * (1.0 - progress * 0.4)
            
            let prevProgress = max(0, CGFloat(i - 1) / CGFloat(secondaryFeatherCount))
            let prevX = width * 0.5 - prevProgress * width * 0.45
            let midX = (x + prevX) / 2
            let midY = baseY - featherDepth
            
            mainWingPath.addQuadCurve(
                to: CGPoint(x: x, y: baseY),
                control: CGPoint(x: midX, y: midY)
            )
        }
        
        // Close wing back to attachment point
        mainWingPath.addLine(to: CGPoint(x: 0, y: height * 0.25))
        
        // Fill main wing with gradient effect
        ctx.saveGState()
        
        // Create gradient-like fill using multiple layers
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.98).cgColor)
        ctx.addPath(mainWingPath)
        ctx.fillPath()
        
        // Add inner shading layers
        ctx.setFillColor(UIColor.gray.withAlphaComponent(0.12).cgColor)
        let shadowPath1 = CGMutablePath()
        shadowPath1.move(to: CGPoint(x: width * 0.05, y: height * 0.15))
        shadowPath1.addQuadCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.02),
            control: CGPoint(x: width * 0.35, y: -height * 0.15)
        )
        shadowPath1.addQuadCurve(
            to: CGPoint(x: width * 0.45, y: height * 0.2),
            control: CGPoint(x: width * 0.6, y: height * 0.12)
        )
        shadowPath1.addLine(to: CGPoint(x: width * 0.05, y: height * 0.15))
        ctx.addPath(shadowPath1)
        ctx.fillPath()
        
        // Deeper shadow near body
        ctx.setFillColor(UIColor.gray.withAlphaComponent(0.08).cgColor)
        let shadowPath2 = CGMutablePath()
        shadowPath2.move(to: CGPoint(x: 0, y: height * 0.25))
        shadowPath2.addQuadCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.1),
            control: CGPoint(x: width * 0.12, y: height * 0.05)
        )
        shadowPath2.addLine(to: CGPoint(x: width * 0.15, y: height * 0.25))
        shadowPath2.addLine(to: CGPoint(x: 0, y: height * 0.25))
        ctx.addPath(shadowPath2)
        ctx.fillPath()
        
        ctx.restoreGState()
        
        // Wing outline
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.45).cgColor)
        ctx.setLineWidth(2.0)
        ctx.addPath(mainWingPath)
        ctx.strokePath()
        
        // DETAILED FEATHER PATTERNS
        
        // Primary flight feathers (long, prominent)
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        ctx.setLineWidth(1.5)
        
        for i in 0..<7 {
            let progress = CGFloat(i) / 6.0
            let startX = width * 0.08 + progress * width * 0.65
            let startY = height * 0.18 - progress * height * 0.08
            let endX = width * 0.25 + progress * width * 0.65
            let endY = -height * 0.05 + progress * height * 0.25
            
            // Main feather shaft
            ctx.move(to: CGPoint(x: startX, y: startY))
            ctx.addLine(to: CGPoint(x: endX, y: endY))
            ctx.strokePath()
            
            // Feather barbs (small perpendicular lines)
            ctx.setLineWidth(0.8)
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.25).cgColor)
            
            let featherLength = sqrt(pow(endX - startX, 2) + pow(endY - startY, 2))
            let barbCount = Int(featherLength / (width * 0.03))
            
            for j in 1..<barbCount {
                let barbProgress = CGFloat(j) / CGFloat(barbCount)
                let barbX = startX + (endX - startX) * barbProgress
                let barbY = startY + (endY - startY) * barbProgress
                
                // Calculate perpendicular direction
                let dx = endX - startX
                let dy = endY - startY
                let length = sqrt(dx * dx + dy * dy)
                let perpX = -dy / length * width * 0.008
                let perpY = dx / length * width * 0.008
                
                ctx.move(to: CGPoint(x: barbX - perpX, y: barbY - perpY))
                ctx.addLine(to: CGPoint(x: barbX + perpX, y: barbY + perpY))
                ctx.strokePath()
            }
            
            ctx.setLineWidth(1.5)
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        }
        
        // Secondary feathers (shorter, curved)
        ctx.setLineWidth(1.2)
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.35).cgColor)
        
        for i in 0..<5 {
            let progress = CGFloat(i) / 4.0
            let startX = width * 0.03 + progress * width * 0.4
            let startY = height * 0.22 + progress * height * 0.03
            let controlX = startX + width * 0.12
            let controlY = startY - height * 0.04
            let endX = startX + width * 0.2
            let endY = startY + height * 0.08
            
            ctx.move(to: CGPoint(x: startX, y: startY))
            ctx.addQuadCurve(
                to: CGPoint(x: endX, y: endY),
                control: CGPoint(x: controlX, y: controlY)
            )
            ctx.strokePath()
        }
        
        // Wing coverts (small overlapping feathers)
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.25).cgColor)
        ctx.setLineWidth(0.8)
        
        for row in 0..<4 {
            let rowCount = 6 - row // Fewer feathers in outer rows
            for col in 0..<rowCount {
                let x = width * 0.12 + CGFloat(col) * width * 0.09 + CGFloat(row) * width * 0.03
                let y = height * 0.08 + CGFloat(row) * height * 0.06 - CGFloat(col) * height * 0.008
                let featherLength = width * (0.035 + CGFloat(row) * 0.008)
                let angle = CGFloat.random(in: -0.3...0.3)
                
                ctx.saveGState()
                ctx.translateBy(x: x, y: y)
                ctx.rotate(by: angle)
                
                // Small feather shape
                ctx.move(to: CGPoint(x: 0, y: 0))
                ctx.addQuadCurve(
                    to: CGPoint(x: featherLength, y: featherLength * 0.2),
                    control: CGPoint(x: featherLength * 0.7, y: -featherLength * 0.1)
                )
                ctx.addQuadCurve(
                    to: CGPoint(x: 0, y: 0),
                    control: CGPoint(x: featherLength * 0.7, y: featherLength * 0.4)
                )
                ctx.strokePath()
                
                ctx.restoreGState()
            }
        }
        
        // HIGHLIGHTS AND FINAL DETAILS
        
        // Leading edge highlight
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.7).cgColor)
        ctx.setLineWidth(1.5)
        ctx.move(to: CGPoint(x: width * 0.08, y: height * 0.05))
        ctx.addQuadCurve(
            to: CGPoint(x: width * 0.75, y: -height * 0.1),
            control: CGPoint(x: width * 0.4, y: -height * 0.35)
        )
        ctx.strokePath()
        
        // Inner wing highlight
        ctx.setLineWidth(1.0)
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        ctx.move(to: CGPoint(x: width * 0.02, y: height * 0.12))
        ctx.addQuadCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.02),
            control: CGPoint(x: width * 0.15, y: -height * 0.02)
        )
        ctx.strokePath()
        
        // Wing tip accent
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.6).cgColor)
        ctx.setLineWidth(1.0)
        ctx.move(to: CGPoint(x: width * 0.85, y: -height * 0.05))
        ctx.addLine(to: CGPoint(x: width * 0.92, y: height * 0.02))
        ctx.strokePath()
    }

    private func addLetterToImage(_ image: UIImage, letter: Character, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw the pig image
            image.draw(in: CGRect(origin: .zero, size: size))
            
            // Draw the letter on the sign (much bigger and more visible)
            let letterString = String(letter)
            let fontSize = min(size.width * 0.35, size.height * 0.18) // Increased size significantly
            let font = UIFont.systemFont(ofSize: fontSize, weight: .black) // Heavier weight
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .strokeColor: UIColor.white,
                .strokeWidth: -4 // Thicker outline
            ]
            
            let letterSize = letterString.size(withAttributes: attributes)
            let letterRect = CGRect(
                x: size.width * 0.5 - letterSize.width/2,
                y: size.height * 0.985 - letterSize.height/2, // Adjusted for bigger sign
                width: letterSize.width,
                height: letterSize.height
            )
            
            letterString.draw(in: letterRect, withAttributes: attributes)
        }
    }
    
    /// Clears the texture cache
    func clearCache() {
        textureCache.removeAll()
    }
    
    /// Preloads textures for commonly used letters
    func preloadCommonLetters(size: CGSize) {
        let commonLetters: [Character] = ["E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G", "O"]
        
        DispatchQueue.global(qos: .background).async {
            for letter in commonLetters {
                _ = self.generatePigTexture(for: letter, size: size)
            }
            
            DispatchQueue.main.async {
                print("🐷 Preloaded \(commonLetters.count) pig textures")
            }
        }
    }
    
    /// Memory warning handler
    @objc func handleMemoryWarning() {
        print("🐷 Memory warning received - clearing pig texture cache")
        clearCache()
    }
}

// MARK: - SKSpriteNode Extension
extension SKSpriteNode {
    /// Convenience initializer to create a sprite node with a pig texture
    convenience init(pigWithLetter letter: Character, size: CGSize) {
        let texture = PigTextureGenerator.shared.generatePigTexture(for: letter, size: size)
        self.init(texture: texture)
        self.size = size
        self.name = "pig"
        
        // Add subtle scaling animation for life-like effect
        let breathe = SKAction.sequence([
            .scale(to: 1.02, duration: 1.0),
            .scale(to: 0.98, duration: 1.0)
        ])
        self.run(.repeatForever(breathe), withKey: "breathe")
    }
}