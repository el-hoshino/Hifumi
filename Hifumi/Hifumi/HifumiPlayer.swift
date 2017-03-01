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
	
	fileprivate let file: AVAudioFile
	fileprivate let playMode: PlayMode
	
	public init(url: URL, playMode: PlayMode = .once) throws {
		
		let file = try AVAudioFile(forReading: url)
		self.file = file
		self.playMode = playMode
		
		self.engine.attach(self.node)
		let buffer: AVAudioPCMBuffer
		
		switch playMode {
		case .once:
			let frameCount = AVAudioFrameCount(file.length)
			buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount)
			try file.read(into: buffer, frameCount: frameCount)
			self.node.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
			
		case .loop(range: let range):
			let loopFrameStart: AVAudioFramePosition
			let loopFrameEnd: AVAudioFramePosition
			
			if let loopRange = range {
				let preRange = 0 ..< loopRange.lowerBound
				let preFrameCount = AVAudioFrameCount(preRange.upperBound)
				let preBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: preFrameCount)
				try file.read(into: preBuffer, frameCount: preFrameCount)
				self.node.scheduleBuffer(preBuffer, at: nil, options: .interrupts, completionHandler: nil)
				loopFrameStart = AVAudioFramePosition(loopRange.lowerBound)
				loopFrameEnd = AVAudioFramePosition(loopRange.upperBound)
				
			} else {
				loopFrameStart = 0
				loopFrameEnd = file.length
			}
			
			let loopFrameCount = AVAudioFrameCount(loopFrameEnd - loopFrameStart)
			buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: loopFrameCount)
			try file.read(into: buffer, frameCount: loopFrameCount)
			self.node.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
		}
		
		self.engine.connect(self.node, to: self.engine.mainMixerNode, format: buffer.format)
		
		try self.engine.start()
		
	}
	
}

extension HifumiPlayer {
	
	public func play() {
		
		if !self.node.isPlaying {
			self.node.play()
		}
		
	}
	
	public func pause() {
		self.node.pause()
	}
	
	public func stop() {
		self.node.stop()
	}
	
}
