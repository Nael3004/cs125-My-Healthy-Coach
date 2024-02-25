import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject var tDate: Dates
    let count: Int
    let startingSpaces: Int
    let daysInMonth: Int
    let daysInPrevMonth: Int
    var body: some View {
        Text(monthS().day())
            .foregroundColor(textColor(type: monthS().monthType))
            .font(.system(size: 20, weight: .bold, design: .default))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func monthS() -> MonthS {
        let start = startingSpaces == 0 ? startingSpaces : startingSpaces
        if (count <= start) {
           let day = daysInPrevMonth + count - start
           return MonthS(monthType: MonthType.Previous, dayInt: day)
        }
        else if (count - start > daysInMonth) {
            let day = count - start - daysInMonth
            return MonthS(monthType: MonthType.Next, dayInt: day)
        }
        let day = count - start
        return MonthS(monthType: MonthType.Current, dayInt: day)
    }
    
    func textColor(type: MonthType) -> Color {
        let currentDay = Calendar.current.component(.day, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())

            if type == MonthType.Current {
                if monthS().dayInt == currentDay && currentMonth == tDate.month() && currentYear == tDate.year() {
                    return Color.blue
                } else {
                    return Color.black
                }
            } else {
                return Color.gray
            }
    }
}

struct CalendarCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarCell(count: 1, startingSpaces: 1, daysInMonth: 1, daysInPrevMonth: 1)
    }
}
