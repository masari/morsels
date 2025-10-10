import Foundation

struct LevelConfiguration: Codable {
    let characterSpeed: Double
    let farnsworthSpeed: Double
    let penaltyDuration: Double
    let delayBetweenRounds: Double
    let preparationTime: Double
    let pigGravity: Double
}

struct GameConfiguration: Codable {
    struct Levels: Codable {
        let beginner: LevelConfiguration
        let intermediate: LevelConfiguration
        let advanced: LevelConfiguration
    }
    
    struct Gameplay: Codable {
        let maxFailedRounds: Int
        let minRoundLength: Int
        let maxRoundLength: Int
    }
    
    let levels: Levels
    let gameplay: Gameplay
}

enum ConfigurationLevel {
    case beginner
    case intermediate
    case advanced
    
    init(fromStage stage: Int) {
        switch stage {
        case 0...2:
            self = .beginner
        case 3...7:
            self = .intermediate
        default:
            self = .advanced
        }
    }
}

class GameConfigurationManager {
    static let shared = GameConfigurationManager()
    
    private let config: GameConfiguration
    private var currentLevel: ConfigurationLevel = .beginner
    
    private init() {
        // Load configuration from JSON file
        if let config = GameConfigurationManager.loadConfiguration() {
            self.config = config
        } else {
            // Fallback to default configuration
            let defaultLevel = LevelConfiguration(
                characterSpeed: 20.0,
                farnsworthSpeed: 15.0,
                penaltyDuration: 1.0,
                delayBetweenRounds: 2.0,
                preparationTime: 2.0,
                pigGravity: 0.4
            )
            
            self.config = GameConfiguration(
                levels: GameConfiguration.Levels(
                    beginner: defaultLevel,
                    intermediate: defaultLevel,
                    advanced: defaultLevel
                ),
                gameplay: GameConfiguration.Gameplay(
                    maxFailedRounds: 3,
                    minRoundLength: 1,
                    maxRoundLength: 4
                )
            )
        }
        
        // Set initial level based on user settings
        updateLevel(fromStage: UserSettings.shared.initialLearningStage)
    }
    
    private static func loadConfiguration() -> GameConfiguration? {
        guard let url = Bundle.main.url(forResource: "GameConfiguration", withExtension: "json") else {
            print("⚙️ GameConfiguration.json not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let config = try decoder.decode(GameConfiguration.self, from: data)
            print("⚙️ Game configuration loaded successfully")
            return config
        } catch {
            print("⚙️ Error loading game configuration: \(error)")
            return nil
        }
    }
    
    // Update the current level based on learning stage
    func updateLevel(fromStage stage: Int) {
        currentLevel = ConfigurationLevel(fromStage: stage)
        print("⚙️ Difficulty level updated to: \(currentLevel)")
    }
    
    private var activeConfig: LevelConfiguration {
        switch currentLevel {
        case .beginner:
            return config.levels.beginner
        case .intermediate:
            return config.levels.intermediate
        case .advanced:
            return config.levels.advanced
        }
    }
    
    // Convenience accessors - these now return values based on current level
    var characterSpeed: Double { activeConfig.characterSpeed }
    var farnsworthSpeed: Double { activeConfig.farnsworthSpeed }
    var penaltyDuration: TimeInterval { activeConfig.penaltyDuration }
    var delayBetweenRounds: TimeInterval { activeConfig.delayBetweenRounds }
    var preparationTime: TimeInterval { activeConfig.preparationTime }
    var pigGravity: CGFloat { CGFloat(activeConfig.pigGravity) }
    var maxFailedRounds: Int { config.gameplay.maxFailedRounds }
    var minRoundLength: Int { config.gameplay.minRoundLength }
    var maxRoundLength: Int { config.gameplay.maxRoundLength }
}
