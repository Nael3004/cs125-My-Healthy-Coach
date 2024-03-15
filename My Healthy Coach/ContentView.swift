import SwiftUI
import Firebase
import FirebaseFirestore
    
struct ActivityCategory: Codable {
    let activity: String
    let category: String
}

class ScheduleViewModel: ObservableObject {
    @Published var editableSchedules: [String: [Int: ActivityCategory]] {
        didSet {
            saveSchedules()
        }
    }
    
    init(schedules: [String: [Int: ActivityCategory]]? = nil) {
        if let storedSchedules = UserDefaults.standard.object(forKey: "editableSchedules") as? Data,
           let decodedSchedules = try? JSONDecoder().decode([String: [Int: ActivityCategory]].self, from: storedSchedules) {
            self.editableSchedules = decodedSchedules
        } else if let schedules = schedules {
            self.editableSchedules = schedules
        } else {
            self.editableSchedules = [:]
        }
    }
    
    func updateSchedule(for date: String, hour: Int, activity: String, category: String) {
        editableSchedules[date]?[hour] = ActivityCategory(activity: activity, category: category)
        saveSchedules()
        uploadScheduleToFirebase()
        
    }
    
    // Replace this with the actual schedule recommendation code
    func createNewSchedule(for date: String) {
        let placeholderSchedule: [Int: ActivityCategory] = Array(1...24).reduce(into: [Int: ActivityCategory]()) { $0[$1] = ActivityCategory(activity: "Edit Activity", category: "Edit Category") }
        editableSchedules[date] = placeholderSchedule
        uploadScheduleToFirebase()
    }
    
    private func saveSchedules() {
        if let encoded = try? JSONEncoder().encode(editableSchedules) {
            UserDefaults.standard.set(encoded, forKey: "editableSchedules")
        }
    }
    
    func clearAndCreateNewSchedule(for date: String) {
        editableSchedules[date] = nil
        createNewSchedule(for: date)
        uploadScheduleToFirebase()
    }
    
    func deleteSchedule(for date: String) {
        if editableSchedules.keys.contains(date) {
            editableSchedules.removeValue(forKey: date)
        }
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "UserID") else {
            return
        }
        db.collection("users").document(userID).setData(["schedule": ""])
    }
    
    private func uploadScheduleToFirebase() {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "UserID") else {
            return
        }
        var scheduleToUpload: [String: String] = [:]
        for (_, dailySchedule) in editableSchedules {
            for (hour, activityCategory) in dailySchedule {
                let hourForDisplay = hour % 12 == 0 ? 12 : hour % 12
                let amPmSuffix = hour < 12 ? "AM" : "PM"
                let timeString = "\(hourForDisplay):00 \(amPmSuffix)"
                let activityDescription = activityCategory.activity
                scheduleToUpload[timeString] = activityDescription
            }
        }
        db.collection("users").document(userID).setData(["schedule": scheduleToUpload], merge: true)
    }
}

struct ScheduleView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    let today: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Today's Schedule - \(formattedDate)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(.leading)
                        .padding(.bottom, 10)
                }

                if let todaySchedule = viewModel.editableSchedules[today], !todaySchedule.isEmpty {
                    ForEach(Array(todaySchedule.keys).sorted(), id: \.self) { hour in
                        HStack {
                            Text("\(hour % 12 == 0 ? 12 : hour % 12) \(hour < 12 || hour == 24 ? "AM" : "PM"):")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                .frame(width: 70, alignment: .leading)
                            VStack {
                                TextEditor(text: Binding(
                                    get: { self.viewModel.editableSchedules[today]?[hour]?.activity ?? "" },
                                    set: { self.viewModel.updateSchedule(for: today, hour: hour, activity: $0, category: self.viewModel.editableSchedules[today]?[hour]?.category ?? "") }
                                ))
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                
                                TextField("Category", text: Binding(
                                    get: { self.viewModel.editableSchedules[today]?[hour]?.category ?? "" },
                                    set: { self.viewModel.updateSchedule(for: today, hour: hour, activity: self.viewModel.editableSchedules[today]?[hour]?.activity ?? "", category: $0) }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.top, 5)
                            }
                            .padding(.trailing)
                        }
                        .padding(.horizontal)
                        Rectangle().fill(Color.black).frame(height: 3).padding([.top, .bottom], 8)
                    }
                } else {
                    Text("No schedule available for today.")
                        .padding(.bottom, 5)
                        .padding(.leading)
                }
                
                HStack {
                    Button("Create New Schedule") {
                        viewModel.clearAndCreateNewSchedule(for: today)
                    }.foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.blue).cornerRadius(10)
                    Button("Delete Schedule") {
                        viewModel.deleteSchedule(for: today)
                    }.foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.red).cornerRadius(10)
                }
                .padding(.top, 10).fixedSize(horizontal: true, vertical: true)
            }
            .padding()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: Date())
    }
}


struct Recommendation: Identifiable {
    let id = UUID()
    let category: String
    let recommendation: String
}

// Testing only - Replace with the function that generates the recommendations to be rated
let recommendationsList = [
    Recommendation(category: "Health", recommendation: "Daily Exercise"),
    Recommendation(category: "Diet", recommendation: "Eat More Greens"),
    Recommendation(category: "Productivity", recommendation: "Use a Planner"),
]

struct RecommendationsView: View {
    @State private var ratings: [String: [String: Int]] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Please Rate the Recommendations Suggested").font(.system(size: 25)).multilineTextAlignment(.center)
                    .padding()
                Rectangle().fill(Color.black).frame(height: 5).padding([.top, .bottom], 8)
                ForEach(recommendationsList) { recommendation in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(recommendation.category) - \(recommendation.recommendation)").font(.system(size: 20))
                            .padding([.leading, .trailing], 16)
                        Slider(value: Binding<Double>(
                            get: {
                                Double(self.ratings[recommendation.category]?[recommendation.recommendation] ?? 5)
                            },
                            set: { newValue in
                                let intValue = Int(newValue.rounded())
                                self.ratings[recommendation.category, default: [:]][recommendation.recommendation] = intValue
                            }
                        ), in: 1...10, step: 1)
                        .padding([.leading, .trailing], 16)
                        Text("Rating: \(self.ratings[recommendation.category]?[recommendation.recommendation, default: 5] ?? 5)").font(.system(size: 20))
                            .padding([.leading, .trailing], 16)
                    }
                    Rectangle().fill(Color.black).frame(height: 3).padding([.top, .bottom], 8)
                }
                Button("Save Ratings") {
                    saveRatings()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            loadRatings()
        }
    }

    private func saveRatings() {
        if let encodedRatings = try? JSONEncoder().encode(ratings) {
            UserDefaults.standard.set(encodedRatings, forKey: "recommendationRatings")
        }
    }

    private func loadRatings() {
        if let savedRatings = UserDefaults.standard.object(forKey: "recommendationRatings") as? Data,
           let decodedRatings = try? JSONDecoder().decode([String: [String: Int]].self, from: savedRatings) {
            ratings = decodedRatings
        }
    }
}



struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var currentState: Int? = nil
    @State private var age: Int = 1
    @State private var dairyAllergy = false
    @State private var fishAllergy = false
    @State private var shellfishAllergy = false
    @State private var nutAllergy = false
    @State private var vegetarian = false

    private let ageKey = "UserAge"
    private let dairyKey = "dairyAllergy"
    private let fishKey = "fishAllergy"
    private let shellfishKey = "shellfishAllergy"
    private let nutKey = "NutAllergy"
    private let vegKey = "Vegetarian"

    var body: some View {
        let backgroundGradient = getBackgroundGradient(forState: currentState)
        ZStack {
            backgroundGradient.edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                VStack {
                    switch currentState {
                    case 0:
                        ScheduleView(viewModel: ScheduleViewModel())
                    case 1:
                        RecommendationsView()
                    case 2:
                        profileView
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
        .onAppear {
            loadAnswers()
            healthManager.fetchStepCountToday()
        }
    }
    
    private var profileView: some View {
            VStack {
                HStack {
                    Text("Age:")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                    Picker(selection: $age, label: Text("")) {
                        ForEach(1..<100) { index in Text("\(index)").tag(index) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }.padding()
                Toggle("Dairy Allergy", isOn: $dairyAllergy)
                    .font(.system(size: 30)).padding()
                Toggle("Fish Allergy", isOn: $fishAllergy)
                    .font(.system(size: 30)).padding()
                Toggle("Shellfish Allergy", isOn: $shellfishAllergy)
                    .font(.system(size: 30)).padding()
                Toggle("Nut Allergy", isOn: $nutAllergy)
                    .font(.system(size: 30)).padding()
                Toggle("Vegetarian", isOn: $vegetarian)
                    .font(.system(size: 30)).padding()
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
            }
        }
    
    private func saveAnswers() {
        let db = Firestore.firestore()
        let userID: String
        if let existingUserID = UserDefaults.standard.string(forKey: "UserID") {
            userID = existingUserID
        } else {
            let newUserID = UUID().uuidString
            UserDefaults.standard.set(newUserID, forKey: "UserID")
            userID = newUserID
        }
        let foodRestrictions: [String: Bool] = [
            "Dairy": dairyAllergy,
            "Fish": fishAllergy,
            "Shellfish": shellfishAllergy,
            "Nut": nutAllergy,
            "Vegetarian": vegetarian
        ]
        let activeRestrictions = foodRestrictions.filter { $0.value }.map { $0.key }
        let userData: [String: Any] = [
            "age": age,
            "food_restrictions": activeRestrictions
        ]
        db.collection("users").document(userID).setData(userData, merge: true)
        UserDefaults.standard.set(age, forKey: ageKey)
        UserDefaults.standard.set(dairyAllergy, forKey: dairyKey)
        UserDefaults.standard.set(fishAllergy, forKey: fishKey)
        UserDefaults.standard.set(shellfishAllergy, forKey: shellfishKey)
        UserDefaults.standard.set(nutAllergy, forKey: nutKey)
        UserDefaults.standard.set(vegetarian, forKey: vegKey)
    }
    
    private func loadAnswers() {
        age = UserDefaults.standard.integer(forKey: ageKey)
        dairyAllergy = UserDefaults.standard.bool(forKey: dairyKey)
        fishAllergy = UserDefaults.standard.bool(forKey: fishKey)
        shellfishAllergy = UserDefaults.standard.bool(forKey: shellfishKey)
        nutAllergy = UserDefaults.standard.bool(forKey: nutKey)
        vegetarian = UserDefaults.standard.bool(forKey: vegKey)
    }
    
    func getBackgroundGradient(forState currentState: Int?) -> LinearGradient {
            switch currentState {
            case 0:
                return LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
            case 1:
                return LinearGradient(gradient: Gradient(colors: [.blue, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
            case 2:
                return LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            default:
                return LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
