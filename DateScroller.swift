import SwiftUI

struct DateScroller: View {
    @EnvironmentObject var tDate: Dates
    var body: some View {
        HStack {
            Spacer()
            Button(action: prevMonth) {
                Image(systemName: "arrow.left").imageScale(.large)
            }
            Text(CalendarHelper().MYString(tDate.date)).font(.title).bold().frame(maxWidth: .infinity)
            Button(action: nextMonth) {
                Image(systemName: "arrow.right").imageScale(.large)
            }
            Spacer()
        }
    }
    
    func prevMonth() {
        tDate.date = CalendarHelper().minusMonth(tDate.date)
    }
    
    func nextMonth() {
        tDate.date = CalendarHelper().addMonth(tDate.date)
    }
}
