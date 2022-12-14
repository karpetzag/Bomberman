//
//  PlayerSkills.swift
//  BM
//
//  Created by Andrey Karpets on 25.11.2022.
//  Copyright © 2022 AK. All rights reserved.
//

import Foundation

class PlayerSkills {

	enum Speed {
		case normal, fast

		var value: CGFloat {
			switch self {
			case .fast: return 125
			case .normal: return 100
			}
		}
	}

	var speed = Speed.fast
	var hasDetonator = true
	var immuneToFlame = true
	var canWalkThroughBombs = false
	var canWalkThroughBlocks = true
	var numberOfBombs = 12
	var explosionRadius = 12
	var immuneToEnemies = false

	func makeCopyForBonusLevel() -> PlayerSkills {
		let skills = PlayerSkills()
		skills.speed = speed
		skills.canWalkThroughBlocks = canWalkThroughBlocks
		skills.canWalkThroughBombs = canWalkThroughBombs
		skills.immuneToFlame = true
		skills.numberOfBombs = numberOfBombs
		skills.explosionRadius = explosionRadius
		skills.hasDetonator = hasDetonator
		skills.immuneToEnemies = true
		return skills
	}
}
