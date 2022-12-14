//
//  SceneManager.swift
//  BM
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class SceneManager {

	enum SceneId {
		case menu, gameLevel, end, gameOver
	}

	var sceneDidChangeHandler: (() -> Void)?

	private let rootView: SKView

	init(rootView: SKView) {
		self.rootView = rootView
        rootView.ignoresSiblingOrder = true
        rootView.showsFPS = true
        rootView.showsNodeCount = true
	}

	func presentScene(id: SceneId) {
		let scene = loadScene(id: id)
		scene.sceneManager = self
		scene.scaleMode = .aspectFit
		let duration = 0.15
		let transition = SKTransition.crossFade(withDuration: duration)
		self.rootView.presentScene(scene, transition: transition)
		DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
			self.sceneDidChangeHandler?()
		})
	}

	private func loadScene(id: SceneId) -> BaseScene {
		switch id {
		case .menu:
			return SKScene(fileNamed: "MenuScene") as! MenuScene
		case .gameLevel:
			return SKScene(fileNamed: "GameScene") as! GameScene
		case .end:
			return SKScene(fileNamed: "WinScene") as! WinScene
		case .gameOver:
			return SKScene(fileNamed: "GameOverScene") as! GameOverScene
		}
	}
}
