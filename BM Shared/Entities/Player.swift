//
//  Player.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class Player: Entity, MovableEntity {

	enum State: Equatable {
		case idle(Direction)
		case walking(Direction)
		case dying
		case dead
	}

	var speed: CGFloat {
		self.skills.speed.value
	}

	var canPassBlocks: Bool {
		self.skills.canWalkThroughBlocks
	}

	var canPassBombs: Bool {
		self.skills.canWalkThroughBombs
	}

	var isDead: Bool {
		switch state {
			case .dead: return true
			default: return false
		}
	}

	var isDyingOrDead: Bool {
		switch state {
		case .dead, .dying: return true
		default: return false
		}
	}

	let skills: PlayerSkills

	private var state = State.idle(.down)

	private let input: Input
	private var lastPlacedBomb: Bomb?
	private var bombUseCooldown = 0.0

	init(input: Input, skills: PlayerSkills, level: GameLevel) {
		self.skills = skills
		self.input = input
		super.init()
		let texture = texturesForWalkAnimation(direction: .down)[0]
		self.node.texture = texture
		self.node.size = texture.size()
	}

	override func update(dt: TimeInterval, level: GameLevel) {
		guard !isDyingOrDead else {
			return
		}

		if lastPlacedBomb?.intersects(self) == false {
			lastPlacedBomb?.isBlockingPlayer = true
		}

		if bombUseCooldown > 0 {
			bombUseCooldown -= dt
		}

		if input.isKeyPressed(key: .placeBomb) && bombUseCooldown <= 0 && level.bombs.count < skills.numberOfBombs {
			if level.canPlaceBomb(position: level.playerPosition) {
				self.placeBomb(level: level)
			}
		}

		if skills.hasDetonator && input.isKeyPressed(key: .useDetonator) {
			level.findOldestBomb()?.setReadyToExplode()
		}

		var directionToWalk: Direction?

		if input.isKeyPressed(key: .up) {
			directionToWalk = .up
		}
		else if input.isKeyPressed(key: .right) {
			directionToWalk = .right
		}
		else if input.isKeyPressed(key: .down) {
			directionToWalk = .down
		}
		else if input.isKeyPressed(key: .left) {
			directionToWalk = .left
		} else if input.isKeyPressed(key: .destroyAllBlocks) {
			let blocks = level.findAllBlocks()
			blocks.forEach { position in
				level.destroyBlock(position: position)
			}
		} else if input.isKeyPressed(key: .killAllEnemies) {
			level.enemies.forEach { level.killEnemy($0) }
		}

		if let direction = directionToWalk {
			let moved = level.move(entity: self,
								   direction: direction,
								   speed: skills.speed.value,
								   dt: dt)
			if moved {
				startWalkingAnimation(direction: direction)
			}
		} else {
			stopWalking()
		}
	}

	func stop() {
		self.stopWalking()
		self.node.removeAllActions()
	}

	func die() {
		guard !self.isDyingOrDead else {
			return
		}
		
		state = .dying

		self.node.removeAllActions()
		self.stopWalkSound()
		AudioPlayer.shared.playFx(name: "player_death.wav")

		self.node.run(.animate(with: TextureSource.Player.death, timePerFrame: 0.2)) {
			self.state = .dead
		}
	}

	private func placeBomb(level: GameLevel) {
		let bomb = Bomb(time: 3,
						explosionRadius: self.skills.explosionRadius,
						position: level.playerPosition,
						orderNumber: (level.findLastPlacedBomb()?.orderNumber ?? 1) + 1)
		level.placeBomb(bomb, position: level.playerPosition)
		self.lastPlacedBomb = bomb
		bomb.prepare(startTicking: !self.skills.hasDetonator)
		self.bombUseCooldown = 0.2
		AudioPlayer.shared.playFx(name: SoundName.placeBomb.rawValue)
	}

	private func startWalkingAnimation(direction: Direction) {
		let newState = State.walking(direction)

		guard state != newState else {
			return
		}

		let animation = SKAction.animate(with: texturesForWalkAnimation(direction: direction), timePerFrame: 0.1)
		let walk = SKAction.repeatForever(animation)
		self.node.run(walk, withKey: "walk")

		self.state = newState
		self.playWalkSound(direction: direction)
	}

	private func stopWalking() {
		switch state {
		case .walking(let direction):
			self.node.removeAction(forKey: "walk")
			self.state = .idle(direction)
			self.stopWalkSound()
		default:
			return
		}
	}

	private func texturesForWalkAnimation(direction: Direction) -> [SKTexture] {
		switch direction {
		case .down: return TextureSource.Player.walkingDown
		case .up: return TextureSource.Player.walkingUp
		case .left: return TextureSource.Player.walkingLeft
		case .right: return TextureSource.Player.walkingRight
		}
	}

	private func playWalkSound(direction: Direction) {
		switch direction {
		case .down, .up:
			AudioPlayer.shared.stopLoopFx(name: "walkHorizontal.wav")
			AudioPlayer.shared.playLoopFx(name: "walkVertical.wav")
		case .left, .right:
			AudioPlayer.shared.stopLoopFx(name: "walkVertical.wav")
			AudioPlayer.shared.playLoopFx(name: "walkHorizontal.wav")
		}
	}

	private func stopWalkSound() {
		AudioPlayer.shared.stopLoopFx(name: "walkVertical.wav")
		AudioPlayer.shared.stopLoopFx(name: "walkHorizontal.wav")
	}

	override func didCollideWithEntity(entity: Entity) {
		guard entity is BombFlame && !skills.immuneToFlame || entity is Enemy && !skills.immuneToEnemies else {
			return
		}

		self.die()
	}
}
