//
//  TwitterCounterViewController.swift
//  
//
//  Created by Andrew Roushdy on 20/10/2022.
//
import AuthenticationServices
import UIKit
import TwitterAPIKit

public protocol TweetLenghtCalculator {
    func getLength(text: String) -> Int
}

public class TwitterCounterViewController: UIViewController, UITextViewDelegate {
        
    // MARK: - Outlet
    @IBOutlet private weak var charactersTypedCountView: UIView!
    @IBOutlet private weak var charactersTypedCountLab: UILabel!
    @IBOutlet private weak var charactersRemainingcountView: UIView!
    @IBOutlet private weak var charactersRemainingcountLab: UILabel!
    @IBOutlet private weak var tweetTextView: UITextView!
    @IBOutlet private weak var postButton: UIButton!
    
    private let viewModel: TwitterCounterViewModel
    
    // MARK: - Init
    public init(tweetCalculator: TweetLenghtCalculator) {
        self.viewModel = .init(tweetCalculator: tweetCalculator)
        super.init(nibName: nil, bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupViewModel()
    }
    
    // MARK: - SetupTextView
    func setupTextView() {
        tweetTextView.delegate = self
        tweetTextView.placeholder = "Start typing! You can enter up to 280 characters"
    }
    // MARK: - SetupViewModel
    func setupViewModel() {
        viewModel.onTextChange = { [weak self] count, remaining in
            guard let self = self else { return }
            self.charactersTypedCountLab.text = count
            self.charactersRemainingcountLab.text = remaining
        }
        viewModel.onSession = { [weak self] session in
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            self.showAlert(title: "Error", message: error)
        }
        viewModel.onSuccess = { [weak self] success in
            guard let self = self else { return }
            self.showAlert(title: "Success", message: success)
            self.tweetTextView.text = ""
        }
    }

        
    // MARK: - UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        viewModel.inputDidChanged(text: textView.text)
        let isTextNotEmpty = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        postButton.isEnabled = isTextNotEmpty
        postButton.alpha = isTextNotEmpty ? 1 : 0.5
        if let placeholderLabel = tweetTextView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = tweetTextView.text.count > 0
            placeholderLabel.textAlignment = .left
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (tweetTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if numberOfChars > viewModel.charactersLimit {tweetTextView.shakeIt()}
        return numberOfChars <= viewModel.charactersLimit   // 280 Limit Value
    }
    
    // MARK: - Actions
    @IBAction func copyTextActionButton(_ sender: Any) {
        UIPasteboard.general.string = tweetTextView.text
    }
    
    @IBAction func clearTextActionButton(_ sender: Any) {
        tweetTextView.text = ""
        viewModel.inputDidChanged(text: "")
    }
    
    @IBAction func postTweetActionButton(_ sender: Any) {
        viewModel.validateTweet()
    }
}

extension TwitterCounterViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

