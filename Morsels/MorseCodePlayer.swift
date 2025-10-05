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
    private var toneFrequency: Double = 800  // Hz. Changed to var

    private var dotBuffer: AVAudioPCMBuffer
    private var dashBuffer: AVAudioPCMBuffer
    private let symbolGapBuffer: AVAudioPCMBuffer
    private let letterGapBuffer: AVAudioPCMBuffer

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

        // Load saved frequency or use default
        self.toneFrequency = UserSettings.shared.tonePitch
        
        // Pre‐generate buffers
        dotBuffer      = MorseCodePlayer.makeToneBuffer(duration: 0.1, sampleRate: sampleRate, freq: toneFrequency)
        dashBuffer     = MorseCodePlayer.makeToneBuffer(duration: 0.3, sampleRate: sampleRate, freq: toneFrequency)
        symbolGapBuffer = MorseCodePlayer.makeSilenceBuffer(duration: 0.1, sampleRate: sampleRate)
        letterGapBuffer = MorseCodePlayer.makeSilenceBuffer(duration: 0.3, sampleRate: sampleRate)

        // Start engine
        do { 
            try engine.start() 
            print("Audio engine started successfully")
        }
        catch { 
            print("Audio engine start error:", error) 
        }
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
        self.dotBuffer = MorseCodePlayer.makeToneBuffer(duration: 0.1, sampleRate: self.sampleRate, freq: self.toneFrequency)
        self.dashBuffer = MorseCodePlayer.makeToneBuffer(duration: 0.3, sampleRate: self.sampleRate, freq: self.toneFrequency)
        print("Morse code tone frequency updated to \(newFrequency) Hz")
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
        print("Playing Morse code for: \(letterString)")

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
