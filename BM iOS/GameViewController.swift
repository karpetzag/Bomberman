//
//  GameViewController.swift
//  BM iOS
//
//  Created by Карпец Андрей on 16.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

	private var sceneManager: SceneManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView
		sceneManager = SceneManager(rootView: skView)
		sceneManager?.presentScene(id: .menu)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard let view = self.view as? SKView else { return }
		let resize = view.frame.size.asepctFill( CGSize(width: view.frame.width, height: 450) )
		view.scene?.size = resize// UIScreen.main.bounds.size
	}
}

extension CGSize {
    func asepctFill(_ target: CGSize) -> CGSize {
        let baseAspect = self.width / self.height
        let targetAspect = target.width / target.height
        if baseAspect > targetAspect {
            return CGSize(width: (target.height * width) / height, height: target.height)
        } else {
            return CGSize(width: target.width, height: (target.width * height) / width)
        }
    }
}
