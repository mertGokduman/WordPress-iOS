import UITestsFoundation
import XCTest

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        clearText()
        self.tap()
        self.typeText(text)
    }
}

extension XCTestCase {

    public func setUpTestSuite() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-wpcom-api-base-url", WireMock.URL().absoluteString, "-no-animations", "-ui-testing"]
        app.activate()

        // Media permissions alert handler
        let alertButtonTitle: String
        if #available(iOS 14.0, *) {
            alertButtonTitle = "Allow Access to All Photos"
        } else {
            alertButtonTitle = "OK"
        }
        systemAlertHandler(alertTitle: "“WordPress” Would Like to Access Your Photos", alertButton: alertButtonTitle)
    }

    public func takeScreenshotOfFailedTest() {
        if let failureCount = testRun?.failureCount, failureCount > 0 {
            XCTContext.runActivity(named: "Take a screenshot at the end of a failed test") { (activity) in
                add(XCTAttachment(screenshot: XCUIApplication().windows.firstMatch.screenshot()))
            }
        }
    }

    public func systemAlertHandler(alertTitle: String, alertButton: String) {
        addUIInterruptionMonitor(withDescription: alertTitle) { (alert) -> Bool in
            let alertButtonElement = alert.buttons[alertButton]
            XCTAssert(alertButtonElement.waitForExistence(timeout: 5))
            alertButtonElement.tap()
            return true
        }
    }

    public func waitForElementToNotExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        let notExistsPredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                    object: element)

        let timeoutValue = timeout ?? 30
        guard XCTWaiter().wait(for: [expectation], timeout: timeoutValue) == .completed else {
            XCTFail("\(element) still exists after \(timeoutValue) seconds.")
            return
        }
    }

    public func getRandomPhrase() -> String {
        var wordArray: [String] = []
        let phraseLength = Int.random(in: 3...6)
        for _ in 1...phraseLength {
            wordArray.append(DataHelper.words.randomElement()!)
        }
        let phrase = wordArray.joined(separator: " ")

        return phrase
    }

    public func getRandomContent() -> String {
        var sentenceArray: [String] = []
        let paraLength = Int.random(in: 1...DataHelper.sentences.count)
        for _ in 1...paraLength {
            sentenceArray.append(DataHelper.sentences.randomElement()!)
        }
        let paragraph = sentenceArray.joined(separator: " ")

        return paragraph
    }

    public func getCategory() -> String {
        return "Wedding"
    }

    public func getTag() -> String {
        return "tag \(Date().toString())"
    }

    public struct DataHelper {
        static let words = ["Lorem", "Ipsum", "Dolor", "Sit", "Amet", "Consectetur", "Adipiscing", "Elit"]
        static let sentences = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "Nam ornare accumsan ante, sollicitudin bibendum erat bibendum nec.", "Nam congue efficitur leo eget porta.", "Proin dictum non ligula aliquam varius.", "Aenean vehicula nunc in sapien rutrum, nec vehicula enim iaculis."]
        static let category = "iOS Test"
        static let tag = "tag \(Date().toString())"
    }
}
