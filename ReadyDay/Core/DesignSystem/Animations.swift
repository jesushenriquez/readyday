import SwiftUI

extension Animation {
    /// Standard transition for content appearing
    static let rdAppear = Animation.spring(duration: 0.4, bounce: 0.15)

    /// Quick state change (toggle, button press)
    static let rdSnap = Animation.spring(duration: 0.2, bounce: 0.1)

    /// Chart/data animation on load
    static let rdChart = Animation.easeOut(duration: 0.6)

    /// Recovery ring fill animation
    static let rdRing = Animation.easeInOut(duration: 1.0)
}
