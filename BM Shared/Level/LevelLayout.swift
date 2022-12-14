//
//  LevelLayout.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

struct LevelParameters {

	let powerUp: PowerUpType
	let blocksDensity: Float // 0.0-1.0
	let numberOfEnemiesPerKind: [Enemy.Kind: Int]
	let exitEnemies: [Enemy.Kind]

	static func parameters(levelNumber: Int, playerSkills: PlayerSkills) -> LevelParameters {
		let enemies: [Enemy.Kind: Int]
		var blocksDensity: Float = 0.2
		switch levelNumber {
		case 1:
			enemies = [.balloom: 10]
			blocksDensity += 0.5
		case 2...4:
			blocksDensity += 0.1
			enemies = [.balloom: 4, .oneal: 2]
		case 5:
			enemies = [.balloom: 2, .oneal: 2, .dall: 2]
		case 6...10:
			blocksDensity += 0.2
			enemies = [.balloom: Int.random(in: 1...2), .dall: Int.random(in: 2...3), .kondoria: Int.random(in: 2...3)]
		case 11...20:
			blocksDensity += 0.3
			enemies = [.oneal: Int.random(in: 1...2), .minvo: Int.random(in: 2...3), .kondoria: Int.random(in: 2...3)]
		case 21...30:
			blocksDensity += 0.35
			enemies = [
					   .minvo: Int.random(in: 2...3),
					   .kondoria: Int.random(in: 2...3),
					   .pass: Int.random(in: 2...3),
					   .dall: Int.random(in: 2...4)]
		case 31...40:
			blocksDensity += 0.4
			enemies = [
					   .minvo: Int.random(in: 2...3),
					   .kondoria: Int.random(in: 2...5),
					   .pass: Int.random(in: 3...5),
					   .ovapi: Int.random(in: 3...5)
			]
		case 41...49:
			blocksDensity += 0.5
			enemies = [
					   .minvo: Int.random(in: 2...3),
					   .kondoria: Int.random(in: 2...5),
					   .pass: Int.random(in: 2...5),
					   .ovapi: Int.random(in: 2...5),
					   .balloom: Int.random(in: 2...5)
			]
		case 50:
			blocksDensity += 0.55
			enemies = [
					   .minvo: 5,
					   .kondoria: 5,
					   .pass: 3,
					   .pontan: 4
			]
		default:
			enemies = [:]
		}

		return .init(powerUp: self.randomPowerUp(levelNumber: levelNumber, playerSkills: playerSkills),
					 blocksDensity: blocksDensity,
					 numberOfEnemiesPerKind: enemies,
					 exitEnemies: [.oneal]
		)
	}

	private static func randomPowerUp(levelNumber: Int, playerSkills: PlayerSkills) -> PowerUpType {
		switch levelNumber {
		case 1...10:
			var types = [PowerUpType.flames, PowerUpType.bomb]
			if playerSkills.speed != .fast {
				types.append(.speed)
			}
			return types.randomElement()!
		case 11...20:
			return [PowerUpType.bomb, PowerUpType.flames, .bombpass].randomElement()!
		case 21...30:
			return [PowerUpType.bomb, PowerUpType.flames, .bombpass, .flames, .blockpass].randomElement()!
		case 31...40:
			return [PowerUpType.bomb, PowerUpType.flames, .bombpass, .flames, .blockpass, .detonator].randomElement()!
		case 41...50:
			return [PowerUpType.bomb, PowerUpType.flames, .bombpass, .flames, .blockpass, .detonator].randomElement()!
		default:
			return .bomb
		}
	}
}

struct LevelLayout {

	static let minNumberOfColumns = 10
	static let minNumberOfRows = 8

	struct EnemySpawnInfo {
		let kind: Enemy.Kind
		let positon: TilePosition
	}

	let playerStartPosition: TilePosition
	let powerUpPosition: TilePosition
	let powerUp: PowerUpType
	let exitPosition: TilePosition
	let enemiesSpawnPosition: [EnemySpawnInfo]
	let tiles: [[TileType]]

	static func generateBonusGameLayout(numberOfColumns: Int, numberOfRows: Int, enemies: [Enemy.Kind]) -> LevelLayout {
		var tiles = Array(repeating: [TileType](repeating: .empty, count: numberOfRows), count: numberOfColumns)
		for column in (0..<numberOfColumns) {
			for row in 0..<numberOfRows {
				if (column % 2 == 0 && row % 2 == 0)
					|| column == 0
					|| row == 0
					|| column == numberOfColumns - 1
					|| row == numberOfRows - 1 {
					tiles[column][row] = .wall
				}
			}
		}
		return LevelLayout(playerStartPosition: .init(row: 1, column: 1),
						   powerUpPosition: .init(row: 0, column: 0),
						   powerUp: .bomb,
						   exitPosition: .init(row: 0, column: 0),
						   enemiesSpawnPosition: [], tiles: tiles)
	}

	static func generate(numberOfColumns: Int, numberOfRows: Int, parameters: LevelParameters) -> LevelLayout {
		var numberOfColumns = numberOfColumns
		var numberOfRows = numberOfRows

		if numberOfRows < minNumberOfRows || numberOfColumns < minNumberOfColumns {
			assertionFailure("Invalid number of columns and rows")
			numberOfColumns = minNumberOfColumns
			numberOfRows = minNumberOfRows
		}

		var tiles = Array(repeating: [TileType](repeating: .empty, count: numberOfRows), count: numberOfColumns)

		// No blocks in safe area
		let playerSafeAreaWidth = 5
		let playerSafeAreaHeight = 4

		var blocksPositions = [TilePosition]()
		for column in (0..<numberOfColumns) {
			for row in 0..<numberOfRows {
				if (column % 2 == 0 && row % 2 == 0)
					|| column == 0
					|| row == 0
					|| column == numberOfColumns - 1
					|| row == numberOfRows - 1 {
					tiles[column][row] = .wall
				} else if (column < playerSafeAreaWidth && row == 1) || (column == 1 && row < playerSafeAreaHeight) {
					continue
				} else if Int.random(in: 0..<100) < Int(parameters.blocksDensity * 100) {
					tiles[column][row] = .block
					blocksPositions.append(.init(row: row, column: column))
				}
			}
		}

		let xPositions = (playerSafeAreaWidth..<numberOfColumns - 1).filter { $0 % 2 != 0 }
		let yPositions = (playerSafeAreaHeight..<numberOfRows - 1).filter { $0 % 2 != 0 }

		var enemyPositions = [TilePosition]()
		let numberOfEnemies = parameters.numberOfEnemiesPerKind.reduce(0, { $0 + $1.value })
		for _ in 0..<numberOfEnemies {
			let x = xPositions.randomElement()!
			let y = yPositions.randomElement()!
			enemyPositions.append(TilePosition(row: y, column: x))

			if tiles[x][y] == .block {
				tiles[x][y] = .empty
			}
		}

		var enemyInfo = [EnemySpawnInfo]()
		for (kind, count) in parameters.numberOfEnemiesPerKind {
			for _ in 0..<count {
				let info = EnemySpawnInfo(kind: kind, positon: enemyPositions.removeLast())
				enemyInfo.append(info)
			}
		}

		let exitIndex = (0..<blocksPositions.count).randomElement()!
		let exitPosition = blocksPositions[exitIndex]
		blocksPositions.remove(at: exitIndex)

		let powerUpIndex = (0..<blocksPositions.count).randomElement()!
		let powerUpPosition = blocksPositions[powerUpIndex]
		let layout = LevelLayout(playerStartPosition: .init(row: 1, column: 1), powerUpPosition: powerUpPosition,
								 powerUp: parameters.powerUp,
								 exitPosition: exitPosition,
								 enemiesSpawnPosition: enemyInfo,
								 tiles: tiles)

		return layout
	}
}
