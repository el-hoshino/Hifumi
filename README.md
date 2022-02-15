# Hifumi
A loop-point loop-able audio player class for iOS

## Usage

```swift
import Hifumi
```

```swift
let url = Bundle.main.url(forResource: <#filename#>, withExtension: <#extension#>)!
let player = try! HifumiPlayer(url: url, playMode: .loop(range: <#loopStartingPoint#>...))
player.play()

```

## Installation

Use SwiftPM to install Hifumi

```swift
dependencies: [
    .package(url: "https://github.com/el-hoshino/Hifumi", from: "1.0.2"),
]
```
