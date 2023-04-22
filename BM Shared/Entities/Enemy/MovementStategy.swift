//
//  MovementStategy.swift
//  BM
//
//  Created by Карпец Андрей on 29.10.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Foundation

protocol MovementStategy {

	var direction: Direction { get }

	func update(dt: TimeInterval, entity: MovableEntity, level: GameLevel)
}

class Movement: MovementStategy {

	fileprivate(set) var direction = Direction.left

	func update(dt: TimeInterval, entity: MovableEntity, level: GameLevel) {}
}

class RandomMovement: Movement {

	override func update(dt: TimeInterval, entity: MovableEntity, level: GameLevel) {
		if !level.move(entity: entity, direction: direction, speed: entity.speed, dt: dt) {
			direction = Direction.allCases.randomElement()!
		}
	}
}

class ChaseMovement: Movement {

	enum Constants {
		static let maxDistanceToPlayer = 5
	}

	private var defaultMovement: MovementStategy

	private var usingDefaultMovement = false

	init(defaultMovement: MovementStategy) {
		self.defaultMovement = defaultMovement
		super.init()
	}

	override func update(dt: TimeInterval, entity: MovableEntity, level: GameLevel) {
		let currentPosition = level.positionOfEntity(entity)

		func updateWithDefaultMovement() {
			self.defaultMovement.update(dt: dt, entity: entity, level: level)
			self.direction = defaultMovement.direction
		}

		guard let next = level.navigationMap.cameFromPositions[currentPosition]   else {
			updateWithDefaultMovement()
			return
		}

		let chaseDistance: Float = 5
		guard level.playerPosition.distance(to: currentPosition) < chaseDistance else {
			updateWithDefaultMovement()
			return
		}

		if next.column > currentPosition.column {
			self.direction = .right
		} else if next.column < currentPosition.column {
			self.direction = .left
		} else if next.row > currentPosition.row {
			self.direction = .up
		} else {
			self.direction = .down
		}

		level.move(entity: entity, direction: direction, speed: entity.speed, dt: dt)
	}
}
