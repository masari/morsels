import GameKit

class GameKitHelper: NSObject {
    static let shared = GameKitHelper()
    
    static let leaderboardID = "morsels_high_scores"
    
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    /// Authenticates the local player with Game Center.
    func authenticateLocalPlayer(presentingVC: UIViewController) {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { viewController, error in
            if let vc = viewController {
                // If Game Center needs the player to sign in, present the login view controller.
                presentingVC.present(vc, animated: true, completion: nil)
                return
            }
            
            if error != nil {
                // Player is not authenticated, usually due to parental controls, network issues, etc.
                print("Game Center authentication failed with error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            print("Game Center: Player authenticated successfully.")
        }
    }
    
    /// Submits a score to the specified leaderboard.
    func submitScore(_ score: Int, leaderboardID: String) {
        guard isAuthenticated else {
            print("Cannot submit score, player is not authenticated.")
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score to Game Center: \(error.localizedDescription)")
            } else {
                print("Score of \(score) submitted to leaderboard \(leaderboardID) successfully.")
            }
        }
    }
    
    /// Presents the native Game Center leaderboard view controller.
    func showLeaderboard(presentingVC: UIViewController) {
        guard isAuthenticated else {
            print("Cannot show leaderboard, player is not authenticated.")
            // Optionally, show an alert to the user here.
            return
        }
        
        let gcVC = GKGameCenterViewController(leaderboardID: GameKitHelper.leaderboardID,
                                              playerScope: .global,
                                              timeScope: .allTime)
        gcVC.gameCenterDelegate = self
        presentingVC.present(gcVC, animated: true, completion: nil)
    }
}

extension GameKitHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}