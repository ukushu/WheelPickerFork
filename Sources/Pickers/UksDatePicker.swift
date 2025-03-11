
import SwiftUI
import MoreSwiftUI
import Essentials

@available(macOS 12, *)
public struct UksDatePicker: View {
    @Binding var date: Date
    
    let yearRange: [Int]
    let monthRange: [Int] = (1...12).map { $0 }
    
    @State private var year: Int
    @State private var month: Int
    @State private var day: Int
    
    @State private var shown = false
    
    let osDateFormat: [DateFormatType]
    
    public init(date: Binding<Date>, yearRange: [Int] = (1900...(Date.now.year)).map{ $0 } ) {
        _date = date
        self.yearRange = yearRange
        self.year = date.wrappedValue.year
        self.month = date.wrappedValue.month
        self.day = date.wrappedValue.day
        self.osDateFormat = Date.now.dateFormat
    }
    
    public var body: some View {
        PickerButtonBody()
            .onChange(of: day) {
                if date.day != $0 {
                    date = Date(calendar: date.calendar, timeZone: nil, era: date.era, year: date.year, month: date.month, day: $0)!
                }
            }
            .onChange(of: month) {
                if date.month != $0 {
                    let tmp = Date(calendar: .current, year: date.year, month: $0, day: 1)!
                    
                    if day <= 28 || tmp.daysInMonth >= date.daysInMonth {
                        date = Date(calendar: date.calendar, timeZone: nil, era: date.era, year: date.year, month: $0, day: date.day )!
                    } else {
                        date = Date(calendar: date.calendar, timeZone: nil, era: date.era, year: date.year, month: $0, day: tmp.daysInMonth)!
                    }
                }
            }
            .onChange(of: year) {
                if date.month != $0 {
                    date = Date(calendar: .current, year: $0, month: date.month, day: date.day)!
                }
            }
            .onChange(of: date) { _ in
                if year != date.year {
                    year = date.year
                }
                
                if month != date.month {
                    month = date.month
                }
                
                if day != date.day {
                    day = date.day
                }
            }
    }
    
    func PickerButtonBody() -> some View {
        Button(action: { shown.toggle() }) { PickerLabel() }
            .popover(isPresented: $shown) {
                PopoverBody()
                    .padding(.horizontal)
//                    .background{ AppBackground().padding(.all, -30) }
                #if os(iOS)
                    .presentationCompactAdaptation(.popover)
                #endif
            }
    }
    
    func PickerLabel() -> some View {
        Text(verbatim: date.localizedString() )
            .padding(EdgeInsets(horizontal: 8, vertical: 5))
            .fixedSize()
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
            }
    }
    
    @ViewBuilder
    func PopoverBody() -> some View {
        HStack {
            ForEach(osDateFormat, id: \.self) { format in
                switch format {
                case .day:
                    DayPicker()
                        .frame(minWidth: 80)
                        #if os(macOS)
                        #endif
                case .month:
                    MonthPicker()
                        .frame(minWidth: 80)
                case .year:
                    YearPicker()
                        .frame(minWidth: 80)
                case .unknown:
                    Text(verbatim: "Error")
                }
            }
        }
        .background(SelectedPositionBackground())
    }
    
    func YearPicker() -> some View {
        FiniteWheelPicker(selection: $year, items: yearRange, displayBg: false) { value in
            if let value = value {
                Text(String(value))
            } else {
                Text("")
            }
        }
    }
    
    func MonthPicker() -> some View {
        FiniteWheelPicker(selection: $month, items: monthRange, displayBg: false) { value in
            if let value = value {
                Text("\(value)")
            } else {
                Text("")
            }
        }
    }
    
    @ViewBuilder
    func DayPicker() -> some View {
        let dayRange: [Int] = (1...date.daysInMonth).map{ $0 }
        
        FiniteWheelPicker(selection: $day, items: dayRange, displayBg: false) { value in
            if let value = value {
                Text("\(value)")
            } else {
                Text("")
            }
        }
        .id(month)
    }
}

fileprivate extension Date {
    var daysInMonth: Int {
        let dateComponents = DateComponents(year: self.year, month: self.month)
        let calendar = self.calendar
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func localizedString() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return self.asString(dateFormatter.dateFormat)
    }
    
    var dateFormat: [DateFormatType] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        guard let format = dateFormatter.dateFormat else { return [.year, .month, .day] }
        
        let formats = format.split(byCharsIn: "/.,:")
            .map { str -> DateFormatType in
                switch str {
                case "MM":
                    return .month
                case "yyyy":
                    return .year
                case "y":
                    return .year
                case "dd":
                    return .day
                default:
                    return .unknown
                }
            }
        
        guard !formats.contains(.unknown) else { return [.year, .month, .day] }
        
        return formats
    }
}

enum DateFormatType {
    case month
    case day
    case year
    
    case unknown
}
