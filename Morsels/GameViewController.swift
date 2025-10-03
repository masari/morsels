//
//  GameViewController.swift
//  Morsels
//
//  Created by Mark Messer on 9/27/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameSceneDelegate, PauseMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            // Instantiate GameScene in code
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            scene.gameDelegate = self // Set the delegate
            // Remove background override - let GameScene set its own background
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - GameSceneDelegate
    
    func pauseGame() {
        // Pause the SpriteKit view
        if let skView = self.view as? SKView {
            skView.isPaused = true
        }
        
        // Present the pause menu
        let pauseMenuVC = PauseMenuViewController()
        pauseMenuVC.delegate = self
        pauseMenuVC.modalPresentationStyle = .overCurrentContext
        pauseMenuVC.modalTransitionStyle = .crossDissolve
        present(pauseMenuVC, animated: true, completion: nil)
    }
    
    // MARK: - PauseMenuDelegate
    
    func didTapContinue() {
        dismiss(animated: true) {
            // Unpause the SpriteKit view after the menu is dismissed
            if let skView = self.view as? SKView {
                skView.isPaused = false
            }
        }
    }
    
    func didTapQuit() {
        dismiss(animated: true) {
            // Unpause the view first to avoid it being frozen on the next playthrough
            if let skView = self.view as? SKView {
                skView.isPaused = false
            }
            // Return to the main menu
            self.navigationController?.popViewController(animated: true)
        }
    }
}