//
//  PowerUp.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

enum PowerUpType: CaseIterable {

	case bomb
	case speed
	case flames
	case blockpass
	case detonator
	case bombpass
	case flamepass

	var texture: SKTexture {
		switch self {
		case .bombpass: return TextureSource.PowerUp.speed
		case .detonator: return TextureSource.PowerUp.detonator
		case .flamepass: return TextureSource.PowerUp.flamepass
		case .blockpass: return TextureSource.PowerUp.blockpass
		case .speed: return TextureSource.PowerUp.speed
		case .flames: return TextureSource.PowerUp.flamepass
		case .bomb: return TextureSource.PowerUp.bomb
		}
	}
}

class PowerUp: Entity {

	let type: PowerUpType

	let position: TilePosition

	init(type: PowerUpType, level: GameLevel, position: TilePosition) {
		self.type = type
		self.position = position
		super.init()
		self.node.texture = type.texture
		self.node.size = type.texture.size()
	}

	override func update(dt: TimeInterval, level: GameLevel) {
		super.update(dt: dt, level: level)

		if level.playerPosition == position {
			self.apply(level: level)
			AudioPlayer.shared.playFx(name: SoundName.powerup.rawValue)
			AudioPlayer.shared.playMusic(name: SoundName.musicAfterPowerup.rawValue)
			level.removePowerUp()
		}
	}

	private func apply(level: GameLevel) {
		guard let skills = level.player?.skills else {
			return
		}

		switch type {
		case .bombpass:
			skills.canWalkThroughBombs = true
		case .detonator:
			skills.hasDetonator = true
		case .flamepass:
			skills.immuneToFlame = true
		case .blockpass:
			skills.canWalkThroughBlocks = true
		case .speed:
			skills.speed = .fast
		case .flames:
			skills.explosionRadius += 1
		case .bomb:
			skills.numberOfBombs += 1
		}
	}
}
