//
//  HifumiPlayer.swift
//  Hifumi
//
//  Created by 史　翔新 on 2017/02/28.
//  Copyright © 2017年 Crazism. All rights reserved.
//

import AVFoundation

public class HifumiPlayer {
	
	public enum PlayMode {
		case once
		case loop(range: LoopRange)
	}
	
	fileprivate let engine = AVAudioEngine()
	fileprivate let node = AVAudioPlayerNode()
	
	fileprivate let buffer: Buffer
	
	let playMode: PlayMode
	
	public init(url: URL, playMode: PlayMode = .once) throws {
		
		let file = try AVAudioFile(forReading: url)
		self.playMode = playMode
		
		self.engine.attach(self.node)
		
		let buffer = try Buffer(file: file, playMode: playMode)
		self.buffer = buffer
		
		self.engine.connect(self.node, to: self.engine.mainMixerNode, format: buffer.format)
		
		try self.engine.start()
		
	}
	
}

extension HifumiPlayer {
	
	public var isPlaying: Bool {
		return self.node.isPlaying
	}
	
}

extension HifumiPlayer {
	
	public var volume: Float {
		get {
			return self.node.volume
		}
		set {
			self.node.volume = newValue
		}
	}
	
}

extension HifumiPlayer {
	
	fileprivate func prepareToPlay() {
		
		self.node.stop()
		
		self.node.scheduleBuffer(self.buffer)
		
	}
	
}

extension HifumiPlayer {
	
	private func validateEngineStatus() throws {
		
		if self.engine.isRunning {
			return
		}
		
		try engine.start()
		
	}
	
	public func play() {
		
		guard (try? self.validateEngineStatus()) != nil else { return }
		
		self.prepareToPlay()
		self.node.play()
		
	}
	
	public func pause() {
		self.node.pause()
	}
	
	public func stop() {
		self.node.stop()
	}
	
}
