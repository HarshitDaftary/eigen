// For creating single direction pan gestures:
// http://stackoverflow.com/questions/7100884/uipangesturerecognizer-only-vertical-or-horizontal

import UIKit
import UIKit.UIGestureRecognizerSubclass


/// Necessary when we have a gesture recognizer attached to a view within a scroll view.
/// This recognizer needs to set its state to cancelled if the initial velocity is in the
/// wrong direction. This allows, say, a vertical gesture recognizer to be added to a view
/// within a horizontally scrolling scrollview.
class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    enum PanDirection {
        case Vertical
        case Horizontal
    }

    let direction: PanDirection

    init(direction: PanDirection) {
        self.direction = direction
        super.init(target: nil, action: nil)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        guard let view = self.view else { return }

        if state == .Began {
            let velocity = velocityInView(view)
            switch direction {
            case .Horizontal where fabs(velocity.y) > fabs(velocity.x):
                state = .Cancelled
            case .Vertical where fabs(velocity.x) > fabs(velocity.y):
                state = .Cancelled
            default:
                break
            }
        }
    }
}
