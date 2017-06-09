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
		case loop(range: ClosedRange<Int>?)
	}
	
	fileprivate let engine = AVAudioEngine()
	fileprivate let node = AVAudioPlayerNode()
	
	fileprivate let preBuffer: AVAudioPCMBuffer?
	fileprivate let mainBuffer: AVAudioPCMBuffer
	
	let playMode: PlayMode
	
	public init(url: URL, playMode: PlayMode = .once) throws {
		
		let file = try AVAudioFile(forReading: url)
		self.playMode = playMode
		
		self.engine.attach(self.node)
		let buffer: AVAudioPCMBuffer
		
		enum Error: Swift.Error {
			case failedToCreatePCMBuffer(url: URL)
		}
		
		switch playMode {
		case .once:
			let frameCount = AVAudioFrameCount(file.length)
			guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
			                                       frameCapacity: frameCount) else {
				throw Error.failedToCreatePCMBuffer(url: url)
			}
			buffer = pcmBuffer
			try file.read(into: buffer, frameCount: frameCount)
			self.preBuffer = nil
			self.mainBuffer = buffer
			
		case .loop(range: let range):
			let loopFrameStart: AVAudioFramePosition
			let loopFrameEnd: AVAudioFramePosition
			
			if let loopRange = range {
				let preRange = 0 ..< loopRange.lowerBound
				let preFrameCount = AVAudioFrameCount(preRange.upperBound)
				guard let preBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
				                                       frameCapacity: preFrameCount) else {
					throw Error.failedToCreatePCMBuffer(url: url)
				}
				try file.read(into: preBuffer, frameCount: preFrameCount)
				loopFrameStart = AVAudioFramePosition(loopRange.lowerBound)
				loopFrameEnd = AVAudioFramePosition(loopRange.upperBound)
				self.preBuffer = preBuffer
				
			} else {
				loopFrameStart = 0
				loopFrameEnd = file.length
				self.preBuffer = nil
			}
			
			let loopFrameCount = AVAudioFrameCount(loopFrameEnd - loopFrameStart)
			guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
			                                       frameCapacity: loopFrameCount) else {
				throw Error.failedToCreatePCMBuffer(url: url)
			}
			buffer = pcmBuffer
			try file.read(into: buffer, frameCount: loopFrameCount)
			self.mainBuffer = buffer
		}
		
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
		
		switch self.playMode {
		case .once:
			self.node.scheduleBuffer(self.mainBuffer, at: nil, options: .interrupts, completionHandler: nil)
			
		case .loop:
			if let preBuffer = self.preBuffer {
				self.node.scheduleBuffer(preBuffer, at: nil, options: .interrupts, completionHandler: nil)
			}
			self.node.scheduleBuffer(self.mainBuffer, at: nil, options: .loops, completionHandler: nil)
		}
		
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
