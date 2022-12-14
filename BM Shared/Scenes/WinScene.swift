//
//  MenuScene.swift
//  BM
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class WinScene: BaseScene {

	override func sceneDidLoad() {
		super.sceneDidLoad()
	}

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		AudioPlayer.shared.playMusic(name: SoundName.ending.rawValue)
	}
}

#if os(OSX)
extension WinScene {

	override func keyUp(with event: NSEvent) {
		AudioPlayer.shared.stopMusic()
		self.sceneManager?.presentScene(id: .menu)
	}

	override func keyDown(with event: NSEvent) {
	}
}
#endif
