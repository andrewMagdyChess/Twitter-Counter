import XCTest
@testable import Twitter_Counter

final class Twitter_CounterTests: XCTestCase {
    
    var sut: TwitterCounterViewModel!
    let lengthCalculator = MockTweetLengthCalculator()
    
    override func setUp() {
        super.setUp()
        sut = TwitterCounterViewModel(tweetCalculator: lengthCalculator)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testViewModel_whenStartTyping_CountIsZero() {
        XCTAssertEqual(sut.charactersCount, 0)
    }
    
    func testViewModel_whenStartTyping_RemainingIs280() {
        XCTAssertEqual(sut.remainigCharacters, 280)
    }
    
    func testViewModel_whenTyped_CountIsEqualLenghtCalculator() {
        // given
        let text = "Hello World!"
        var charactersCount: String = ""
        
        // when
        sut.onTextChange = { count, _ in
            charactersCount = count
        }
        sut.inputDidChanged(text: text)
        
        // then
        XCTAssertEqual(sut.charactersCount, lengthCalculator.getLength(text: text))
        XCTAssertEqual(charactersCount, "\(lengthCalculator.getLength(text: text))/\(sut.charactersLimit)")
        
    }
    
    func testViewModel_whenTyped_RemainingIsEqualCharactersLimitMinusLenghtCalculator() {
        // given
        let text = "Hello World!"
        var remainingCharacters: String = ""
        
        // when
        sut.onTextChange = { _, remaining in
            remainingCharacters = remaining
        }
        sut.inputDidChanged(text: text)
        
        // then
        XCTAssertEqual(sut.remainigCharacters, sut.charactersLimit - lengthCalculator.getLength(text: text))
        XCTAssertEqual(remainingCharacters, "\(sut.charactersLimit - lengthCalculator.getLength(text: text))")
    }
    
    
    func testViewModel_whenClear_CountIsZero() {
        // given
        let text = "Hello World!"
        var charactersCount: String = ""
        
        // when
        sut.onTextChange = { count, _ in
            charactersCount = count
        }
        sut.inputDidChanged(text: text)
        sut.inputDidChanged(text: "")
        
        // then
        XCTAssertEqual(sut.charactersCount, 0)
        XCTAssertEqual(charactersCount, "0/\(sut.charactersLimit)")
    }
    
    func testViewModel_whenClear_RemainingIs280() {
        // given
        let text = "Hello World!"
        var remainingCharacters: String = ""
        
        // when
        sut.onTextChange = { _, remaining in
            remainingCharacters = remaining
        }
        sut.inputDidChanged(text: text)
        sut.inputDidChanged(text: "")
        
        // then
        XCTAssertEqual(sut.remainigCharacters, 280)
        XCTAssertEqual(remainingCharacters, "280")
    }
    
}

struct MockTweetLengthCalculator: TweetLenghtCalculator {
    func getLength(text: String) -> Int {
        text.count
    }
}
