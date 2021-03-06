import Quick
import Nimble
import UIKit
import Forgeries

@testable
import Artsy

class LiveAuctionLotBidHistoryGestureControllerTests: QuickSpec {
    override func spec() {
        var gestureRecognizer: ForgeryPanGestureRecognizer!
        var subject: LiveAuctionLotBidHistoryGestureController!
        var beginning: LiveAuctionLotBidHistoryGestureController.BeginClosure?
        var update: LiveAuctionLotBidHistoryGestureController.UpdateClosure?
        var completion: LiveAuctionLotBidHistoryGestureController.CompletionClosure?

        beforeEach {
            beginning = nil
            update = nil
            completion = nil
            gestureRecognizer = ForgeryPanGestureRecognizer()
            subject = LiveAuctionLotBidHistoryGestureController(gestureRecognizer: gestureRecognizer,
                begining: { originalState in
                    beginning?(originalState: originalState)
                }, update: { delta in
                    update?(delta: delta)
                }, completion: { targetState in
                    completion?(targetState: targetState)
            })
            subject.openedPosition = 10
            subject.closedPosition = 20
        }

        it("closes when it's forced closed") {

        }

        it("disables the gesture recognizer when disabled itself") {
            subject.enabled = false

            expect(gestureRecognizer.enabled) == false
        }

        it("enables the gesture recognizer when enabled itself") {
            subject.enabled = false

            subject.enabled = true

            expect(gestureRecognizer.enabled) == true
        }

        describe("opening") {
            it("calls beginning closure") {
                var receivedInitialState: BidHistoryState?
                beginning = { initialState in
                    receivedInitialState = initialState
                }
                gestureRecognizer.testing_state = .Began

                gestureRecognizer.invoke()

                expect(receivedInitialState) == .Closed
            }

            it("sets its state to open during the opening") {
                gestureRecognizer.testing_state = .Began

                gestureRecognizer.invoke()

                expect(subject.bidHistoryState == .Open) == true
            }

            it("updates with delta") {
                var receivedDelta: CGFloat?
                update = { delta in
                    receivedDelta = delta
                }
                gestureRecognizer.testing_translation = CGPoint(x: 0, y: -5)
                gestureRecognizer.testing_state = .Changed

                gestureRecognizer.invoke()

                expect(receivedDelta) == -5
            }

            it("calls ending closure to cancel") {
                var receivedTargetState: BidHistoryState?
                completion = { targetState in
                    receivedTargetState = targetState
                }
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: 5)
                gestureRecognizer.testing_state = .Ended

                gestureRecognizer.invoke()

                expect(receivedTargetState) == .Closed
            }

            it("calls ending closure to complete") {
                var receivedTargetState: BidHistoryState?
                completion = { targetState in
                    receivedTargetState = targetState
                }
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: -5)
                gestureRecognizer.testing_state = .Ended

                gestureRecognizer.invoke()

                expect(receivedTargetState) == .Open
            }

            it("updates its state once opened") {
                gestureRecognizer.state = .Began
                gestureRecognizer.invoke()

                gestureRecognizer.testing_state = .Ended
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: -5)
                gestureRecognizer.invoke()

                expect(subject.bidHistoryState == .Open) == true
            }
        }

        describe("closing") {
            beforeEach {
                // "Open" the controller.
                gestureRecognizer.testing_state = .Began
                gestureRecognizer.invoke()
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: -5)
                gestureRecognizer.testing_state = .Ended
                gestureRecognizer.invoke()
            }

            it("calls beginning closure") {
                var receivedInitialState: BidHistoryState?
                beginning = { initialState in
                    receivedInitialState = initialState
                }
                gestureRecognizer.testing_state = .Began

                gestureRecognizer.invoke()

                expect(receivedInitialState) == .Open
            }

            it("calls ending closure to cancel") {
                var receivedTargetState: BidHistoryState?
                completion = { targetState in
                    receivedTargetState = targetState
                }
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: -5)
                gestureRecognizer.testing_state = .Ended

                gestureRecognizer.invoke()

                expect(receivedTargetState) == .Open
            }

            it("calls ending closure to complete") {
                var receivedTargetState: BidHistoryState?
                completion = { targetState in
                    receivedTargetState = targetState
                }
                gestureRecognizer.testing_velocity = CGPoint(x: 0, y: 5)
                gestureRecognizer.testing_state = .Ended

                gestureRecognizer.invoke()

                expect(receivedTargetState) == .Closed
            }
        }
    }
}
