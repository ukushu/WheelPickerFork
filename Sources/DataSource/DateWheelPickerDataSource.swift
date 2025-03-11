
import SwiftUI

public struct DateWheelPickerDataSource: WheelPickerDataSource {
    public var initialSelection: Date
    private let oneDaySeconds = 24 * 60 * 60
    
    public init(initialSelection: Date) {
        self.initialSelection = initialSelection
    }
    
    public func item(at offset: Int) -> Date? {
        initialSelection.advanced(by: TimeInterval(oneDaySeconds * offset))
    }
    
    public func offset(of item: Date) -> Int? {
        Int(initialSelection.distance(to: item)) / oneDaySeconds
    }
    
    public func translationOffset(to item: Date, origin: Int) -> Int {
        guard let offset = offset(of: item) else { return 0 }
        return offset - origin
    }
    
    public func limitDigreesTranslation(_ rawTranslation: Double, draggingStartOffset: Int?) -> Double {
        return rawTranslation
    }
    
    public func maxTranslation(draggingStartOffset: Int?) -> Double {
        .infinity
    }
    
    public func minTranslation(draggingStartOffset: Int?) -> Double {
        -.infinity
    }
}
