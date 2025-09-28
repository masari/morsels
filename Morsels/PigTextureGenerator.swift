import SpriteKit
import SwiftUI

class PigTextureGenerator {
    static let shared = PigTextureGenerator()
    
    private init() {}
    
    // Cache for generated textures to improve performance
    private var textureCache: [String: SKTexture] = [:]
    
    /// Optimal pig size for the current device.
    var recommendedPigSize: CGSize {
        let baseSize: CGFloat = 90 // Increased base size for better visibility
        let screenScale = UIScreen.main.scale
        
        // Simpler scaling for consistency
        let scaledSize = baseSize * (screenScale / 2.0)
        return CGSize(width: scaledSize, height: scaledSize)
    }
    
    /// Generates a single texture for a pig with the given letter.
    func generatePigTexture(for letter: Character, size: CGSize) -> SKTexture {
        let cacheKey = "\(letter)_\(Int(size.width))x\(Int(size.height))"
        
        // Return cached texture if available
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        // Create the texture using Core Graphics
        let texture = createPigTexture(letter: letter, size: size)
        
        // Cache the texture
        textureCache[cacheKey] = texture
        
        return texture
    }
    
    /// Creates a single pig texture.
    private func createPigTexture(letter: Character, size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Add a vertical offset to shift the entire drawing up, creating a margin at the bottom.
            let verticalOffset = -size.height * 0.12
            ctx.translateBy(x: 0, y: verticalOffset)
            
            // --- Pig Body and Head ---
            drawPigBody(ctx: ctx, size: size)
            
            // --- Legs and Tail ---
            drawPigLegs(ctx: ctx, size: size)
            drawCurlyTail(ctx: ctx, size: size)
            
            // --- Sign (Drawn on top) ---
            drawSign(ctx: ctx, size: size)
        }
        
        // Add the letter to the sign on the final composited image
        let finalImage = addLetterToImage(image, letter: letter, size: size)
        
        let texture = SKTexture(image: finalImage)
        texture.filteringMode = .linear
        return texture
    }

    private func drawPigBody(ctx: CGContext, size: CGSize) {
        // Body
        let bodyRect = CGRect(x: size.width * 0.1, y: size.height * 0.35, width: size.width * 0.8, height: size.height * 0.45)
        ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
        ctx.fillEllipse(in: bodyRect)
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
        ctx.setLineWidth(1)
        ctx.strokeEllipse(in: bodyRect)
        
        // Head
        let headRect = CGRect(x: size.width * 0.2, y: size.height * 0.15, width: size.width * 0.6, height: size.height * 0.5)
        ctx.fillEllipse(in: headRect)
        ctx.strokeEllipse(in: headRect)
        
        // Snout
        let snoutRect = CGRect(x: size.width * 0.35, y: size.height * 0.3, width: size.width * 0.3, height: size.height * 0.2)
        ctx.setFillColor(UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0).cgColor)
        ctx.fillEllipse(in: snoutRect)
        ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        ctx.strokeEllipse(in: snoutRect)
        
        // Nostrils
        let nostrilSize = size.width * 0.025
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.42 - nostrilSize/2, y: size.height * 0.37, width: nostrilSize, height: nostrilSize * 0.7))
        ctx.fillEllipse(in: CGRect(x: size.width * 0.58 - nostrilSize/2, y: size.height * 0.37, width: nostrilSize, height: nostrilSize * 0.7))
        
        // Eyes
        let eyeSize = size.width * 0.06
        // Left Eye
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.35 - eyeSize/2, y: size.height * 0.22, width: eyeSize, height: eyeSize))
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.35 - eyeSize/4, y: size.height * 0.24, width: eyeSize/2, height: eyeSize/2))
        // Right Eye
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.65 - eyeSize/2, y: size.height * 0.22, width: eyeSize, height: eyeSize))
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.65 - eyeSize/4, y: size.height * 0.24, width: eyeSize/2, height: eyeSize/2))
        
        // Ears
        let earWidth = size.width * 0.15
        let earHeight = size.height * 0.2
        ctx.setFillColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
        // Left Ear
        ctx.saveGState()
        ctx.translateBy(x: size.width * 0.25, y: size.height * 0.1)
        ctx.rotate(by: -0.3)
        ctx.fillEllipse(in: CGRect(x: -earWidth/2, y: 0, width: earWidth, height: earHeight))
        ctx.restoreGState()
        // Right Ear
        ctx.saveGState()
        ctx.translateBy(x: size.width * 0.75, y: size.height * 0.1)
        ctx.rotate(by: 0.3)
        ctx.fillEllipse(in: CGRect(x: -earWidth/2, y: 0, width: earWidth, height: earHeight))
        ctx.restoreGState()
    }
    
    private func drawPigLegs(ctx: CGContext, size: CGSize) {
        let legWidth = size.width * 0.06
        ctx.setLineCap(.round)
        ctx.setLineWidth(legWidth)
        ctx.setStrokeColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
        
        // Legs
        let legPositions = [
            (x: 0.32, yStart: 0.78, yEnd: 0.90), // Front left
            (x: 0.68, yStart: 0.78, yEnd: 0.90), // Front right
            (x: 0.25, yStart: 0.78, yEnd: 0.88), // Back left
            (x: 0.75, yStart: 0.78, yEnd: 0.88)  // Back right
        ]
        for leg in legPositions {
            ctx.move(to: CGPoint(x: size.width * leg.x, y: size.height * leg.yStart))
            ctx.addLine(to: CGPoint(x: size.width * leg.x, y: size.height * leg.yEnd))
            ctx.strokePath()
        }

        // Hooves
        ctx.setFillColor(UIColor.black.cgColor)
        let hoofSize = size.width * 0.04
        let hoofPositions = [
            (x: 0.32, y: 0.88),
            (x: 0.68, y: 0.88),
            (x: 0.25, y: 0.86),
            (x: 0.75, y: 0.86)
        ]
        for hoof in hoofPositions {
            ctx.fillEllipse(in: CGRect(x: size.width * hoof.x - hoofSize/2, y: size.height * hoof.y, width: hoofSize, height: hoofSize * 0.6))
        }
    }
    
    private func drawCurlyTail(ctx: CGContext, size: CGSize) {
        ctx.setStrokeColor(UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0).cgColor)
        ctx.setLineWidth(size.width * 0.02)
        ctx.setLineCap(.round)
        
        let startPoint = CGPoint(x: size.width * 0.85, y: size.height * 0.5)
        ctx.move(to: startPoint)
        ctx.addQuadCurve(to: CGPoint(x: startPoint.x + size.width * 0.1, y: startPoint.y - size.height * 0.05),
                         control: CGPoint(x: startPoint.x + size.width * 0.08, y: startPoint.y + size.height * 0.05))
        ctx.strokePath()
    }
    
    private func drawSign(ctx: CGContext, size: CGSize) {
        // Sign is held by the pig, so it should be lower down, in front of the body.
        let signHeight = size.height * 0.35
        let signRect = CGRect(
            x: size.width * 0.1,
            y: size.height * 0.6, // Moved sign up
            width: size.width * 0.8,
            height: signHeight
        )
        
        // Sign background (wood texture)
        ctx.setFillColor(UIColor(red: 0.85, green: 0.65, blue: 0.45, alpha: 1.0).cgColor)
        ctx.fill(signRect)
        
        // Thicker border
        ctx.setStrokeColor(UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0).cgColor)
        ctx.setLineWidth(4)
        ctx.stroke(signRect)

        // Sign post is held by the legs
        let postRect = CGRect(x: size.width * 0.45, y: size.height * 0.8, width: size.width * 0.1, height: size.height * 0.15)
        ctx.setFillColor(UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)
        ctx.fill(postRect)
    }

    private func addLetterToImage(_ image: UIImage, letter: Character, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw the pig image
            image.draw(in: CGRect(origin: .zero, size: size))
            
            // Draw the letter on the sign
            let letterString = String(letter)
            let fontSize = min(size.width * 0.35, size.height * 0.20)
            
            // Use a rounded, bold font for better visibility
            let font = UIFont(name: "ArialRoundedMTBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .black)
            
            // Add a subtle shadow for depth
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 3
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white, // White text for better contrast
                .strokeColor: UIColor.black,
                .strokeWidth: -5, // Thicker outline
                .shadow: shadow
            ]
            
            let letterSize = letterString.size(withAttributes: attributes)
            
            // Apply the same vertical offset to the letter's position.
            let verticalOffset = -size.height * 0.12
            let letterRect = CGRect(
                x: size.width * 0.5 - letterSize.width / 2,
                y: (size.height * 0.77 - letterSize.height / 2) + verticalOffset, // Centered in sign, with offset
                width: letterSize.width,
                height: letterSize.height
            )
            
            letterString.draw(in: letterRect, withAttributes: attributes)
        }
    }
    
    /// Preloads textures for common letters to improve initial performance.
    func preloadCommonLetters() {
        let commonLetters: [Character] = ["E", "T", "I", "A", "N", "M"]
        let size = recommendedPigSize
        
        DispatchQueue.global(qos: .background).async {
            for letter in commonLetters {
                _ = self.generatePigTexture(for: letter, size: size)
            }
            DispatchQueue.main.async {
                print("🐷 Preloaded textures for \(commonLetters.count) common letters.")
            }
        }
    }
}