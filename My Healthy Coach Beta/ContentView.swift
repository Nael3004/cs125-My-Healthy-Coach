//
//  ContentView.swift
//  My Healthy Coach
//
//  Created by Johnson Chen on 2/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentState: Int? = nil
    @EnvironmentObject var tDate: Dates
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                VStack {
                    switch currentState {
                    case 0:
                        Text("Schedule Placeholder")
                    case 1:
                        VStack(spacing: 1) {
                            DateScroller().environmentObject(tDate).padding()
                            dayOfWeek(for: tDate.date)
                            CalendarGrid(for: tDate.date)
                        }
                    case 2:
                        Text("Profile Placeholder")
                    default: EmptyView()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height * 0.84)
                .background(Color.white.opacity(0.2))
            }
            HStack {
                VStack {
                    Spacer()
                    Button {
                        currentState = 0
                    } label: {
                        Image(systemName: "clock").resizable().cornerRadius(10).aspectRatio(contentMode:.fit).frame(width: 80.0, height: 80.0).foregroundColor(.black).padding(.horizontal)
                    }
                    Text("Schedule")
                }
                VStack {
                    Spacer()
                    Button {
                        currentState = 1
                        tDate.date = Date()
                    } label: {
                        Image(systemName: "calendar").resizable().cornerRadius(10).aspectRatio(contentMode:.fit).frame(width: 80, height: 80).foregroundColor(.black).padding(.horizontal)
                    }
                    Text("Calendar")
                }
                VStack {
                    Spacer()
                    Button {
                        currentState = 2
                    } label: {
                        Image(systemName: "person").resizable().cornerRadius(10).aspectRatio(contentMode:.fit).frame(width: 80.0, height: 80).foregroundColor(.black).padding(.horizontal)
                    }
                    Text("Profile")
                }
            }
        }
    }
    func dayOfWeek(for date: Date) -> some View {
            HStack(spacing: 1) {
                Text("Sun").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Mon").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Tue").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Wed").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Thu").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Fri").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
                Text("Sat").dayOfW().font(.system(size: 20, weight: .bold, design: .default))
            }
        }
    
    func CalendarGrid(for date: Date) -> some View {
        VStack(spacing: 1) {
            let daysInMonth = CalendarHelper().daysInMonth(tDate.date)
            let firstday = CalendarHelper().firstOfMonth(tDate.date)
            let startingSpaces = CalendarHelper().weekDay(firstday)
            let prevM = CalendarHelper().minusMonth(tDate.date)
            let daysInPrevMonth = CalendarHelper().daysInMonth(prevM)
            ForEach(0..<6) {
                row in
                HStack(spacing: 1) {
                    ForEach(1..<8) {
                        column in
                        let count = column + (row * 7)
                        CalendarCell(count: count, startingSpaces: startingSpaces, daysInMonth: daysInMonth, daysInPrevMonth: daysInPrevMonth).environmentObject(tDate)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Text {
    func dayOfW() -> some View {
        self.frame(maxWidth: .infinity).padding(.top, 1).lineLimit(1)
    }
}
