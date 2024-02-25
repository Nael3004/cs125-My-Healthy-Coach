

import Foundation

class CalendarHelper {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    func MYString(_ date: Date) -> String {
        dateFormatter.dateFormat = "LLL yyyy"
        return dateFormatter.string(from: date)
    }
    
    func addMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func daysInMonth(_ date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func daysOfMonth(_ date: Date) -> Int {
        let comp = calendar.dateComponents([.day], from: date)
        return comp.day!
    }
    
    func firstOfMonth(_ date: Date) -> Date {
        let comp = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comp)!
    }
    
    func weekDay(_ date: Date) -> Int {
        let comp = calendar.dateComponents([.weekday], from: date)
        return comp.weekday! - 1
    }
}
