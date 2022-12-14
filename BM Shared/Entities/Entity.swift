//
//  Entity.swift
//  BM
//
//  Created by Карпец Андрей on 18.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

protocol MovableEntity: Entity {

	var speed: CGFloat { get }

	var canPassBlocks: Bool { get }

	var canPassBombs: Bool { get }
}

class Entity {

	private(set) var node = SKSpriteNode()

	func update(dt: TimeInterval, level: GameLevel) {}

	func intersects(_ entity: Entity) -> Bool {
		let frame = hitBox.intersection(entity.hitBox)
		guard !frame.isNull else {
			return false
		}

		return frame.width > 1 && frame.height > 1
	}

	var hitBox: CGRect {
		return self.node.frame.insetBy(dx: 1, dy: 1)
	}
}
