
import SwiftUI
import WheelPicker

struct ContentView: View {
    @State private var circularWheelPickerSelection: Int = 0
    @State private var finiteWheelPickerSelection: Int = 0
    @State private var dateWheelPickerSelection: Date = Date()
    let items: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    var body: some View {
        VStack {
            UksDatePicker(date: $dateWheelPickerSelection)
            
            // Circular style picker
            CircularWheelPicker(selection: $circularWheelPickerSelection, items: items) { value in
                // value may be nil (If the label is out of range)
                if let value = value {
                    Text("\(value)")
                } else {
                    Text("")
                }
            }
            // Finite style picker
            FiniteWheelPicker(selection: $finiteWheelPickerSelection, items: items) { value in
                // value may be nil (If the label is out of range)
                if let value = value {
                    Text("\(value)")
                } else {
                    Text("")
                }
            }
            // Date select picker (Multiple columns)
//            DateWheelPicker(selection: $dateWheelPickerSelection) { date in
//                let components = Calendar.current.dateComponents([.weekday], from: date)
//                switch components.weekday {
//                case 1: return .red // Sunday
//                case 7: return .blue // Saturday
//                default: return nil
//                }
//            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
