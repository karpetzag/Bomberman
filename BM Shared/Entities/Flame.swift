//
//  File.swift
//  BM
//
//  Created by Карпец Андрей on 18.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class ExplosionCore: Entity {

	private(set) var isCompleted = false

	override init() {
		super.init()
		self.node.size = GameConfiguration.tileSize
	}

	func start() {
		let action = SKAction.animate(with: TextureSource.Bomb.explosionCenter, timePerFrame: 0.05)
		let reverse = action.reversed()
		self.node.run(SKAction.sequence([action, reverse, .fadeAlpha(to: 0, duration: 0.1)]), completion: { [weak self] in
			self?.isCompleted = true
		})
	}
}

class BombFlame: Entity {

	let direction: Direction

	override var hitBox: CGRect {
		return self.node.frame.insetBy(dx: 4, dy: 4)
	}

	private var flameParts = [SKSpriteNode]()

	private(set) var isInflictingDamage = false
	private(set) var isCompleted = false
	private let isBlocked: Bool

	init(direction: Direction, length: Int, isBlocked: Bool) {
		self.direction = direction
		self.isBlocked = isBlocked

		super.init()

		let size = GameConfiguration.tileSize

		self.node.size = CGSize(width: size.width * CGFloat(length), height: size.height)
		for i in 0..<length {
			let part = SKSpriteNode(texture: nil, size: size)

			self.flameParts.append(part)
			self.node.addChild(part)
			part.anchorPoint = .init(x: 0, y: 0.5)
			part.position.x += CGFloat(CGFloat(i) * size.width)
		}


		switch direction {
		case .left:
			self.node.xScale = -1
		case .up:
			self.node.zRotation =  .pi / 2
		case .down:
			self.node.zRotation =  .pi / -2
		default:
			break
		}
	}

	func activate() {
		for (index, part) in flameParts.enumerated() {
			let isEnd = flameParts.count == index + 1
			let middleParts = TextureSource.Explosion.explosionMiddle
			let endParts = TextureSource.Explosion.explosionEnd
			let texutes = isEnd ? (isBlocked ? middleParts : endParts) : middleParts
			let action = SKAction.animate(with: texutes, timePerFrame: 0.05)
			let reverse = action.reversed()
			part.run(SKAction.sequence([.wait(forDuration: 0.01 * Double(index)), action, reverse]), completion: {
				if index == self.flameParts.count - 1 {
					self.isCompleted = true
				}
			})
		}
	}
}
