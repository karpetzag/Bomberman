//
//  TextureSource.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class TextureSource {

	fileprivate static let atlas = SKTextureAtlas(named: "sprites")

	enum Tiles {

		static let wall = TextureSource.atlas.textureNamed("wall")

		static let block = TextureSource.atlas.textureNamed("block")

	}

	enum Block {

		static let destruction = ["block_destroy_1",
								  "block_destroy_2",
								  "block_destroy_3",
								  "block_destroy_4",
								  "block_destroy_5"].asTextures
	}

	enum Player {

		static let walkingUp = ["player_up_1", "player_up_2", "player_up_3"].asTextures
		static let walkingDown = ["player_down_1", "player_down_2", "player_down_3"].asTextures
		static let walkingLeft = ["player_left_1", "player_left_2", "player_left_3"].asTextures
		static let walkingRight = ["player_right_1", "player_right_2", "player_right_3"].asTextures

		static let death = ["player_death_1",
							"player_death_2",
							"player_death_3",
							"player_death_4",
							"player_death_5",
							"player_death_6",
							"player_death_7"].asTextures
	}

	enum Bomb {

		static let ticking = ["bomb_1", "bomb_2", "bomb_3"].map { TextureSource.atlas.textureNamed($0)}
		static let flameLeft = ["expl_middle_1", "bomb_2", "bomb_3"].map { TextureSource.atlas.textureNamed($0)}
		static let explosionCenter = ["expl_center_1",
									  "expl_center_2",
									  "expl_center_3",
									  "expl_center_4"].asTextures

	}

	enum Explosion {
		static let explosionMiddle = ["expl_middle_1", "expl_middle_2", "expl_middle_3", "expl_middle_4"].asTextures
		static let explosionEnd = ["expl_end_1", "expl_end_2", "expl_end_3", "expl_end_4"].asTextures
	}

	enum Enemy {
		static let balloomRight = ["balloom_right_1", "balloom_right_2", "balloom_right_3"].asTextures
		static let dallRight = ["dall_right_1", "dall_right_2", "dall_right_3"].asTextures
		static let onealRight = ["oneal_right_1", "oneal_right_2", "oneal_right_3"].asTextures
		static let ovapiRight = ["ovapi_right_1", "ovapi_right_2", "ovapi_right_3"].asTextures
		static let kondoriaRight = ["kondoria_right_1", "kondoria_right_2", "kondoria_right_3"].asTextures
		static let passRight = ["pass_right_1", "pass_right_2", "pass_right_3"].asTextures
		static let minvoRight = ["minvo_right_1", "minvo_right_2", "minvo_right_3"].asTextures
		static let pontanRight = ["pontan_right_1", "pontan_right_2", "pontan_right_3", "pontan_right_4"].asTextures

		static let balloomDeath = TextureSource.atlas.textureNamed("balloom_death")
		static let dallDeath = TextureSource.atlas.textureNamed("dall_death")
		static let ovapiDeath = TextureSource.atlas.textureNamed("ovapi_death")
		static let onealDeath = TextureSource.atlas.textureNamed("oneal_death")
		static let minvoDeath = TextureSource.atlas.textureNamed("minvo_death")
		static let pontanDeath = TextureSource.atlas.textureNamed("pontan_death")
		static let kondoriaDeath = TextureSource.atlas.textureNamed("kondoria_death")
		static let passDeath = TextureSource.atlas.textureNamed("pass_death")

		static let pinkDeathFade = ["death_pink_1", "death_pink_2", "death_pink_3", "death_pink_4"].asTextures
		static let blueDeathFade = ["death_blue_1", "death_blue_2", "death_blue_3", "death_blue_4"].asTextures
		static let purpleDeathFade = ["death_purple_1", "death_purple_2", "death_purple_3", "death_purple_4"].asTextures
	}

	enum Misc {
		static let exit = TextureSource.atlas.textureNamed("exit")
	}

	enum PowerUp {
		static let speed = TextureSource.atlas.textureNamed("p-up-speed")
		static let bomb = TextureSource.atlas.textureNamed("p-up-bomb")
		static let bombpass = TextureSource.atlas.textureNamed("p-up-bombpass")
		static let detonator = TextureSource.atlas.textureNamed("p-up-detonator")
		static let flames = TextureSource.atlas.textureNamed("p-up-flame")
		static let flamepass = TextureSource.atlas.textureNamed("p-up-flamepass")
		static let blockpass = TextureSource.atlas.textureNamed("p-up-wallpass")
		static let immortal = TextureSource.atlas.textureNamed("p-up-immortal")
	}
}

extension Array where Element == String {

	var asTextures: [SKTexture] {
		self.map { TextureSource.atlas.textureNamed($0)}
	}
}
