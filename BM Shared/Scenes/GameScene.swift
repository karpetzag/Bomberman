//
//  GameScene.swift
//  BM Shared
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class LevelIntroSprite: SKSpriteNode {

	var title: String? {
		didSet {
			label.text = title
		}
	}

	private let label = SKLabelNode()

	init(size: CGSize) {
		super.init(texture: nil, color: .black, size: size)

		label.fontSize = 32
		label.fontName = "Verdana-Bold"
		addChild(label)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class GameScene: BaseScene {

	enum GameType {
		case main(Game), bonus(BonusGame)

		func update(dt: TimeInterval) {
			switch self {
			case .bonus(let game):
				game.update(dt: dt)
			case .main(let game):
				game.update(dt: dt)
			}
		}
	}

	private lazy var gameMenu = self.childNode(withName: "Menu")

	private var lifeLabelNode: SKLabelNode?
	private var timeLabelNode: SKLabelNode?
	private var scoreLabelNode: SKLabelNode?
	private var statsNode: SKSpriteNode?

	private lazy var levelIntroNode = LevelIntroSprite(size: .zero)

	private var prevTime: TimeInterval = 0

	private var game: GameType?
	private var levelNumber = 1
	private var input = Input()
	private var player: Player!

	private var skills = PlayerSkills()

	private var gameProgress: GameProgress = .makeInitialProgres()

	private var tilemapData: TileMapNodeData!

	private var isPauseActive = false

    override func sceneDidLoad() {
        self.setUpScene()
    }

    func setUpScene() {
		self.gameMenu?.removeFromParent()

		self.setupTileMap()

		self.statsNode = self.camera?.childNode(withName: "Stats") as? SKSpriteNode
		self.lifeLabelNode = self.statsNode?.childNode(withName: "Life") as? SKLabelNode
		self.scoreLabelNode = self.statsNode?.childNode(withName: "Score") as? SKLabelNode
		self.timeLabelNode = self.statsNode?.childNode(withName: "Time") as? SKLabelNode

		self.start(levelNumber: levelNumber)
		//self.startBonusGame(afterLevel: 1)
		//self.start(levelNumber: 1, fastStart: true)
    }

	override func didChangeSize(_ oldSize: CGSize) {
		self.levelIntroNode.size = self.size

		self.levelIntroNode.position = .zero
		self.statsNode?.size.width = self.size.width
		let statsNodeWidth = self.statsNode?.frame.width ?? 0
		if let lifeLabel = self.lifeLabelNode, let scoreLabel = self.scoreLabelNode, let timeLabel = self.timeLabelNode {
			let timeX = -statsNodeWidth / 2 + timeLabel.frame.width / 2
			timeLabel.position = CGPoint(x: timeX, y: 0.0)
			scoreLabel.position = CGPoint(x: statsNodeWidth / 2 - scoreLabel.frame.width / 2 - 10, y: 0.0)
			lifeLabel.position = CGPoint(x: scoreLabel.position.x - lifeLabel.frame.width - scoreLabel.frame.width / 2 - 10, y: 0.0)
		}
		self.resetCameraConstraints()
	}

	override func update(_ currentTime: TimeInterval) {
		if self.prevTime > 0 {
			if self.input.isKeyPressed(key: .pause) {
				self.isPauseActive = !isPauseActive
				self.prevTime = 0
				return
			}
			guard !self.isPauseActive else {
				return
			}
			let dt = currentTime - self.prevTime
			self.prevTime = currentTime

			if self.input.isKeyPressed(key: .skipLevel) {
				self.start(levelNumber: self.levelNumber, fastStart: true)
			}

			self.game?.update(dt: dt)
		}

		self.prevTime = currentTime
    }

	private func setupTileMap() {
		let blockDefinition = SKTileDefinition(texture: TextureSource.Tiles.block, size: GameConfiguration.tileSize)
		let blockGroup = SKTileGroup(tileDefinition: blockDefinition)

		let wallDefinition = SKTileDefinition(texture: TextureSource.Tiles.wall, size: GameConfiguration.tileSize)
		let wallkGroup = SKTileGroup(tileDefinition: wallDefinition)

		let tileSet = SKTileSet(tileGroups: [blockGroup, wallkGroup])
		let tileMap = SKTileMapNode(tileSet: tileSet,
									columns: GameConfiguration.levelWidth,
									rows: GameConfiguration.levelHeight,
									tileSize: GameConfiguration.tileSize)

		self.addChild(tileMap)

		let data = TileMapNodeData(tileMap: tileMap, wallTile: wallkGroup, blockTile: blockGroup)
		self.tilemapData = data
	}

	private func start(levelNumber: Int, fastStart: Bool) {
		if fastStart {
			self.resetMap(level: levelNumber)
		} else {
			self.start(levelNumber: levelNumber)
		}
	}

	private func start(levelNumber: Int) {
		self.showLevelIntro(title: "STAGE \(levelNumber)") {
			self.resetMap(level: levelNumber)
		}
	}

	private func resetMap(level: Int) {
		self.tilemapData.tileMap.removeAllChildren()
		self.tilemapData.tileMap.fill(with: nil)

		let params = LevelParameters.parameters(levelNumber: level, playerSkills: self.skills)

		let layout: LevelLayout

		layout = LevelLayout.generate(numberOfColumns: self.tilemapData.tileMap.numberOfColumns,
									  numberOfRows: self.tilemapData.tileMap.numberOfRows,
									  parameters: params)
		let level = GameLevel(tiles: layout.tiles, tileMapNodeData: self.tilemapData, layout: layout)
		self.player = Player(input: self.input, skills: self.skills, level: level)

		let game = Game(player: player, progress: self.gameProgress, level: level, layout: layout)
		game.start()
		game.delegate = self

		self.game = .main(game)

		self.updateProgress(progress: self.gameProgress)
		self.resetCameraConstraints()
	}

	private func startBonusGame(afterLevel level: Int) {
		func restart() {
			self.tilemapData.tileMap.removeAllChildren()
			self.tilemapData.tileMap.fill(with: nil)

			let layout: LevelLayout

			let progress = GameProgress.makeInitialProgres()

			layout = LevelLayout.generateBonusGameLayout(numberOfColumns: tilemapData.tileMap.numberOfColumns,
														 numberOfRows: tilemapData.tileMap.numberOfRows,
														 enemies: [.dall])
			let level = GameLevel(tiles: layout.tiles, tileMapNodeData: tilemapData, layout: layout)

			let skills = self.skills.makeCopyForBonusLevel()
			self.player = Player(input: input, skills: skills, level: level)
			let game = BonusGame(player: player, progress: progress, level: level, layout: layout)
			game.delegate = self
			game.start()

			self.game = .bonus(game)

			updateProgress(progress: progress)
			resetCameraConstraints()
		}

		showLevelIntro(title: "BONUS STAGE") {
			restart()
		}
	}

	private func showLevelIntro(title: String, time: TimeInterval = 3, completion: @escaping () -> Void) {
		camera?.addChild(self.levelIntroNode)
		self.levelIntroNode.title = title
		self.statsNode?.isHidden = true

		AudioPlayer.shared.playFx(name: SoundName.stageStart.rawValue)
		DispatchQueue.main.asyncAfter(deadline: .now() + time) {
			self.levelIntroNode.removeFromParent()
			self.statsNode?.isHidden = false
			completion()
		}
	}


	private func resetCameraConstraints() {
		guard self.player != nil && self.tilemapData != nil  else {
			return
		}

		let tileMap = self.tilemapData.tileMap
		let playerConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: player.node)
		let constraintX = SKConstraint.positionX(SKRange(lowerLimit: tileMap.frame.width / -2 + frame.width / 2,
														 upperLimit: tileMap.frame.width / 2 - frame.width / 2))

		let constraintY = SKConstraint.positionY(SKRange(lowerLimit: tileMap.frame.height / -2 + frame.height / 2,
														 upperLimit: tileMap.frame.height / 2 - frame.height / 2))

		self.camera?.constraints = [playerConstraint, constraintX, constraintY]
	}

	private func updateTimeLeft(_ timeLeft: TimeInterval) {
		guard let timeLabelNode = timeLabelNode, let statsNode = self.statsNode else {
			return
		}

		timeLabelNode.text = "Time: \(Int(timeLeft))"
		timeLabelNode.position.x = statsNode.frame.width / -2 + timeLabelNode.frame.size.width / 2 + 10
	}

	private func updateProgress(progress: GameProgress) {
		lifeLabelNode?.text = "Life: \(progress.life)"
		scoreLabelNode?.text = "Score: \(progress.points)"
	}

	private func showWinScene() {
		self.sceneManager?.presentScene(id: .end)
	}

	private func showGameOverScene() {
		self.sceneManager?.presentScene(id: .gameOver)
	}
}

// MARK: GameDelegate

extension GameScene: GameDelegate {
	func gameTimeLeftDidChange(game: Game, timeLeft: TimeInterval) {
		self.updateTimeLeft(timeLeft)
	}

	func gameProgressDidChange(game: Game, progress: GameProgress) {
		self.updateProgress(progress: progress)
	}

	func gameDidEnd(_ game: Game, reason: GameEndReason) {
		let soundFilename: String
		var shouldStartBonusGame = false
		switch reason {
		case .playerWon:
			levelNumber += 1
			soundFilename = SoundName.stageComplete.rawValue
			shouldStartBonusGame = levelNumber % 5 == 0
		case .playerDied:
			soundFilename = SoundName.lifeLost.rawValue
		}

		AudioPlayer.shared.playFx(name: soundFilename)

		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			if game.progress.life <= 0 {
				self.showGameOverScene()
				return
			}

			if self.levelNumber == GameConfiguration.numberOfLevels && reason == .playerWon {
				self.showWinScene()
				return
			}

			if shouldStartBonusGame {
				self.startBonusGame(afterLevel: self.levelNumber - 1)
			} else {
				self.start(levelNumber: self.levelNumber)
			}
		}
	}
}

extension GameScene: BonusGameDelegate {

	func gameDidEnd(_ game: BonusGame) {
		AudioPlayer.shared.playFx(name: SoundName.stageComplete.rawValue)
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.start(levelNumber: self.levelNumber)
		}
	}

	func gameTimeLeftDidChange(game: BonusGame, timeLeft: TimeInterval) {
		 updateTimeLeft(timeLeft)
	}
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
#endif

#if os(OSX)
extension GameScene {

	override func keyUp(with event: NSEvent) {
		input.handleKeyUp(event: event)
	}

	override func keyDown(with event: NSEvent) {
		input.handleKeyDown(event: event)
	}
}
#endif

