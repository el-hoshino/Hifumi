//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import Hifumi

PlaygroundPage.current.needsIndefiniteExecution = true

let url = Bundle.main.url(forResource: "5370", withExtension: "mp3")!
let player = try! HifumiPlayer(url: url, playMode: .loop(range: 2205 ... 352800))
player.play()
