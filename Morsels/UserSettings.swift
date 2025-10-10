import Foundation

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private let learningStageKey = "initialLearningStage"
    private let speechEnabledKey = "isSpeechRecognitionEnabled"
    private let pitchKey = "tonePitchFrequency"

    private let defaultLearningStage = 2
    private let defaultSpeechEnabled = false
    private let defaultPitch = 800.0

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
    
    var tonePitch: Double {
        get {
            return defaults.double(forKey: pitchKey) == 0 ? defaultPitch : defaults.double(forKey: pitchKey)
        }
        set {
            defaults.set(newValue, forKey: pitchKey)
        }
    }
    
    var isExpertMode: Bool {
        get { defaults.bool(forKey: "isExpertMode") }
        set { defaults.set(newValue, forKey: "isExpertMode") }
    }
    
    // MARK: - JSON Configuration Properties (Read-only from config)
    
    var morseCharacterSpeed: Double {
        GameConfigurationManager.shared.characterSpeed
    }
    
    var morseFarnsworthSpeed: Double {
        GameConfigurationManager.shared.farnsworthSpeed
    }
    
    var penaltyDuration: TimeInterval {
        GameConfigurationManager.shared.penaltyDuration
    }
    
    var delayBetweenRounds: TimeInterval {
        GameConfigurationManager.shared.delayBetweenRounds
    }
    
    var preparationTime: TimeInterval {
        GameConfigurationManager.shared.preparationTime
    }
    
    var pigGravity: CGFloat {
        GameConfigurationManager.shared.pigGravity
    }
    
    private init() {}
}
