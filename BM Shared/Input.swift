//
//  PlayerInput.swift
//  BM
//
//  Created by Карпец Андрей on 17.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

#if !os(iOS)
import Cocoa
#endif

struct KeyState: OptionSet {
	let rawValue: Int32

	static let left = KeyState(rawValue: 1 << 0)
	static let right = KeyState(rawValue: 1 << 1)
	static let up = KeyState(rawValue: 1 << 2)
	static let down = KeyState(rawValue: 1 << 3)
	static let placeBomb = KeyState(rawValue: 1 << 4)
	static let useDetonator = KeyState(rawValue: 1 << 5)
	static let pause = KeyState(rawValue: 1 << 6)

	static let skipLevel = KeyState(rawValue: 1 << 7)
	static let destroyAllBlocks = KeyState(rawValue: 1 << 8)
	static let killAllEnemies = KeyState(rawValue: 1 << 9)
}

class Input {

	private var controlsState = KeyState()

	func isKeyPressed(key: KeyState) -> Bool {
		return self.controlsState.contains(key)
	}

	#if !os(iOS)
	func handleKeyUp(event: NSEvent) {
		switch event.keyCode {
		case 126:
			controlsState.remove(.up)
		case 124:
			controlsState.remove(.right)
		case 125:
			controlsState.remove(.down)
		case 123:
			controlsState.remove(.left)
		case 49:
			controlsState.remove(.placeBomb)
		case 3:
			controlsState.remove(.useDetonator)
		case 35:
			controlsState.remove(.pause)
		case 29:
			controlsState.remove(.skipLevel)
		case 25:
			controlsState.remove(.destroyAllBlocks)
		case 28:
			controlsState.remove(.killAllEnemies)
		default:
			print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
		}
	}

	func handleKeyDown(event: NSEvent) {
		switch event.keyCode {
		case 126:
			controlsState.insert(.up)
		case 124:
			controlsState.insert(.right)
		case 125:
			controlsState.insert(.down)
		case 123:
			controlsState.insert(.left)
		case 49:
			controlsState.insert(.placeBomb)
		case 3:
			controlsState.insert(.useDetonator)
		case 35:
			controlsState.insert(.pause)
		case 29:
			controlsState.insert(.skipLevel)
		case 25:
			controlsState.insert(.destroyAllBlocks)
		case 28:
			controlsState.insert(.killAllEnemies)
		default:
			print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
		}
	}
	#endif
}
