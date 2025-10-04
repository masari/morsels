import SpriteKit
import UIKit

class ParticleTextureGenerator {
    static let shared = ParticleTextureGenerator()
    private var smokeTexture: SKTexture?

    private init() {}

    /// Generates and caches a soft, circular texture suitable for smoke particles.
    func getSmokeTexture() -> SKTexture {
        // Return the cached texture if it already exists
        if let texture = smokeTexture {
            return texture
        }

        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let ctx = context.cgContext

            // Create a radial gradient from semi-transparent white in the center
            // to fully transparent at the edges. This creates a soft "puff" look.
            let colors = [
                UIColor.white.withAlphaComponent(0.7).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])!

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2

            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
        }

        let texture = SKTexture(image: image)
        self.smokeTexture = texture
        return texture
    }
}
