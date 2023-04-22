//
//  MenuScene.swift
//  BM
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class MenuScene: BaseScene {

	override func sceneDidLoad() {
		super.sceneDidLoad()

		AudioPlayer.shared.preloadSounds(names: SoundName.allCases.map { $0.rawValue })
		AudioPlayer.shared.preloadLoopSounds(names: [SoundName.walkHorizontal.rawValue, SoundName.walkVertical.rawValue])
		AudioPlayer.shared.playMusic(name: SoundName.titleScreen.rawValue)
	}

	override func didMove(to view: SKView) {
		super.didMove(to: view)
	}
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension MenuScene {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		AudioPlayer.shared.stopMusic()
		self.sceneManager?.presentScene(id: .gameLevel)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

	}
}
#endif

#if os(OSX)
extension MenuScene {

	override func keyUp(with event: NSEvent) {
		AudioPlayer.shared.stopMusic()
		self.sceneManager?.presentScene(id: .gameLevel)
	}

	override func keyDown(with event: NSEvent) {
	}
}
#endif
