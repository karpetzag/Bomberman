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
	static let bonusGameDuration: TimeInterval = 5
	static let numberOfLevels = 50
	static let numberOfLevelsBeforeBonusGame = 5

	static let tileSize = CGSize(width: 32, height: 32)
}
