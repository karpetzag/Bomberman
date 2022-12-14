//
//  GameViewController.swift
//  BM tvOS
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene.newGameScene()

		guard let skView = self.view as? SKView else {
			return
		}
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}
