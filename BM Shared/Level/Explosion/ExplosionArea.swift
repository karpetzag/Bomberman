//
//  ExplosionArea.swift
//  BM
//
//  Created by Карпец Андрей on 18.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Foundation

struct ExplosionArea {

	struct FlameArea {
		let length: Int
		let isBlocked: Bool
	}

	let center: TilePosition

	let flameAreaByDirection: [Direction: FlameArea]

	func positionForBlockHitByExplosion() -> [TilePosition] {
		var positions = [TilePosition]()
		for (direction, flame) in flameAreaByDirection {
			guard flame.isBlocked else {
				continue
			}

			var position = center
			let length = flame.length + 1
			switch direction {
			case .right:
				position.column += length
			case .left:
				position.column -= length
			case .down:
				position.row -= length
			case .up:
				position.row += length
			}

			positions.append(position)
		}

		return positions
	}
}
