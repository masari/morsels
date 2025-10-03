import Foundation

class UserSettings { // CHANGED: from struct to class
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private let pitchKey = "tonePitchFrequency"
    private let defaultPitch = 800.0

    var tonePitch: Double {
        get {
            // Return saved value or default if not set
            return defaults.double(forKey: pitchKey) == 0 ? defaultPitch : defaults.double(forKey: pitchKey)
        }
        set {
            // Save the new value
            defaults.set(newValue, forKey: pitchKey)
        }
    }

    private init() {}
}