//
//  GameConfiguration.swift
//  BM
//
//  Created by Andrey Karpets on 10.12.2022.
//  Copyright © 2022 AK. All rights reserved.
//

import Foundation

enum GameConfiguration {

	static let levelWidth = 33
	static let levelHeight = 13

	static let gameDuration: TimeInterval = 200
	static let bonusGameDuration: TimeInterval = 15
	static let numberOfLevels = 50
	static let numberOfLevelsBeforeBonusLevel = 5
	static let numberOfBonusLevels = Self.numberOfLevels / Self.numberOfLevelsBeforeBonusLevel

	static let tileSize = CGSize(width: 32, height: 32)
	static let statsHeight = 32
}
