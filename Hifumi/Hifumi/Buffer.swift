//
//  Buffer.swift
//  Hifumi
//
//  Created by 史翔新 on 2017/11/29.
//  Copyright © 2017年 Crazism. All rights reserved.
//

import AVFoundation

extension HifumiPlayer {
	
	enum Buffer {
		case once(main: AVAudioPCMBuffer)
		case loopWithIntro(intro: AVAudioPCMBuffer, main: AVAudioPCMBuffer)
		case loopWithoutIntro(main: AVAudioPCMBuffer)
	}
	
}

extension HifumiPlayer.Buffer {
	
	init(file: AVAudioFile, playMode: HifumiPlayer.PlayMode) throws {
		
		switch playMode {
		case .once:
			let mainBuffer = try AVAudioPCMBuffer.makeWholeBuffer(from: file)
			self = .once(main: mainBuffer)
			
		case .loop(range: let range):
			let loopStartPosition = range.range(in: file).lowerBound
			switch loopStartPosition {
			case 0:
				let loopBuffer = try AVAudioPCMBuffer.makeWholeBuffer(from: file)
				self = .loopWithoutIntro(main: loopBuffer)
				
			default:
				let buffers = try AVAudioPCMBuffer.makeSeperatedBuffers(from: file, introFrameEndPosition: loopStartPosition)
				self = .loopWithIntro(intro: buffers.introBuffer, main: buffers.mainBuffer)
			}
		}
		
	}
	
}

extension HifumiPlayer.Buffer {
	
	var mainBuffer: AVAudioPCMBuffer {
		switch self {
		case .once(main: let buffer):
			return buffer
			
		case .loopWithIntro(intro: _, main: let buffer):
			return buffer
			
		case .loopWithoutIntro(main: let buffer):
			return buffer
		}
	}
	
	var format: AVAudioFormat {
		return self.mainBuffer.format
	}
	
}

extension AVAudioPlayerNode {
	
	func scheduleBuffer(_ buffer: HifumiPlayer.Buffer) {
		
		switch buffer {
		case .once(main: let main):
			self.scheduleBuffer(main, at: nil, options: .interrupts, completionHandler: nil)
			
		case .loopWithIntro(intro: let intro, main: let main):
			self.scheduleBuffer(intro, at: nil, options: .interrupts, completionHandler: nil)
			self.scheduleBuffer(main, at: nil, options: .loops, completionHandler: nil)
			
		case .loopWithoutIntro(main: let main):
			self.scheduleBuffer(main, at: nil, options: .loops, completionHandler: nil)
		}
		
	}
	
}

private extension AVAudioPCMBuffer {
	
	enum Error: Swift.Error {
		case failedToCreateAVAudioPCMBufferFromFile(AVAudioFile)
	}
	
	static func makeWholeBuffer(from file: AVAudioFile) throws -> AVAudioPCMBuffer {
		
		let frameCount = AVAudioFrameCount(file.length)
		
		guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
			throw Error.failedToCreateAVAudioPCMBufferFromFile(file)
		}
		
		try file.read(into: buffer, frameCount: frameCount)
		
		return buffer
		
	}
	
	static func makeSeperatedBuffers(from file: AVAudioFile, introFrameEndPosition: AVAudioFramePosition) throws -> (introBuffer: AVAudioPCMBuffer, mainBuffer: AVAudioPCMBuffer) {
		
		let introFrameCount = AVAudioFrameCount(introFrameEndPosition)
		guard let introBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: introFrameCount) else {
			throw Error.failedToCreateAVAudioPCMBufferFromFile(file)
		}
		
		let mainFrameCount = AVAudioFrameCount(file.length) - introFrameCount
		guard let mainBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: mainFrameCount) else {
			throw Error.failedToCreateAVAudioPCMBufferFromFile(file)
		}
		
		try file.read(into: introBuffer, frameCount: introFrameCount)
		try file.read(into: mainBuffer, frameCount: mainFrameCount)
		
		return (introBuffer, mainBuffer)
		
	}
	
}
