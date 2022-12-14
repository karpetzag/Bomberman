//
//  Explosion.swift
//  BM
//
//  Created by Карпец Андрей on 30.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class Explosion: Entity {

	let area: ExplosionArea

	let center = ExplosionCore()

	private var isDone: Bool {
		return self.flames.first?.isCompleted ?? self.center.isCompleted
	}

	private(set) var flames = [BombFlame]()

	init(area: ExplosionArea) {
		self.area = area
		super.init()
		self.flames = self.flamesForArea(area)
	}

	func start() {
		AudioPlayer.shared.playFx(name: "explosion.mp3")
		center.start()
		flames.forEach({ $0.activate() })
	}

	override func update(dt: TimeInterval, level: GameLevel) {
		for flame in flames {
			if let player = level.player, flame.intersects(player) {
				player.didCollideWithEntity(entity: flame)
			}

			for enemy in level.enemies {
				if !enemy.isDead && enemy.intersects(flame) {
					level.killEnemy(enemy)
				}
			}

			for (_, bomb) in level.bombs {
				let intersection = flame.node.frame.intersection(bomb.node.frame)
				if bomb.timeLeft > 0 && (intersection.width > 0 && intersection.height > 0) {
					bomb.setReadyToExplode()
				}
			}

			if let exit = level.exit {
				if flame.intersects(exit) {
					level.spawnEnemyFromExit()
				}
			}
		}

		let blocks = area.positionForBlockHitByExplosion()
		blocks.forEach {
			if level.hasBlock($0) {
				level.destroyBlock(position: $0)
			} else if let bomb = level.bombs[$0] {
				bomb.setReadyToExplode()
			}
		}

		if isDone {
			level.removeExplosion(self)
		}
	}

	private func flamesForArea(_ area: ExplosionArea) -> [BombFlame] {
		var flames = [BombFlame]()
		for (direction, flame) in area.flameAreaByDirection {
			guard flame.length > 0 else {
				continue
			}
			flames.append(.init(direction: direction, length: flame.length, isBlocked: flame.isBlocked))
		}

		return flames
	}
}
