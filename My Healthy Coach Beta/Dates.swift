
import Foundation

class Dates: ObservableObject {
    @Published var date = Date()
    
    func month() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
    
    func year() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }
}
