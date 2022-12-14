//
//  GameViewController.swift
//  BM macOS
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

	private var sceneManager: SceneManager?

    override func viewDidLoad() {
        super.viewDidLoad()

		guard let skView = self.view as? SKView else {
			return
		}
		sceneManager = SceneManager(rootView: skView)
		sceneManager?.presentScene(id: .menu)
		sceneManager?.sceneDidChangeHandler = { [weak self] in
			DispatchQueue.main.async {
				self?.updateSceneSize()
			}
		}
    }

	override func viewDidLayout() {
		super.viewDidLayout()

		self.updateSceneSize()
	}

	private func updateSceneSize() {
		let screenSize = self.view.frame.size
		let minHeight = (Int(GameConfiguration.tileSize.height)) * GameConfiguration.levelHeight + 32
		let ratio = screenSize.width / screenSize.height
		let width = min(CGFloat(minHeight) * ratio, 850)
		let size = CGSize(width: width, height: CGFloat(minHeight))
		guard let skView = self.view as? SKView else {
			return
		}
		DispatchQueue.main.async {
			skView.scene?.size = size
		}
	}
}
