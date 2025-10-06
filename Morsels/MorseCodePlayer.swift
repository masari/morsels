import AVFoundation

/// Singleton that generates and plays Morse code as sine‐wave beeps on the fly.
class MorseCodePlayer {
    static let shared = MorseCodePlayer()

    // International Morse Code table for A–Z
    let mapping: [Character:String] = [
        "A":".-", "B":"-...", "C":"-.-.", "D":"-..",
        "E":".",  "F":"..-.", "G":"--.",  "H":"....",
        "I":"..", "J":".---", "K":"-.-",  "L":".-..",
        "M":"--", "N":"-.",   "O":"---",  "P":".--.",
        "Q":"--.-","R":".-.", "S":"...",  "T":"-",
        "U":"..-","V":"...-","W":".--",  "X":"-..-",
        "Y":"-.--","Z":"--.."
    ]

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var toneFrequency: Double = 800

    // Timing properties
    private var characterSpeed: Double = 20.0  // WPM
    private var farnsworthSpacing: Double = 15.0  // Effective WPM
    
    private var dotBuffer: AVAudioPCMBuffer
    private var dashBuffer: AVAudioPCMBuffer
    private var symbolGapBuffer: AVAudioPCMBuffer
    private var letterGapBuffer: AVAudioPCMBuffer

    private init() {
        // Configure audio session first
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        // Attach & connect player
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        // Load saved settings
        self.toneFrequency = UserSettings.shared.tonePitch
        self.characterSpeed = UserSettings.shared.morseCharacterSpeed
        self.farnsworthSpacing = UserSettings.shared.morseFarnsworthSpacing
        
        // Generate buffers with current timing
        (dotBuffer, dashBuffer, symbolGapBuffer, letterGapBuffer) = Self.generateBuffers(
            sampleRate: sampleRate,
            frequency: toneFrequency,
            characterSpeed: characterSpeed,
            farnsworthSpacing: farnsworthSpacing
        )

        // Start engine
        do {
            try engine.start()
            print("🔊 Morse code audio engine started successfully")
        }
        catch {
            print("❌ Morse code audio engine start error:", error)
        }
    }

    /// Calculate timing based on WPM (Words Per Minute)
    /// Standard word is "PARIS" which is 50 dot units
    private static func calculateTiming(characterSpeed: Double, farnsworthSpacing: Double) -> (dot: Double, dash: Double, symbolGap: Double, letterGap: Double) {
        // Character speed determines dit/dah length
        let dotDuration = 1.2 / characterSpeed  // PARIS standard
        let dashDuration = dotDuration * 3
        let symbolGap = dotDuration  // Between dits/dahs in a character
        
        // Farnsworth spacing: stretch the gaps between characters
        // If farnsworth < character speed, use character speed (no stretching)
        let effectiveSpacing = min(farnsworthSpacing, characterSpeed)
        let stretchFactor = characterSpeed / effectiveSpacing
        let letterGap = dotDuration * 3 * stretchFactor  // Between characters
        
        return (dotDuration, dashDuration, symbolGap, letterGap)
    }

    /// Generate all timing buffers
    private static func generateBuffers(sampleRate: Double, frequency: Double, characterSpeed: Double, farnsworthSpacing: Double) -> (dot: AVAudioPCMBuffer, dash: AVAudioPCMBuffer, symbolGap: AVAudioPCMBuffer, letterGap: AVAudioPCMBuffer) {
        
        let timing = calculateTiming(characterSpeed: characterSpeed, farnsworthSpacing: farnsworthSpacing)
        
        let dot = makeToneBuffer(duration: timing.dot, sampleRate: sampleRate, freq: frequency)
        let dash = makeToneBuffer(duration: timing.dash, sampleRate: sampleRate, freq: frequency)
        let symbolGap = makeSilenceBuffer(duration: timing.symbolGap, sampleRate: sampleRate)
        let letterGap = makeSilenceBuffer(duration: timing.letterGap, sampleRate: sampleRate)
        
        return (dot, dash, symbolGap, letterGap)
    }

    /// Generate sine‐wave buffer
    private static func makeToneBuffer(duration: Double, sampleRate: Double, freq: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buf.frameLength = frameCount

        let thetaIncrement = 2.0 * Double.pi * freq / sampleRate
        var theta: Double = 0
        let ptr = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            ptr[i] = Float(sin(theta))
            theta += thetaIncrement
        }
        return buf
    }

    /// Generate silence buffer
    private static func makeSilenceBuffer(duration: Double, sampleRate: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buf.frameLength = frameCount
        memset(buf.floatChannelData![0], 0, Int(frameCount) * MemoryLayout<Float>.size)
        return buf
    }

    /// Updates the tone frequency and regenerates the audio buffers.
    func updateToneFrequency(_ newFrequency: Double) {
        self.toneFrequency = newFrequency
        regenerateBuffers()
    }
    
    /// Updates character speed (WPM) and regenerates buffers
    func updateCharacterSpeed(_ newSpeed: Double) {
        self.characterSpeed = newSpeed
        regenerateBuffers()
    }
    
    /// Updates Farnsworth spacing and regenerates buffers
    func updateFarnsworthSpacing(_ newSpacing: Double) {
        self.farnsworthSpacing = newSpacing
        regenerateBuffers()
    }
    
    /// Regenerate all buffers with current settings
    private func regenerateBuffers() {
        (dotBuffer, dashBuffer, symbolGapBuffer, letterGapBuffer) = Self.generateBuffers(
            sampleRate: sampleRate,
            frequency: toneFrequency,
            characterSpeed: characterSpeed,
            farnsworthSpacing: farnsworthSpacing
        )
        print("🔊 Morse buffers regenerated - Speed: \(characterSpeed) WPM, Farnsworth: \(farnsworthSpacing) WPM, Freq: \(toneFrequency) Hz")
    }

    /// Play given letters as Morse code beeps.
    func play(letters: [Character]) {
        player.stop()
        var buffers: [AVAudioPCMBuffer] = []
        for (idx, ch) in letters.enumerated() {
            guard let code = mapping[ch] else { continue }
            for symbol in code {
                buffers.append(symbol == "." ? dotBuffer : dashBuffer)
                buffers.append(symbolGapBuffer)
            }
            if idx < letters.count - 1 {
                buffers.append(letterGapBuffer)
            }
        }

        // Debug: Print what we're about to play
        let letterString = letters.map(String.init).joined()
        print("🔊 Playing Morse code for: \(letterString)")

        // Schedule sequentially
        var time: AVAudioTime? = nil
        for buf in buffers {
            player.scheduleBuffer(buf, at: time, options: []) {}
            if let nodeTime = player.lastRenderTime,
               let playerTime = player.playerTime(forNodeTime: nodeTime) {
                let next = playerTime.sampleTime + AVAudioFramePosition(buf.frameLength)
                time = AVAudioTime(sampleTime: next, atRate: sampleRate)
            }
        }
        player.play()
    }
    
    /// Restarts the audio engine if it has stopped
    func restartEngineIfNeeded() {
        if !engine.isRunning {
            do {
                try engine.start()
                print("🔊 Morse code audio engine restarted")
            } catch {
                print("🔊 Failed to restart audio engine: \(error)")
            }
        }
    }
}
