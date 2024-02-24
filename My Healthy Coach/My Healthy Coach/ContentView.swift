//
//  ContentView.swift
//  My Healthy Coach
//
//  Created by Johnson Chen on 2/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentState: Int? = nil
    var body: some View {
    
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                VStack {
                    switch currentState {
                    case 0:
                        Text("Schedule Placeholder")
                    case 1:
                        Text("Calendar Placeholder")
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
