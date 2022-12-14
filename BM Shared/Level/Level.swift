//
//  Level.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

struct TileMapNodeData {

	let tileMap: SKTileMapNode
	let wallTile: SKTileGroup
	let blockTile: SKTileGroup
}

class GameLevel {

	var playerPosition: TilePosition {
		guard let player = self.player else {
			return .init(row: 0, column: 0)
		}

		return TilePosition(row: self.tileMap.tileRowIndex(fromPosition: player.node.position),
							column: self.tileMap.tileColumnIndex(fromPosition: player.node.position))
	}

	var onDeathHandler: ((Enemy) -> Void)?

	private(set) var navigationMap = NavigationMap(targetPosition: .init(row: 0, column: 0),
												   cameFromPositions: [:])

	private(set) var bombs = [TilePosition: Bomb]()
	private(set) var enemies = [Enemy]()
	private(set) var explosions = [TilePosition: Explosion]()
	private(set) var exit: Entity?
	private(set) var powerUp: PowerUp?

	private var tiles: [[TileType]]

	private(set) weak var player: Player?
	private var navigationMapUpdateTime: TimeInterval = 0.0

	private let layout: LevelLayout
	private let tileMap: SKTileMapNode
	private let tileMapNodeData: TileMapNodeData

	init(tiles: [[TileType]], tileMapNodeData: TileMapNodeData, layout: LevelLayout) {
		self.layout = layout
		self.tiles = tiles
		self.tileMapNodeData = tileMapNodeData
		self.tileMap = tileMapNodeData.tileMap
		self.fillMap()
	}

	func update(dt: TimeInterval) {
		self.powerUp?.update(dt: dt, level: self)
		self.player?.update(dt: dt, level: self)

		self.explosions.forEach { (_, explosion) in
			explosion.update(dt: dt, level: self)
		}

		self.enemies.forEach {
			$0.update(dt: dt, level: self)
		}

		for (_, bomb) in self.bombs {
			bomb.update(dt: dt, level: self)
		}

		self.navigationMapUpdateTime -= dt
		if self.navigationMapUpdateTime <= 0 {
			self.updateNavigationMap(targetPosition: self.playerPosition)
			self.navigationMapUpdateTime = 2
		}
	}

	func updateNavigationMap(targetPosition: TilePosition) {
		self.navigationMap = PathFinder.makeNavigationMap(targetPosition: targetPosition, area: self)
	}

	func setTile(_ tile: TileType, position: TilePosition) {
		self.tiles[position.column][position.row] = tile
		switch tile {
		case .block:
			self.tileMapNodeData.tileMap.setTileGroup(tileMapNodeData.blockTile, forColumn: position.column, row: position.row)
		case .wall:
			self.tileMapNodeData.tileMap.setTileGroup(tileMapNodeData.wallTile, forColumn: position.column, row: position.row)
		case .empty:
			self.tileMapNodeData.tileMap.setTileGroup(nil, forColumn: position.column, row: position.row)
		}
	}

	func findAllBlocks() -> [TilePosition] {
		var result = [TilePosition]()
		self.forEachTile { position in
			if self.tileAt(position: position) == .block {
				result.append(position)
			}
		}
		return result
	}

	func hasBlock(_ tilePosition: TilePosition) -> Bool {
		return self.tiles[tilePosition.column][tilePosition.row] == .block
	}

	func destroyBlock(position: TilePosition) {
		if self.layout.exitPosition == position {
			self.destroyBlock(position: position, animated: false)
			self.addExit(position: position)
		} else if layout.powerUpPosition == position {
			self.destroyBlock(position: position, animated: false)
			self.addPowerUp(layout.powerUp, position: position)
		} else {
			self.destroyBlock(position: position, animated: true)
		}
	}

	private func destroyBlock(position: TilePosition, animated: Bool) {
		guard hasBlock(position) else {
			return
		}

		self.tiles[position.column][position.row] = .empty
		let blockSprite = SKSpriteNode()
		let action = SKAction.animate(with: TextureSource.Block.destruction, timePerFrame: 0.07, resize: true, restore: false)
		let point = self.tileMapNodeData.tileMap.centerOfTile(atColumn: position.column, row: position.row)
		self.tileMapNodeData.tileMap.addChild(blockSprite)
		blockSprite.position = point
		blockSprite.run(SKAction.sequence([.customAction(withDuration: 0, actionBlock: { (_, _) in
			self.setTile(.empty, position: TilePosition(row: position.row, column: position.column))
		}), action])) {
			blockSprite.removeFromParent()
		}
	}

	func spawnEnemyFromExit() {
		(0..<8).forEach { _ in
			let row = self.tileMap.tileRowIndex(fromPosition: self.exit!.node.position)
			let column = self.tileMap.tileColumnIndex(fromPosition: self.exit!.node.position)
			self.addEnemy(Enemy(kind: .oneal), row: row, column: column)
		}
	}

	@discardableResult
	func move(entity: MovableEntity, direction: Direction, speed: CGFloat, dt: TimeInterval) -> Bool {
		var updatedCollisionRect = entity.hitBox

		var x: CGFloat = 0
		var y: CGFloat = 0

		let distance = speed * CGFloat(dt)

		switch direction {
		case .down: y = -distance
		case .up: y = distance
		case .left: x = -distance
		case .right: x = distance
		}

		updatedCollisionRect = updatedCollisionRect.offsetBy(dx: x, dy: y)
		let tilesToCollide = Set(self.tilesForFrame(updatedCollisionRect, direction: direction))

		let currentTileColumn = tileMap.tileColumnIndex(fromPosition: entity.node.position)
		let currentTileRow = tileMap.tileRowIndex(fromPosition: entity.node.position)

		for position in tilesToCollide {
			guard self.isValidPosition(position) else {
				return false
			}
			let tile = self.tileAt(position: position)
			if tile == .block && !entity.canPassBlocks || tile == .wall {
				let index = !y.isZero ? (y > 0 ? 1 : -1) : x > 0 ? 1 : -1
				let nextTile = !y.isZero ? tiles[currentTileColumn][currentTileRow + index]
				: tiles[currentTileColumn + index][currentTileRow]
				if nextTile == .empty || (nextTile == .block && entity.canPassBlocks) {
					if y.isZero {
						let direction = position.row < currentTileRow ? Direction.up : Direction.down
						entity.node.position.y += direction == .up ? distance : -distance
						return true
					} else {
						let direction = position.column < currentTileColumn ? Direction.right : Direction.left
						entity.node.position.x += direction == .right ? distance : -distance
						return true
					}
				}
				return false
			}

			if let bomb = bombs[position], !bomb.intersects(entity) {
				return false
			}
		}

		let newPosition = CGPoint(x: entity.node.position.x + x, y: entity.node.position.y + y)

		entity.node.position = newPosition

		return true
	}

	func addPlayer(_ player: Player, row: Int, column: Int) {
		self.addEntity(player, row: row, column: column)
		self.player = player
		player.node.zPosition = 2
	}

	func removePlayer(_ player: Player) {
		self.removeEntity(player)
		self.player = nil
	}

	func addEnemy(_ enemy: Enemy, row: Int, column: Int) {
		enemy.start()
		enemy.node.zPosition = 1
		self.addEntity(enemy, row: row, column: column)
		self.enemies.append(enemy)
	}

	func removeEnemy(_ enemy: Enemy) {
		self.enemies.removeAll(where: { $0 === enemy })
		self.removeEntity(enemy)
	}

	func addExplosion(_ area: ExplosionArea) {
		guard self.explosions[area.center] == nil else {
			return
		}

		let explosion = Explosion(area: area)
		let tileSize = self.tileMap.tileSize.width / 2
		explosion.flames.forEach({
			let position = area.center + $0.direction
			$0.node.anchorPoint = .init(x: 0, y: 0.5)
			self.addEntity($0, row: position.row, column: position.column)
			switch $0.direction {
			case .down: $0.node.position.y += tileSize
			case .up: $0.node.position.y -= tileSize
			case .left: $0.node.position.x += tileSize
			case .right: $0.node.position.x -= tileSize
			}
		})
		self.addEntity(explosion.center, row: area.center.row, column: area.center.column)
		explosion.start()

		self.explosions[area.center] = explosion
	}

	func removeExplosion(_ explosion: Explosion) {
		self.explosions[explosion.area.center] = nil
		explosion.flames.forEach({ self.removeEntity($0) })
		self.removeEntity(explosion.center)
	}

	func calculateExplosionArea(row: Int, column: Int, radius: Int) -> ExplosionArea {
		func flameArea<T: Collection>(range: T, isRow: Bool) -> ExplosionArea.FlameArea where T.Element == Int {
			func isBlockingExplosion(row: Int, column: Int) -> Bool {
				return tiles[column][row] != .empty || hasBomb(row: row, column: column) || hasExplosion(row: row, column: column)
			}

			var length = 0
			var isBlocked = false

			for index in range {
				let fixedRow = isRow ? index : row
				let fixedColumn = isRow ? column : index
				if isBlockingExplosion(row: fixedRow, column: fixedColumn) {
					isBlocked = true
					break
				}
				length += 1
			}

			return .init(length: length, isBlocked: isBlocked)
		}

		var flames = [Direction: ExplosionArea.FlameArea]()
		flames[.up] = flameArea(range: row + 1..<radius + row, isRow: true)
		flames[.down] = flameArea(range: ((row - (radius - 1))..<row).reversed(), isRow: true)
		flames[.right] = flameArea(range: column + 1..<radius + column, isRow: false)
		flames[.left] = flameArea(range: ((column - (radius - 1))..<column).reversed(), isRow: false)

		return ExplosionArea(center: TilePosition(row: row, column: column), flameAreaByDirection: flames)
	}

	func canPlaceBomb(position: TilePosition) -> Bool {
		return self.bombs[position] == nil && self.tiles[position.column][position.row] == .empty
	}

	@discardableResult
	func placeBomb(_ bomb: Bomb, position: TilePosition) -> Bool {
		guard self.canPlaceBomb(position: position) else {
			return false
		}
		self.bombs[position] = bomb
		self.addEntity(bomb, row: position.row, column: position.column)
		return true
	}

	func findEmptyTiles(avoidPlayerDistance: UInt = 0) -> [TilePosition] {
		let numberOfColumns = tileMapNodeData.tileMap.numberOfColumns
		let numberOfRows = tileMapNodeData.tileMap.numberOfRows

		var positions = [TilePosition]()
		for column in 0..<numberOfColumns {
			for row in 0..<numberOfRows {
				let tile = tiles[column][row]
				if tile == .empty {
					let tilePosition = TilePosition(row: row, column: column)
					let playerPosition = self.playerPosition
					if abs(playerPosition.column - tilePosition.column) >= avoidPlayerDistance ||
					   abs(playerPosition.row - tilePosition.row) >= avoidPlayerDistance {
						positions.append(tilePosition)
					}
				}
			}
		}

		return positions
	}

	func findOldestBomb() -> Bomb? {
		self.bombs.values.sorted(by: { $0.orderNumber < $1.orderNumber }).first
	}

	func findLastPlacedBomb() -> Bomb? {
		self.bombs.values.sorted(by: { $0.orderNumber > $1.orderNumber }).first
	}

	func hasExplosion(row: Int, column: Int) -> Bool {
		return self.explosions[TilePosition(row: row, column: column)] != nil
	}

	func hasBomb(row: Int, column: Int) -> Bool {
		return self.bombs[TilePosition(row: row, column: column)] != nil
	}

	func positionOfEntity(_ entity: Entity) -> TilePosition {
		return TilePosition(row: self.tileMap.tileRowIndex(fromPosition: entity.node.position),
							column: self.tileMap.tileColumnIndex(fromPosition: entity.node.position))
	}

	func removeBomb(_ bomb: Bomb) {
		self.bombs[bomb.position] = nil
		self.removeEntity(bomb)
	}

	func addExit(position: TilePosition) {
		let exit = StaticEntity.exit()
		self.addEntity(exit, row: position.row, column: position.column)
		self.exit = exit
	}

	func addPowerUp(_ powerUp: PowerUpType, position: TilePosition) {
		let entity = PowerUp(type: powerUp, level: self, position: position)
		self.addEntity(entity, row: position.row, column: position.column)
		self.powerUp = entity
	}

	func removePowerUp() {
		if let powerUp = self.powerUp {
			self.removeEntity(powerUp)
			self.powerUp = nil
		}
	}

	func killEnemy(_ enemy: Enemy) {
		enemy.die()
		self.drawPoints(enemy.kind.points,
						position: enemy.node.position,
						delay: 2.5)
	}

	private func drawPoints(_ points: Int, position: CGPoint, delay: TimeInterval) {
		let label = SKLabelNode(text: "\(points)")
		label.fontSize = 10
		label.fontName = "Verdana-Bold"
		label.color = .white
		label.position = position
		tileMap.addChild(label)
		let action = SKAction.sequence([.wait(forDuration: delay),
										.group([.fadeAlpha(to: 0, duration: 0.1), .scale(by: 1.2, duration: 0.1)])])
		label.run(action, completion: label.removeFromParent)
	}

	private func addEntity(_ entity: Entity, row: Int, column: Int) {
		let position = tileMap.centerOfTile(atColumn: column, row: row)
		self.tileMap.addChild(entity.node)
		entity.node.position = position
	}

	private func removeEntity(_ entity: Entity) {
		entity.node.removeFromParent()
	}

	private func tileAt(position: TilePosition) -> TileType {
		return tiles[position.column][position.row]
	}

	private func fillMap() {
		let numberOfColumns = tileMapNodeData.tileMap.numberOfColumns
		let numberOfRows = tileMapNodeData.tileMap.numberOfRows
		let map = tileMapNodeData.tileMap

		for column in 0..<numberOfColumns {
			for row in 0..<numberOfRows {
				let tile = tiles[column][row]
				switch tile {
				case .block:
					map.setTileGroup(tileMapNodeData.blockTile, forColumn: column, row: row)
				case .wall:
					map.setTileGroup(tileMapNodeData.wallTile, forColumn: column, row: row)
				case .empty:
					break
				}
			}
		}
	}

	private func forEachTile(handler: (TilePosition) -> Void) {
		let numberOfColumns = tileMapNodeData.tileMap.numberOfColumns
		let numberOfRows = tileMapNodeData.tileMap.numberOfRows

		for column in 0..<numberOfColumns {
			for row in 0..<numberOfRows {
				handler(TilePosition(row: row, column: column))
			}
		}
	}

	private func tilesForFrame(_ frame: CGRect, direction: Direction) -> [TilePosition] {
		var points: [CGPoint]
		switch direction {
		case .left: points = [frame.topLeft, frame.bottomLeft]
		case .right: points = [frame.topRight, frame.bottomRight]
		case .down: points = [frame.bottomLeft, frame.bottomRight]
		case .up: points = [frame.topLeft, frame.topRight]
		}
		return points.map { corner in
			let row = self.tileMap.tileRowIndex(fromPosition: corner)
			let column = self.tileMap.tileColumnIndex(fromPosition: corner)
			return TilePosition(row: row, column: column)
		}
	}
}

extension GameLevel: NavigationArea {

	func findFreeNeighbors(position: TilePosition) -> [TilePosition] {
		let positions = [position + Direction.up,
						 position + Direction.down,
						 position + Direction.left,
						 position + Direction.right]

		return positions.filter {
			isValidPosition($0) &&
			tiles[$0.column][$0.row] == .empty &&
			!hasBomb(row: $0.row, column: $0.column)
		}
	}

	func isValidPosition(_ position: TilePosition) -> Bool {
		position.column > 0 && position.column < tiles.count - 1 && position.row > 0 && position.row < tiles[0].count - 1
	}
}
