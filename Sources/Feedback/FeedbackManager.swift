
import SwiftUI

class FeedbackManager {
    private var generator: NSObject?
    
    init() {
#if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        self.generator = generator
#endif
    }
    
    func generateFeedback() {
#if os(iOS)
        (generator as? UISelectionFeedbackGenerator)?.selectionChanged()
#endif
    }
}
