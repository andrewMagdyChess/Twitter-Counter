# Twitter-Counter
iOS UI Component for posting tweets

![](https://img.shields.io/badge/Platform-iOS-orange)
<img src="https://img.shields.io/badge/minimum%20iOS%20version-10-red">
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/andrewMagdyChess/Twitter-Counter)

<img src="Sources/Twitter-Counter/Resources/MicrosoftTeams-image%20(4).png" width="300"> 

## Installation
### Swift Package Manager
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
To integrate using Apple's Swift package manager from xcode :

File -> Swift Packages -> Add Package Dependency... 

enter package URL: ```https://https://github.com/andrewMagdyChess/Twitter-Counter``` , choose the latest release

## Usage
#### 1. conform to ```TweetLenghtCalculator```
we recommend to use [twitter text](https://github.com/nysander/twitter-text) package
```swift
extenstion X: TweetLenghtCalculator {
  func getLength(text: String) -> Int {
      Parser.defaultParser.parseTweet(text: text).weightedLength
  }
}
```
#### 2. create an instance of ```TwitterCounterViewController```
```swift
let postTweetVC = TwitterCounterViewController(tweetCalculator: X)
```
#### 3. present or push
```swift
show(postTweetVC)
```

#### you can check our [example app](Sources/twitterCounter) as a reference
