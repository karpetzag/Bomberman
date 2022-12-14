//
//  BonusGame.swift
//  BM
//
//  Created by Andrey Karpets on 24.11.2022.
//  Copyright © 2022 AK. All rights reserved.
//

import Foundation

protocol BonusGameDelegate: AnyObject {

	func gameDidEnd(_ game: BonusGame)

	func gameTimeLeftDidChange(game: BonusGame, timeLeft: TimeInterval)
}

class BonusGame {

	weak var delegate: BonusGameDelegate?

	private let player: Player
	private let level: GameLevel
	private let layout: LevelLayout

	private var isCompleted = false
	private var timeLeft: TimeInterval = GameConfiguration.bonusGameDuration

	private lazy var possibleSpawnPositions: [TilePosition] = {
		var positions = [TilePosition]()
		for columnIndex in 0..<layout.tiles.count {
			for rowIndex in 0..<layout.tiles[columnIndex].count {
				if layout.tiles[columnIndex][rowIndex] == .empty {
					positions.append(.init(row: rowIndex, column: columnIndex))
				}
			}
		}
		return positions
	}()

	init(player: Player, progress: GameProgress, level: GameLevel, layout: LevelLayout) {
		self.player = player
		self.level = level
		self.layout = layout
	}

	func start() {
		self.level.addPlayer(player, row: 1, column: 1)
		AudioPlayer.shared.playMusic(name: SoundName.bonusStage.rawValue)
		self.spawnEnemy()
	}

	func update(dt: TimeInterval) {
		if self.isCompleted {
			return
		}

		if self.timeLeft > 0 {
			self.timeLeft -= dt
			self.delegate?.gameTimeLeftDidChange(game: self, timeLeft: timeLeft)
			if self.timeLeft < 0 {
				self.handleTimeOut()
				if self.isCompleted {
					return
				}
			}
		}

		self.level.update(dt: dt)

		guard self.level.enemies.count < 10 else {
			return
		}

		self.spawnEnemy()
	}

	private func handleTimeOut() {
		self.isCompleted = true
		self.player.stop()
		AudioPlayer.shared.stopMusic()
		self.delegate?.gameDidEnd(self)
	}

	private func spawnEnemy() {
		guard let position = self.possibleSpawnPositions.randomElement() else {
			return
		}

		self.level.addEnemy(.init(kind: .dall), row: position.row, column: position.column)
	}
}
