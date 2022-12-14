//
//  SoundPlayer.swift
//  BM
//
//  Created by Карпец Андрей on 23.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import SpriteKit
import AVFoundation

class AudioPlayer {

	var isFxMuted = false

	var isMusicMuted = false

	static let shared = AudioPlayer()

	private var musicPlayer: AVAudioPlayer?

	private var playersByFxName = [String: AVAudioPlayer]()

	private var extraPlayersByFxName = [String: AVAudioPlayer]()

	private var fxLoopPlayersByName = [String: AVAudioPlayer]()

	func playFx(name: String) {
		guard !isFxMuted else {
			return
		}

		if let player = playersByFxName[name] {
			if player.isPlaying {
				playWithExtraPlayer(name: name, attempt: 0)
			} else {
				player.play()
			}
			return
		}

		guard let path = Bundle.main.url(forResource: name, withExtension: nil) else {
			assertionFailure("Invalid filename \(name)")
			return
		}

		if let avPlayer = try? AVAudioPlayer(contentsOf: path) {
			avPlayer.play()
			playersByFxName[name] = avPlayer
		}
	}

	func playLoopFx(name: String) {
		guard !isFxMuted else {
			return
		}

		if let player = fxLoopPlayersByName[name] {
			if player.isPlaying {
				return
			} else {
				player.play()
			}
			return
		}

		guard let path = Bundle.main.url(forResource: name, withExtension: nil) else {
			assertionFailure("Invalid filename \(name)")
			return
		}

		if let avPlayer = try? AVAudioPlayer(contentsOf: path) {
			avPlayer.numberOfLoops = -1
			avPlayer.play()
			fxLoopPlayersByName[name] = avPlayer
		}
	}

	func stopLoopFx(name: String) {
		let player = fxLoopPlayersByName[name]
		player?.stop()
	}

	func playMusic(name: String) {
		guard !isMusicMuted else {
			return
		}
		stopMusic()
		guard let path = Bundle.main.url(forResource: name, withExtension: nil) else {
			assertionFailure("Invalid filename \(name)")
			return
		}
		let avPlayer = try? AVAudioPlayer(contentsOf: path)
		avPlayer?.numberOfLoops = -1
		avPlayer?.play()
		musicPlayer = avPlayer
	}

	func stopMusic() {
		musicPlayer?.stop()
	}

	private func playWithExtraPlayer(name: String, attempt: Int) {
		let maxAttempt = 10
		guard attempt < maxAttempt else {
			return
		}

		let key = name + "\(attempt)"
		if let player = extraPlayersByFxName[key] {
			if player.isPlaying {
				playWithExtraPlayer(name: name, attempt: attempt + 1)
			} else {
				player.play()
			}
			return
		}

		guard let path = Bundle.main.url(forResource: name, withExtension: nil) else {
			assertionFailure("Invalid filename \(name)")
			return
		}

		if let avPlayer = try? AVAudioPlayer(contentsOf: path) {
			avPlayer.play()
			extraPlayersByFxName[key] = avPlayer
		}
	}
}
