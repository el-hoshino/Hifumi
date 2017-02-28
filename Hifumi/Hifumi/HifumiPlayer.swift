//
//  HifumiPlayer.swift
//  Hifumi
//
//  Created by 史　翔新 on 2017/02/28.
//  Copyright © 2017年 Crazism. All rights reserved.
//

import AVFoundation

public class HifumiPlayer {
	
	fileprivate let engine = AVAudioEngine()
	fileprivate let node = AVAudioPlayerNode()
	
	fileprivate let preBuffer: AVAudioPCMBuffer?
	fileprivate let mainBuffer: AVAudioPCMBuffer
	
	public init(url: URL, loopRange: ClosedRange<Int>? = nil) throws {
		
		let file = try AVAudioFile(forReading: url)
		
		self.engine.attach(self.node)
		
		if let loopRange = loopRange {
			let preRange = 0 ..< loopRange.lowerBound
			let preFrameCount = AVAudioFrameCount(preRange.upperBound)
			let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: preFrameCount)
			try file.read(into: buffer, frameCount: preFrameCount)
			self.node.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
			self.preBuffer = buffer
			file.framePosition = AVAudioFramePosition(preFrameCount)
			
		} else {
			self.preBuffer = nil
		}
		
		let mainFrameStart = file.framePosition
		let mainFrameCount = AVAudioFrameCount(file.length - mainFrameStart)
		let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: mainFrameCount)
		try file.read(into: buffer, frameCount: mainFrameCount)
		self.node.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
		self.mainBuffer = buffer
		
		self.engine.connect(self.node, to: engine.mainMixerNode, format: buffer.format)
		
	}
	
}

extension HifumiPlayer {
	
	public func play() throws {
		
		if !self.engine.isRunning {
			try self.engine.start()
		}
		
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
