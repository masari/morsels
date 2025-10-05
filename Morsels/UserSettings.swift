import Foundation

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private let pitchKey = "tonePitchFrequency"
    private let learningStageKey = "initialLearningStage"
    private let penaltyDurationKey = "penaltyDuration"
    private let speechEnabledKey = "isSpeechRecognitionEnabled"
    
    private let defaultPitch = 800.0
    private let defaultLearningStage = 2 // E, T, I
    private let defaultPenaltyDuration = 1.0 // seconds
    private let defaultSpeechEnabled = false

    var tonePitch: Double {
        get {
            return defaults.double(forKey: pitchKey) == 0 ? defaultPitch : defaults.double(forKey: pitchKey)
        }
        set {
            defaults.set(newValue, forKey: pitchKey)
        }
    }
    
    var initialLearningStage: Int {
        get {
            if !defaults.bool(forKey: "\(learningStageKey)_isSet") {
                return defaultLearningStage
            }
            return defaults.integer(forKey: learningStageKey)
        }
        set {
            defaults.set(newValue, forKey: learningStageKey)
            defaults.set(true, forKey: "\(learningStageKey)_isSet")
        }
    }
    
    var penaltyDuration: TimeInterval {
        get {
            let saved = defaults.double(forKey: penaltyDurationKey)
            return saved == 0 ? defaultPenaltyDuration : saved
        }
        set {
            defaults.set(newValue, forKey: penaltyDurationKey)
        }
    }
    
    var isSpeechRecognitionEnabled: Bool {
        get {
            if !defaults.bool(forKey: "\(speechEnabledKey)_isSet") {
                return defaultSpeechEnabled
            }
            return defaults.bool(forKey: speechEnabledKey)
        }
        set {
            defaults.set(newValue, forKey: speechEnabledKey)
            defaults.set(true, forKey: "\(speechEnabledKey)_isSet")
        }
    }

    private init() {}
}
