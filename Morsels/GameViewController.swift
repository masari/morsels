//
//  GameViewController.swift
//  Morsels
//
//  Created by Mark Messer on 9/27/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            // Instantiate GameScene in code
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            // Remove background override - let GameScene set its own background
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
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
}