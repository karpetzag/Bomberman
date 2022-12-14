//
//  PathFinder.swift
//  BM
//
//  Created by Карпец Андрей on 21.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

protocol NavigationArea {

	func findFreeNeighbors(position: TilePosition) -> [TilePosition]
}

struct NavigationMap {
	let targetPosition: TilePosition
	let cameFromPositions: [TilePosition: TilePosition] // [position] -> cameFromPosition
}

class PathFinder {

	static func makeNavigationMap(targetPosition: TilePosition, area: NavigationArea) -> NavigationMap {
		let frontier = Queue(values: [targetPosition])
		var cameFrom = [TilePosition: TilePosition]()

		while !frontier.isEmpty {
			let position = frontier.dequeue()!
			let neighbors = area.findFreeNeighbors(position: position)
			for neighbor in neighbors {
				if cameFrom[neighbor] == nil {
					cameFrom[neighbor] = position
					frontier.enqueue(value: neighbor)
				}
			}
		}

		return NavigationMap(targetPosition: targetPosition, cameFromPositions: cameFrom)
	}
}
