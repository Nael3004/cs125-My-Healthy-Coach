import SwiftUI
	
// Schedules need to be stored on the database
// we will extract and populate the schedule object in the app with the schedules extarcted from database
struct Schedule {
    let schedules: [String: [Int: String]] = [
        // testing purpose only, see if schedule correctly displays
        "2024-03-10": [
            1: "Sleep",
            2: "Sleep",
            3: "Sleep",
            4: "Sleep",
            5: "Sleep",
            6: "Sleep",
            7: "Sleep",
            8: "Sleep",
            9: "Sleep",
            10: "Eat",
            11: "Sleep",
            12: "Work",
            13: "Work",
            14: "Work",
            15: "Work",
            16: "Work",
            17: "Work",
            18: "Work",
            19: "Work",
            20: "Work",
            21: "Work",
            22: "Work",
            23: "Work",
            24: "Work"
        ],
    ]
}

struct ScheduleView: View {
    let schedule: Schedule
    let today: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Schedule")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .padding(.bottom, 10)
                if let todaySchedule = schedule.schedules[today] {
                    ForEach(todaySchedule.sorted(by: { $0.key < $1.key }), id: \.key) { hour, activity in
                        HStack {
                            Text("\(hour % 12 == 0 ? 12 : hour % 12) \(hour < 12 ? "AM" : "PM"):")
                                .foregroundColor(.black)
                                .font(.system(size: 23))
                                .frame(width: 70, alignment: .leading)
                            Text(activity)
                                .foregroundColor(.black)
                                .font(.system(size: 23))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("No schedule available for today.")
                        .padding(.bottom, 5)
                        .padding(.leading)
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @State private var currentState: Int? = nil
    @State private var age: Int = 1
    @State private var dairyAllergy = false
    @State private var fishAllergy = false
    @State private var shellfishAllergy = false
    @State private var nutAllergy = false
    @State private var vegetarian = false

    // UserDefaults keys
    private let ageKey = "UserAge"
    private let dairyKey = "dairyAllergy"
    private let fishKey = "fishAllergy"
    private let shellfishKey = "shellfishAllergy"
    private let nutKey = "NutAllergy"
    private let vegKey = "Vegetarian"
    let schedule = Schedule()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                VStack {
                    switch currentState {
                    case 0:
                        ScheduleView(schedule: schedule)
                    case 1:
                        Text("Placeholder")
                    case 2:
                        VStack {
                            HStack {
                                Text("Age:")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                Picker(selection: $age, label: Text("")) {
                                    ForEach(1..<100) { index in Text("\(index)").tag(index)}
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 100)
                            }.padding()
                            Toggle("Dairy Allergy", isOn: $dairyAllergy)
                                .font(.headline).padding()
                            Toggle("Fish Allergy", isOn: $fishAllergy)
                                .font(.headline).padding()
                            Toggle("Shellfish Allergy", isOn: $shellfishAllergy)
                                .font(.headline).padding()
                            Toggle("Nut Allergy", isOn: $nutAllergy)
                                .font(.headline).padding()
                            Toggle("Vegetarian", isOn: $vegetarian)
                                .font(.headline).padding()
                            Button(action: saveAnswers) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.blue)
                                        .frame(height: 50)
                                        .cornerRadius(10)
                                        .padding()
                                    Text("Save")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .onTapGesture {
                                withAnimation {
                                    saveAnswers()
                                }
                            }
                        }
                    default:
                        EmptyView()
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
                        Image(systemName: "note.text").resizable().cornerRadius(10).aspectRatio(contentMode:.fit).frame(width: 80, height: 80).foregroundColor(.black).padding(.horizontal)
                    }
                    Text("Recommendations")
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
    
    // needs to connect and store answers on database
    private func saveAnswers() {
        UserDefaults.standard.set(age, forKey: ageKey)
        UserDefaults.standard.set(dairyAllergy, forKey: dairyKey)
        UserDefaults.standard.set(fishAllergy, forKey: fishKey)
        UserDefaults.standard.set(shellfishAllergy, forKey: shellfishKey)
        UserDefaults.standard.set(nutAllergy, forKey: nutKey)
        UserDefaults.standard.set(vegetarian, forKey: vegKey)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
