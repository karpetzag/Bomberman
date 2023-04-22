//
//  SoundType.swift
//  BM
//
//  Created by Andrey Karpets on 24.11.2022.
//  Copyright © 2022 AK. All rights reserved.
//

import Foundation

enum SoundName: String, CaseIterable {

	case stageComplete = "stage_complete.mp3"
	case lifeLost = "life_lost.m4a"
	case stageStart = "stage_start.m4a"
	case allEnemiesDead = "all_enemies_dead.wav"
	case powerup = "powerup.wav"
	case musicAfterPowerup = "music_after_powerup.mp3"
	case stageTheme = "stage_theme.mp3"
	case titleScreen = "title_screen.mp3"
	case ending = "ending.mp3"
	case placeBomb = "place_bomb.wav"
	case gameOver = "game_over.mp3"
	case bonusStage = "bonus_stage.mp3"
	case walkHorizontal = "walkHorizontal.wav"
	case walkVertical = "walkVertical.wav"
	case playerDeath = "player_death.wav"
	case explosion = "explosion.mp3"

}
