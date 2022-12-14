//
//  Enemy.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class Enemy: Entity, MovableEntity {

	enum Kind {
		// names from nes game
		case balloom, oneal, dall, minvo, kondoria, ovapi, pass, pontan

		var points: Int {
			switch self {
			case .balloom: return 100
			case .dall: return 300
			case .oneal: return 312
			case .minvo: return 100
			case .kondoria: return 200
			case .ovapi: return 200
			case .pass: return 400
			case .pontan: return 500
			}
		}
	}

	var speed: CGFloat {
		switch self.kind {
		case .oneal: return 100
		case .pontan: return 150
		case .kondoria: return 15
		default: return 50
		}
	}

	var canPassBlocks: Bool {
		switch self.kind {
		case .ovapi, .pontan, .kondoria: return true
		default: return false
		}
	}

	var canPassBombs: Bool {
		return false
	}

	var onDeathHandler: (() -> Void)?

	let kind: Kind

	private(set) var isDead = false
	private var isDeadAnimationCompleted = false

	private lazy var movementStrategy: MovementStategy = self.makeMovementStrategy()

	private lazy var moveAction = SKAction.repeatForever(
		SKAction.sequence([
			SKAction.animate(with: self.moveTextures(),
							 timePerFrame: self.timePerFrame(),
							 resize: true,
							 restore: false),
			SKAction.animate(with: self.moveTextures(),
							 timePerFrame: self.timePerFrame(),
							 resize: true,
							 restore: false).reversed()
		])
	)

	init(kind: Kind) {
		self.kind = kind
	}

	func start() {
		node.run(moveAction)
	}

	func die() {
		self.isDead = true
		self.node.removeAllActions()
		self.node.texture = self.deathTexture()

		self.node.run(.wait(forDuration: 0.8)) {
			self.node.run(.animate(with: self.deathFadeTextures(),
								   timePerFrame: 0.2,
								   resize: true,
								   restore: false)) {
				self.isDeadAnimationCompleted = true
			}
		}

		self.onDeathHandler?()
	}

	override func update(dt: TimeInterval, level: GameLevel) {
		guard !isDead else {
			if self.isDeadAnimationCompleted {
				level.removeEnemy(self)
			}
			return
		}

		self.movementStrategy.update(dt: dt, entity: self, level: level)

		switch movementStrategy.direction {
		case .left:
			node.xScale = -1
		default:
			node.xScale = 1
		}

		if let player = level.player, player.intersects(self) {
			player.handleEnemyHit(entity: self)
		}
	}

	private func timePerFrame() -> TimeInterval {
		switch self.kind {
		case .kondoria: return 0.2
		default: return 0.1
		}
	}

	private func deathTexture() -> SKTexture {
		switch self.kind {
		case .balloom: return TextureSource.Enemy.balloomDeath
		case .dall: return TextureSource.Enemy.dallDeath
		case .oneal: return TextureSource.Enemy.onealDeath
		case .minvo: return TextureSource.Enemy.minvoDeath
		case .kondoria: return TextureSource.Enemy.kondoriaDeath
		case .ovapi: return TextureSource.Enemy.ovapiDeath
		case .pass: return TextureSource.Enemy.passDeath
		case .pontan: return TextureSource.Enemy.pontanDeath

		}
	}

	private func deathFadeTextures() -> [SKTexture] {
		switch self.kind {
		case .balloom, .pass, .pontan, .minvo: return TextureSource.Enemy.pinkDeathFade
		case .dall, .ovapi: return TextureSource.Enemy.purpleDeathFade
		case .oneal, .kondoria: return TextureSource.Enemy.blueDeathFade
		}
	}

	private func moveTextures() -> [SKTexture] {
		switch self.kind {
		case .balloom: return TextureSource.Enemy.balloomRight
		case .dall: return TextureSource.Enemy.dallRight
		case .oneal: return TextureSource.Enemy.onealRight
		case .minvo: return TextureSource.Enemy.minvoRight
		case .kondoria: return TextureSource.Enemy.kondoriaRight
		case .ovapi: return TextureSource.Enemy.ovapiRight
		case .pass: return TextureSource.Enemy.passRight
		case .pontan: return TextureSource.Enemy.pontanRight

		}
	}

	private func makeMovementStrategy() -> MovementStategy {
		switch self.kind {
		case .balloom:
			return RandomMovement()
		case .dall, .kondoria:
			return ChaseMovement(defaultMovement: RandomMovement())
		default:
			return RandomMovement()
		}
	}
}
