//
//  Exit.swift
//  BM
//
//  Created by Карпец Андрей on 09.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit

class StaticEntity: Entity {

	init(texture: SKTexture) {
		super.init()
		self.node.texture = texture
		self.node.size = texture.size()
	}

	static func exit() -> StaticEntity {
		return StaticEntity(texture: TextureSource.Misc.exit)
	}
}
