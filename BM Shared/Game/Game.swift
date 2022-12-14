//
//  Game.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

enum GameEndReason {
	case playerDied
	case playerWon
}

class GameProgress {

	private(set) var life: Int

	private(set) var points = 0

	func addLife() {
		self.life += 1
	}

	func removeLife() {
		self.life -= 1
	}

	func addPoints(_ points: Int) {
		self.points += points
	}

	init(life: Int, points: Int = 0) {
		self.life = life
		self.points = points
	}

	static func makeInitialProgres() -> GameProgress {
		return GameProgress(life: 3, points: 0)
	}
}

protocol GameDelegate: AnyObject {

	func gameDidEnd(_ game: Game, reason: GameEndReason)

	func gameProgressDidChange(game: Game, progress: GameProgress)

	func gameTimeLeftDidChange(game: Game, timeLeft: TimeInterval)
}

class Game {

	weak var delegate: GameDelegate?

	private(set) var progress: GameProgress

	private let player: Player
	private let level: GameLevel
	private let layout: LevelLayout

	private(set) var timeLeft: TimeInterval = GameConfiguration.gameDuration
	private(set) var isCompleted = false

	init(player: Player,
		 progress: GameProgress,
		 level: GameLevel,
		 layout: LevelLayout) {
		self.player = player
		self.level = level
		self.layout = layout
		self.progress = progress
	}

	func start() {
		self.level.addPlayer(player,
							 row: layout.playerStartPosition.row,
							 column: layout.playerStartPosition.column)

		for enemyInfo in layout.enemiesSpawnPosition {
			let enemy = Enemy(kind: enemyInfo.kind)
			enemy.onDeathHandler = { [weak self] in
				self?.checkForLastEnemyDeath()
				self?.addPoints(enemy.kind.points)
			}
			self.level.addEnemy(enemy, row: enemyInfo.positon.row, column: enemyInfo.positon.column)
		}

		AudioPlayer.shared.playMusic(name: SoundName.stageTheme.rawValue)
	}

	func update(dt: TimeInterval) {
		if self.isCompleted {
			return
		}

		if self.timeLeft > 0 {
			self.timeLeft -= dt
			self.delegate?.gameTimeLeftDidChange(game: self, timeLeft: self.timeLeft)
			if timeLeft < 0 {
				self.handleTimeOut()
			}
		}

		if self.player.isDead == true {
			self.completeGame(reason: .playerDied)
			self.level.removePlayer(self.player)
		}

		self.level.update(dt: dt)

		self.checkForExit()
	}

	func handleTimeOut() {
		let safeDistance: UInt = 2
		let positions = self.level.findEmptyTiles(avoidPlayerDistance: safeDistance).shuffled()
		let numberOfEnemiesToSpawn = 8
		for _ in 0..<numberOfEnemiesToSpawn {
			let enemy = Enemy(kind: .pontan)
			guard let position = positions.randomElement() else {
				continue
			}
			self.level.addEnemy(enemy, row: position.row, column: position.column)
		}
	}

	private func checkForExit() {
		if let exit = self.level.exit, self.level.enemies.isEmpty {
			if self.player.intersects(exit) {
				self.isCompleted = true
				self.completeGame(reason: .playerWon)
			}
		}
	}

	private func checkForLastEnemyDeath() {
		if self.level.enemies.allSatisfy({ $0.isDead == true }) {
			AudioPlayer.shared.playFx(name: SoundName.allEnemiesDead.rawValue)
		}
	}

	private func addPoints(_ points: Int) {
		self.progress.addPoints(points)
		self.delegate?.gameProgressDidChange(game: self, progress: progress)
	}

	func completeGame(reason: GameEndReason) {
		self.isCompleted = true
		self.player.stop()
		AudioPlayer.shared.stopMusic()

		switch reason {
		case .playerDied:
			self.progress.removeLife()
		case .playerWon:
			self.progress.addLife()
		}

		self.delegate?.gameProgressDidChange(game: self, progress: self.progress)
		self.delegate?.gameDidEnd(self, reason: reason)
	}
}
