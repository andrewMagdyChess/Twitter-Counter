//
//  TwitterCounterViewModel.swift
//  
//
//  Created by Andrew Roushdy on 22/10/2022.
//

import Foundation
import TwitterAPIKit
import AuthenticationServices

class TwitterCounterViewModel {
    // MARK: - properties
    let tweetCalculator: TweetLenghtCalculator
    let charactersLimit = 280
    private(set) var charactersCount: Int = 0
    private(set) var remainigCharacters: Int = 280
    private var tweetText: String = ""
    
    // MARK: - Binding
    var onTextChange: ((_ charactersCount: String, _ remainigCharacters: String) -> Void)?
    var onSession: ((_ session: ASWebAuthenticationSession) -> Void)?
    var onError: ((_ error: String) -> Void)?
    var onSuccess: ((_ success: String) -> Void)?
    
    // MARK: - Setup Env and client
    private var env: Env {
        get {
            if let env = Env.restore() {
                return env
            }
            return Env(
                consumerKey: "hZWbvgbLG7d0wXe935mFWsL4G",
                consumerSecret: "cULLP6wkK1FYScT1q6QDFIJxPX4qMkA5N2VY6p7yqMHKleIFcQ",
                oauthToken: nil,
                oauthTokenSecret: nil,
                clientID: "",
                clientSecret: ""
            )
        }
        set {
            newValue.store()
        }
    }
    
    private lazy var client: TwitterAPIClient = {
        guard let consumerKey = env.consumerKey, let consumerSecret = env.consumerSecret else { fatalError() }
        let client = TwitterAPIClient(.oauth10a(.init(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: env.oauthToken, oauthTokenSecret: env.oauthTokenSecret)))
        return client
    }()
    
    // MARK: - Init
    init(tweetCalculator: TweetLenghtCalculator) {
        self.tweetCalculator = tweetCalculator
    }
    
    func inputDidChanged(text: String) {
        let tweetLenght = tweetCalculator.getLength(text: text)
        if tweetLenght <= charactersLimit {
            let count = charactersLimit - tweetLenght
            charactersCount = tweetLenght
            remainigCharacters = count
        }
        onTextChange?("\(charactersCount)/\(charactersLimit)", "\(remainigCharacters)")
        self.tweetText = text
    }
    
    // MARK: - validate send Tweet
    func validateTweet() {
        // 1. POST oauth/request_token (postOAuthRequestToken)
        // 2. GET oauth/authorize (makeOAuthAuthorizeURL & ASWebAuthenticationSession & parse callback url)
        // 3. POST oauth/access_token (postOAuthAccessToken)
        client.auth.oauth10a.postOAuthRequestToken(.init(oauthCallback: "alamoTwitter://")) // Rewrite your oauth callback url or scheme
            .responseObject { [weak self] response in
                guard let self = self else { return }
                do {
                    let success = try response.result.get()
                    let url = self.client.auth.oauth10a.makeOAuthAuthorizeURL(.init(oauthToken: success.oauthToken))!
                    
                    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "alamoTwitter") { url, error in
                        guard let url = url else {
                            if let error = error {
                                self.onError?(error.localizedDescription)
                            }
                            return
                        }
                        print("URL:", url)
                        
                        let component = URLComponents(url: url, resolvingAgainstBaseURL: false)
                        guard let oauthToken = component?.queryItems?.first(where: { $0.name == "oauth_token"} )?.value,
                              let oauthVerifier = component?.queryItems?.first(where: { $0.name == "oauth_verifier"})?.value else {
                            print("Invalid URL")
                            return
                        }
                        self.client.auth.oauth10a.postOAuthAccessToken(.init(oauthToken: oauthToken, oauthVerifier: oauthVerifier))
                            .responseObject { response in
                                do {
                                    let token = try response.result.get()
                                    let oauthToken = token.oauthToken
                                    let oauthTokenSecret = token.oauthTokenSecret
                                    
                                    self.env.oauthToken = oauthToken
                                    self.env.oauthTokenSecret = oauthTokenSecret
                                    self.env.store()
                                    self.postTweet()
                                } catch {
                                    self.onError?(error.localizedDescription)
                                }
                            }
                    }
                    self.onSession?(session)
                } catch {
                    self.onError?(error.localizedDescription)
                }
            }
        
    }
    
    private func postTweet() {
        self.client.v2.tweet.postTweet(PostTweetsRequestV2(text: self.tweetText))
            .responseObject { response in
                do {
                    self.onSuccess?("Success")
                    self.inputDidChanged(text: "")
                } catch {
                    self.onError?(error.localizedDescription)
                }
            }
    }
    
}
