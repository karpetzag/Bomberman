//
//  Tile.swift
//  BM
//
//  Created by Карпец Андрей on 23.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Foundation

enum TileType {
	case block, wall, empty
}

typealias Tiles = [[TileType]]

struct TilePosition: Hashable {
	var row,column: Int

	static func +(position: TilePosition, direction: Direction) -> TilePosition {
		switch direction {
		case .right: return TilePosition(row: position.row, column: position.column + 1)
		case .left: return TilePosition(row: position.row, column: position.column - 1)
		case .down: return TilePosition(row: position.row - 1, column: position.column)
		case .up: return TilePosition(row: position.row + 1, column: position.column)
		}
	}

	func distance(to: TilePosition) -> Float {
		let dx = to.column - self.column
		let dy = to.row - self.row
		let distance = sqrt(Float(dx*dx + dy*dy))
		return distance
	}
}

extension Tiles {

	func tile(at position: TilePosition) -> TileType {
		self[position.column][position.row]
	}
}
