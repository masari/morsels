import Foundation

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private let pitchKey = "tonePitchFrequency"
    private let learningStageKey = "initialLearningStage"
    private let penaltyDurationKey = "penaltyDuration"
    
    private let defaultPitch = 800.0
    private let defaultLearningStage = 2 // E, T, I
    private let defaultPenaltyDuration = 1.0 // seconds

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
            // If not set, return default
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
            // If not set or zero, return default
            let saved = defaults.double(forKey: penaltyDurationKey)
            return saved == 0 ? defaultPenaltyDuration : saved
        }
        set {
            defaults.set(newValue, forKey: penaltyDurationKey)
        }
    }

    private init() {}
}
