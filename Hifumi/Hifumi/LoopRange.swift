//
//  LoopRange.swift
//  Hifumi
//
//  Created by 史翔新 on 2017/11/29.
//  Copyright © 2017年 Crazism. All rights reserved.
//

import AVFoundation

extension HifumiPlayer {
	
	public enum LoopRange: RangeExpression {
		
		public typealias Bound = AVAudioFramePosition
		
		case all
		case from(start: Bound)
		case through(last: Bound)
		case upTo(end: Bound)
		case within(start: Bound, end: Bound)
		
	}
	
}

extension HifumiPlayer.LoopRange {
	
	public func contains(_ element: AVAudioFramePosition) -> Bool {
		
		switch self {
		case .all:
			return true
			
		case .from(start: let start):
			return element >= start
			
		case .through(last: let last):
			return element <= last
			
		case .upTo(end: let end):
			return element < end
			
		case .within(start: let start, end: let end):
			return (start ..< end).contains(element)
		}
		
	}
	
	public func relative<C>(to collection: C) -> Range<AVAudioFramePosition> where C : _Indexable, HifumiPlayer.LoopRange.Bound == C.Index {
		
		switch self {
		case .all:
			return collection.startIndex ..< collection.endIndex
			
		case .from(start: let start):
			return max(start, collection.startIndex) ..< collection.endIndex
			
		case .through(last: let last):
			return collection.startIndex ..< min(last.advanced(by: 1), collection.endIndex)
			
		case .upTo(end: let end):
			return collection.startIndex ..< min(end, collection.endIndex)
			
		case .within(start: let start, end: let end):
			return max(start, collection.startIndex) ..< min(end, collection.endIndex)
		}
		
	}
	
}

extension HifumiPlayer.LoopRange {
	
	func range(in file: AVAudioFile) -> Range<AVAudioFramePosition> {
		
		let fileLengthRange: CountableRange<AVAudioFramePosition> = 0 ..< file.length
		
		return self.relative(to: fileLengthRange)
		
	}
	
}

public func ..< (lhs: AVAudioFramePosition, rhs: AVAudioFramePosition) -> HifumiPlayer.LoopRange {
	return .within(start: lhs, end: rhs)
}

public func ... (lhs: AVAudioFramePosition, rhs: AVAudioFramePosition) -> HifumiPlayer.LoopRange {
	return .within(start: lhs, end: rhs.advanced(by: 1))
}

public prefix func ..< (rhs: AVAudioFramePosition) -> HifumiPlayer.LoopRange {
	return .upTo(end: rhs)
}

public prefix func ... (rhs: AVAudioFramePosition) -> HifumiPlayer.LoopRange {
	return .through(last: rhs)
}

public postfix func ... (lhs: AVAudioFramePosition) -> HifumiPlayer.LoopRange {
	return .from(start: lhs)
}
