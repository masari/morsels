//
//  SpeechRecognitionManager.swift
//  Morsels
//
//  Manages speech recognition for letter selection
//

import Foundation
import Speech
import AVFoundation

protocol SpeechRecognitionDelegate: AnyObject {
    func didRecognizeLetter(_ letter: Character)
    func speechRecognitionAvailabilityChanged(_ isAvailable: Bool)
}

class SpeechRecognitionManager: NSObject {
    
    static let shared = SpeechRecognitionManager()
    
    // MARK: - Properties
    weak var delegate: SpeechRecognitionDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private(set) var isListening = false
    private(set) var isAuthorized = false
    
    // Track last processed transcription to avoid duplicates
    private var lastProcessedTranscription = ""
    
    // MARK: - Letter Recognition
    private let letterPhonetics: [String: Character] = [
        "a": "A", "alpha": "A", "able": "A",
        "b": "B", "bravo": "B", "baker": "B",
        "c": "C", "charlie": "C",
        "d": "D", "delta": "D", "dog": "D",
        "e": "E", "echo": "E", "easy": "E",
        "f": "F", "foxtrot": "F", "fox": "F",
        "g": "G", "golf": "G", "george": "G",
        "h": "H", "hotel": "H", "how": "H",
        "i": "I", "india": "I", "item": "I",
        "j": "J", "juliet": "J", "jig": "J",
        "k": "K", "kilo": "K", "king": "K",
        "l": "L", "lima": "L", "love": "L",
        "m": "M", "mike": "M",
        "n": "N", "november": "N", "nan": "N",
        "o": "O", "oscar": "O", "oboe": "O",
        "p": "P", "papa": "P", "peter": "P",
        "q": "Q", "quebec": "Q", "queen": "Q",
        "r": "R", "romeo": "R", "roger": "R",
        "s": "S", "sierra": "S", "sugar": "S",
        "t": "T", "tango": "T", "tare": "T",
        "u": "U", "uniform": "U", "uncle": "U",
        "v": "V", "victor": "V",
        "w": "W", "whiskey": "W", "william": "W",
        "x": "X", "xray": "X", "x-ray": "X",
        "y": "Y", "yankee": "Y", "yoke": "Y",
        "z": "Z", "zulu": "Z", "zebra": "Z"
    ]
    
    // MARK: - Initialization
    private override init() {
        super.init()
        speechRecognizer?.delegate = self
        
        // Check current authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    private func checkAuthorizationStatus() {
        let status = SFSpeechRecognizer.authorizationStatus()
        isAuthorized = (status == .authorized)
        print("🎤 Initial authorization status: \(status.rawValue), isAuthorized: \(isAuthorized)")
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.isAuthorized = (authStatus == .authorized)
                print("🎤 Authorization status after request: \(authStatus.rawValue), isAuthorized: \(self.isAuthorized)")
                completion(self.isAuthorized)
                self.delegate?.speechRecognitionAvailabilityChanged(self.isAuthorized)
            }
        }
    }
    
    // MARK: - Recording Control
    func startListening() throws {
        print("🎤 startListening() called")
        
        guard isAuthorized else {
            print("🎤 Not authorized to start listening")
            throw SpeechRecognitionError.notAuthorized
        }
        
        // Stop if already listening
        if isListening {
            stopListening()
        }
        
        // Reset last processed transcription
        lastProcessedTranscription = ""
        
        // Cancel any ongoing task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Configure audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🎤 Audio session error: \(error)")
            throw error
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get audio input node
        let inputNode = audioEngine.inputNode
        
        // Remove any existing taps
        inputNode.removeTap(onBus: 0)
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                print("🎤 Got recognition result: \(result.bestTranscription.formattedString)")
                self.processRecognitionResult(result)
            }
            
            if let error = error {
                print("🎤 Recognition error: \(error.localizedDescription)")
            }
        }
        
        // Configure audio tap
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
        print("🎤 Speech recognition started successfully")
    }
    
    func stopListening() {
        guard isListening else {
            print("🎤 stopListening() called but not listening")
            return
        }
        
        print("🎤 stopListening() called")
        isListening = false
        
        // Stop recognition first
        recognitionTask?.cancel()
        recognitionTask = nil
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Stop audio engine safely
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Reset audio session to playback mode for Morse code
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🎤 Error resetting audio session: \(error)")
        }
        
        // CRITICAL: Restart the Morse code audio engine after switching audio sessions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            MorseCodePlayer.shared.restartEngineIfNeeded()
        }
        
        print("🎤 Speech recognition stopped")
    }
    
    // MARK: - Recognition Processing
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let transcription = result.bestTranscription.formattedString.lowercased()
        
        // Avoid processing the same transcription twice
        guard transcription != lastProcessedTranscription else { return }
        
        let words = transcription.split(separator: " ").map(String.init)
        
        print("🎤 Processing transcription: '\(transcription)'")
        print("🎤 Words: \(words)")
        
        // Check the most recent words for letter matches
        guard let lastWord = words.last else { return }
        
        print("🎤 Checking last word: '\(lastWord)'")
        
        if let letter = letterPhonetics[lastWord] {
            lastProcessedTranscription = transcription
            delegate?.didRecognizeLetter(letter)
            print("🎤 ✅ Recognized: \(lastWord) -> \(letter)")
        } else {
            print("🎤 ❌ No match for: '\(lastWord)'")
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognitionManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.speechRecognitionAvailabilityChanged(available)
    }
}

// MARK: - Error Handling
enum SpeechRecognitionError: Error {
    case requestCreationFailed
    case audioEngineNotAvailable
    case notAuthorized
}
