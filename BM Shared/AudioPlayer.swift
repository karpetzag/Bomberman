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

	static let shared = AudioPlayer()

	var isFxMuted = false

	var isMusicMuted = false

	private let engine = AVAudioEngine()

	private var backgroundMusicNode = AVAudioPlayerNode()

	private var nodes = [AVAudioPlayerNode]()
	private var currentNodeIndex = 0

	private var loopNodesPerSoundname = [String: AVAudioPlayerNode]()

	private let mixerNode = AVAudioMixerNode()

	private var bufferPerSoundname = [String: AVAudioPCMBuffer]()

	init() {
		self.engine.attach(self.mixerNode)
		self.engine.connect(self.mixerNode, to: self.engine.outputNode, format: nil)
		self.engine.attach(self.backgroundMusicNode)
		self.engine.connect(self.backgroundMusicNode, to: self.mixerNode, format: nil)

		try? engine.start()

		let maxNodes = 15
		self.nodes = self.makeNodes(count: maxNodes)
	}

	func preloadSounds(names: [String]) {
		names.forEach { self.loadSound(name: $0) }
	}

	func playFx(name: String) {
		guard !self.isFxMuted else {
			return
		}

		guard let buffer = self.bufferPerSoundname[name] ?? self.loadSound(name: name) else {
			return
		}

		self.currentNodeIndex = (self.currentNodeIndex + 1) % self.nodes.count
		let node = self.nodes[currentNodeIndex]

		node.scheduleBuffer(buffer, at: nil)
	}

	func playLoopFx(name: String) {
		guard !isFxMuted else {
			return
		}

		guard let buffer = self.bufferPerSoundname[name] ?? self.loadSound(name: name) else {
			return
		}

		var node = self.loopNodesPerSoundname[name]
		if node == nil {
			let newNode = self.makeNode()
			self.loopNodesPerSoundname[name] = newNode
			node = newNode
		}

		node?.scheduleBuffer(buffer, at: nil, options: .loops)
		node?.play()
	}

	func stopLoopFx(name: String) {
		self.loopNodesPerSoundname[name]?.stop()
	}

	func playMusic(name: String) {
		guard !self.isMusicMuted else {
			return
		}

		self.stopMusic()

		guard let audioFileBuffer = self.bufferPerSoundname[name] ?? self.loadSound(name: name) else {
			return
		}

		self.backgroundMusicNode.scheduleBuffer(audioFileBuffer, at: nil, options: .loops)
		self.backgroundMusicNode.play()
	}

	func stopMusic() {
		self.backgroundMusicNode.stop()
	}

	private func makeNodes(count: Int) -> [AVAudioPlayerNode] {
		var nodes = [AVAudioPlayerNode]()
		for _ in 0..<count {
			nodes.append(self.makeNode())
		}

		return nodes
	}

	private func makeNode() -> AVAudioPlayerNode {
		let playerNode = AVAudioPlayerNode()
		self.engine.attach(playerNode)
		self.engine.connect(playerNode, to: self.mixerNode, format: nil)
		playerNode.play()
		return playerNode
	}

	@discardableResult
	private func loadSound(name: String) -> AVAudioPCMBuffer? {
		guard let path = Bundle.main.url(forResource: name, withExtension: nil) else {
			assertionFailure("Invalid filename \(name)")
			return nil
		}

		guard let file = try? AVAudioFile(forReading: path) else {
			return nil
		}

		guard let audioFileBuffer = AVAudioPCMBuffer(
			pcmFormat: file.processingFormat,
			frameCapacity: AVAudioFrameCount(file.length)
		) else {
			return nil
		}

		try? file.read(into: audioFileBuffer)
		self.bufferPerSoundname[name] = audioFileBuffer

		return audioFileBuffer
	}
}
