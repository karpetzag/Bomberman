//
//  Bomb.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class Bomb: Entity {

	var orderNumber: Int
	var position: TilePosition
	var explosionRadius: Int

	var isBlockingPlayer = false

	var timeLeft: TimeInterval
	private(set) var isTicking = false

	init(
		time: TimeInterval,
		explosionRadius: Int,
		position: TilePosition,
		orderNumber: Int
	) {
		self.explosionRadius = explosionRadius
		self.position = position
		self.timeLeft = time
		self.orderNumber = orderNumber
		super.init()
		node.size = GameConfiguration.tileSize
	}

	func prepare(startTicking: Bool) {
		self.isTicking = startTicking

		let textures = TextureSource.Bomb.ticking
		let animation = SKAction.animate(with: textures, timePerFrame: 0.35, resize: true, restore: false)
		self.node.isHidden = true

		self.node.run(.wait(forDuration: 0.175)) { [weak self] in
			self?.node.isHidden = false
			self?.node.run(SKAction.repeatForever(animation), withKey: "ticking")
		}
	}

	func setReadyToExplode() {
		if self.timeLeft > 0.1 {
			self.timeLeft = 0.1
		}

		self.isTicking = true
	}

	override func update(dt: TimeInterval, level: GameLevel) {
		if self.isTicking && self.timeLeft > 0 {
			self.timeLeft -= dt
		}

		if self.timeLeft <= 0 {
			level.removeBomb(self)
			let area = level.calculateExplosionArea(row: position.row,
													column: position.column,
													radius: explosionRadius)
			level.addExplosion(area)
		}
	}
}
