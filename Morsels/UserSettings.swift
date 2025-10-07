import Foundation

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private let pitchKey = "tonePitchFrequency"
    private let learningStageKey = "initialLearningStage"
    private let penaltyDurationKey = "penaltyDuration"
    private let speechEnabledKey = "isSpeechRecognitionEnabled"
    private let roundDelayKey = "delayBetweenRounds"
    private let preparationTimeKey = "preparationTime"
    private let characterSpeedKey = "morseCharacterSpeed"  // NEW
    private let farnsworthSpacingKey = "morseFarnsworthSpacing"  // NEW
    private let pigGravityKey = "pigGravity"

    private let defaultPitch = 800.0
    private let defaultLearningStage = 2
    private let defaultPenaltyDuration = 1.0
    private let defaultSpeechEnabled = false
    private let defaultRoundDelay = 2.0
    private let defaultPreparationTime = 2.0
    private let defaultCharacterSpeed = 20.0  // NEW: Words per minute (WPM)
    private let defaultFarnsworthSpacing = 15.0  // NEW: Effective WPM for spacing
    private let defaultPigGravity = 0.4

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
    
    var delayBetweenRounds: TimeInterval {
        get {
            let saved = defaults.double(forKey: roundDelayKey)
            return saved == 0 ? defaultRoundDelay : saved
        }
        set {
            defaults.set(newValue, forKey: roundDelayKey)
        }
    }
    
    var preparationTime: TimeInterval {
        get {
            let saved = defaults.double(forKey: preparationTimeKey)
            return saved == 0 ? defaultPreparationTime : saved
        }
        set {
            defaults.set(newValue, forKey: preparationTimeKey)
        }
    }
    
    // NEW: Character speed in WPM
    var morseCharacterSpeed: Double {
        get {
            let saved = defaults.double(forKey: characterSpeedKey)
            return saved == 0 ? defaultCharacterSpeed : saved
        }
        set {
            defaults.set(newValue, forKey: characterSpeedKey)
        }
    }
    
    // NEW: Farnsworth spacing in effective WPM
    var morseFarnsworthSpacing: Double {
        get {
            let saved = defaults.double(forKey: farnsworthSpacingKey)
            return saved == 0 ? defaultFarnsworthSpacing : saved
        }
        set {
            defaults.set(newValue, forKey: farnsworthSpacingKey)
        }
    }

    var pigGravity: CGFloat {
        get {
            let saved = defaults.double(forKey: pigGravityKey)
            return saved == 0 ? CGFloat(defaultPigGravity) : CGFloat(saved)
        }
        set {
            defaults.set(Double(newValue), forKey: pigGravityKey)
        }
    }
    
    // In UserSettings.swift
    var isExpertMode: Bool {
        get { defaults.bool(forKey: "isExpertMode") }
        set { defaults.set(newValue, forKey: "isExpertMode") }
    }
    
    private init() {}
}
