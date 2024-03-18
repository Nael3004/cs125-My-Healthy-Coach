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
        let finalSchedule: [Int: ActivityCategory] = Array(1...24).reduce(into: [Int: ActivityCategory]()) { $0[$1] = ActivityCategory(activity: "Edit Activity", category: "Edit Category") }
        let db = Firestore.firestore()
        let userID: String
        var ideal_sleeptime = 8
        if let existingUserID = UserDefaults.standard.string(forKey: "UserID") {
            userID = existingUserID
            let docRef = db.collection("users").document(userID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    ideal_sleeptime = document.data()!["ideal_sleep"] as! Int
                    //ideal_sleeptime = document.get("ideal_sleep")
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            let newUserID = UUID().uuidString
            UserDefaults.standard.set(newUserID, forKey: "UserID")
            UserDefaults.standard.set(8, forKey: "ideal_sleep")
            userID = newUserID
        }
        let fat = healthManager.fetchFat().reduce(0, +) / healthManager.fetchFat().count
        let sat_fat = healthManager.fetchSatFat().reduce(0, +) / healthManager.fetchSatFat().count
        let chol = healthManager.fetchCholesterol().reduce(0, +) / healthManager.fetchCholesterol().count
        let carbs = healthManager.fetchCarbohydrates().reduce(0, +) / healthManager.fetchCarbohydrates().count
        let sodium = healthManager.fetchSodium().reduce(0, +) / healthManager.fetchSodium().count
        let fiber = healthManager.fetchFiber().reduce(0, +) / healthManager.fetchFiber().count
        let prot = healthManager.fetchProtein().reduce(0, +) / healthManager.fetchProtein().count
        let sugar = healthManager.fetchSugar().reduce(0, +) / healthManager.fetchSugar().count
        let cur_nut_score = nut_rater(fat: fat, sat_fat: sat_fat, chol: chol, carbs: carbs, sodium: sodium, fiber: fiber, prot: prot, sugar: sugar)[0]
        let usr_ref = db.collection("users").document(userID)
        var food_arr = [Rating]()
        var workouts_arr = [Rating]()
        var restrictions = [String]()
        usr_ref.getDocument { (document, error) in
            if let document = document, document.exists {
                let usr_data = document.data()
                food_arr = usr_data!["foods"] as! [Rating]
                workouts_arr = usr_data!["workouts"] as! [Rating]
                restrictions = usr_data!["food_restrictions"] as! [String]
            } else {
                print("Document does not exist")
            }
        }

        var best_food = Food(id: "",name: "", fat: 0, sat_fat:0, carbs: 0, chol: 0, sodium: 0, sugar: 0, fiber: 0, prot: 0, restrictions: [String]())
        var best_food_score = Float(0)
        
        Firestore.firestore().collection("food").getDocuments { docs, err in
            if err == nil {
                print("Error getting documents")
            } else {
                for document in docs!.documents{
                    do {
                        let food_item = try document.data(as: Food.self)
                            
                        let f_score = nut_rater(fat: fat + food_item.fat, sat_fat: sat_fat + food_item.sat_fat, chol: chol + food_item.chol, carbs: carbs + food_item.carbs, sodium: sodium + food_item.sodium, fiber: fiber + food_item.fiber, prot: prot + food_item.prot, sugar: sugar + food_item.sugar)[0]
                        var restricted = false
                        for usr_rest in restrictions {
                            for food_rest in food_item.restrictions {
                                if usr_rest == food_rest {
                                    restricted = true
                                }
                            }
                        }
                            
                            
                            
                        var rating = 5 // can make unknown ratings depend on other item's ratings
                            
                        for usr_rate in food_arr {
                            if usr_rate.item == food_item.name {
                                rating = usr_rate.rating
                            }
                        }
                            
                        let weighted_f_score = Float((Float(f_score) - Float(cur_nut_score)) + Float(abs(Float(f_score) - Float(cur_nut_score))) * 0.1 * Float(rating))
                        
                        if weighted_f_score > best_food_score && !restricted {
                            best_food_score = weighted_f_score
                            best_food = food_item
                        }
                             
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        finalSchedule[13] = ActivityCategory(activity: "Just eat the usual, your meals are pretty healthy", category: "Nutrition")
        if best_food.name != "" {
            finalSchedule[13] = ActivityCategory(activity: "have some " + best_food.name, category: "Nutrition")
        }

        let vig_t = 0
        let mod_t = 0
        var mus_g = Set<String>() //replace with functions to populate data
        
        let cur_work_score = activ_rater(mod_time: mod_t, vig_time: vig_t, mus_groups: mus_g)[0]

        var best_workout = Workout(name: "", group: false, intensity: "", muscles: [String](), place: "")
        var best_workout_score = Float(0)
        Firestore.firestore().collection("workouts").getDocuments { docs, err in
            if err == nil {
                print("Error getting documents")
            } else {
                for document in docs!.documents{
                    do {
                        let workout_item = try document.data(as: Workout.self)
                            
                        var rating = 5 // can make unknown ratings depend on other item's ratings
                        
                        for usr_rate in workouts_arr {
                            if usr_rate.item == workout_item.name {
                                rating = usr_rate.rating
                            }
                        }
                        
                        let w_score = Float(0)
                        if workout_item.intensity == "moderate" {
                            let w_score = activ_rater(mod_time: mod_t + 60, vig_time: vig_t, mus_groups: mus_g)[0]
                        }
                        if workout_item.intensity == "vigorous" {
                            let w_score = activ_rater(mod_time: mod_t, vig_time: vig_t + 45, mus_groups: mus_g)[0]
                        }
                        if workout_item.intensity == "muscle" {
                            let groups = mus_g
                            for g in workout_item.muscles {
                                mus_g.insert(g)
                            }
                            let w_score = activ_rater(mod_time: mod_t, vig_time: vig_t, mus_groups: groups)[0]
                        }
                        
                        
                        let weighted_w_score = Float((Float(w_score) - Float(cur_work_score)) + Float(abs(Float(w_score) - Float(cur_work_score))) * 0.1 * Float(rating))
                         
                        if weighted_w_score > best_workout_score {
                            best_workout_score = weighted_w_score
                            best_workout = workout_item
                        }
                             
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        finalSchedule[18] = ActivityCategory(activity: "Usual exercise routine", category: "Exercise")
        if best_workout.name != "" {
            finalSchedule[18] = ActivityCategory(activity: "1 hour of " + best_workout.name, category: "Exercise")
        }

        var i = 0
        while i < ideal_sleeptime {
            var index = i - 7
            if index <= 0 {
                index = index + 24
            }
            finalSchedule[index] = ActivityCategory(activity: "Sleep", category: "Sleep")
            i = i + 1
        }
        editableSchedules[date] = finalSchedule
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

struct Food: Codable {
    @DocumentID var id: String?
    var name: String
    var fat: Int
    var sat_fat: Int
    var carbs: Int
    var chol: Int
    var sodium: Int
    var sugar: Int
    var fiber: Int
    var prot: Int
    var restrictions: [String]
}

struct Workout: Codable {
    @DocumentID var id: String?
    var name: String
    var group: Bool
    var intensity: String
    var muscles: [String]
    var place: String
}

struct Rating: Codable {
    var item: String
    var rating: Int
}


struct RecommendationsView: View {
    @State private var ratings: [String: [String: Int]] = [:]
    let healthManager = HealthManager()
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Please Rate the Recommendations Suggested").font(.system(size: 25)).multilineTextAlignment(.center)
                    .padding()
                Rectangle().fill(Color.black).frame(height: 5).padding([.top, .bottom], 8)
                ForEach(generateRecommendation()) { recommendation in
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

    func generateRecommendation() -> [Recommendation] {
        let db = Firestore.firestore()
        let userID: String
        var ideal_sleeptime = 8
        if let existingUserID = UserDefaults.standard.string(forKey: "UserID") {
            userID = existingUserID
            let docRef = db.collection("users").document(userID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    ideal_sleeptime = document.data()!["ideal_sleep"] as! Int
                    //ideal_sleeptime = document.get("ideal_sleep")
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            let newUserID = UUID().uuidString
            UserDefaults.standard.set(newUserID, forKey: "UserID")
            UserDefaults.standard.set(8, forKey: "ideal_sleep")
            UserDefaults.standard.set([Rating](), forKey: "foods")
            UserDefaults.standard.set([Rating](), forKey: "workouts")
            UserDefaults.standard.set([String](), forKey: "food_restrictions")
            userID = newUserID
        }
        let fat = healthManager.fetchFat().reduce(0, +) / healthManager.fetchFat().count
        let sat_fat = healthManager.fetchSatFat().reduce(0, +) / healthManager.fetchSatFat().count
        let chol = healthManager.fetchCholesterol().reduce(0, +) / healthManager.fetchCholesterol().count
        let carbs = healthManager.fetchCarbohydrates().reduce(0, +) / healthManager.fetchCarbohydrates().count
        let sodium = healthManager.fetchSodium().reduce(0, +) / healthManager.fetchSodium().count
        let fiber = healthManager.fetchFiber().reduce(0, +) / healthManager.fetchFiber().count
        let prot = healthManager.fetchProtein().reduce(0, +) / healthManager.fetchProtein().count
        let sugar = healthManager.fetchSugar().reduce(0, +) / healthManager.fetchSugar().count
        let cur_nut_score = nut_rater(fat: fat, sat_fat: sat_fat, chol: chol, carbs: carbs, sodium: sodium, fiber: fiber, prot: prot, sugar: sugar)[0]
        let usr_ref = db.collection("users").document(userID)
        var food_arr = [Rating]()
        var workouts_arr = [Rating]()
        var restrictions = [String]()
        usr_ref.getDocument { (document, error) in
            if let document = document, document.exists {
                let usr_data = document.data()
                food_arr = usr_data!["foods"] as! [Rating]
                workouts_arr = usr_data!["workouts"] as! [Rating]
                restrictions = usr_data!["food_restrictions"] as! [String]
            } else {
                print("Document does not exist")
            }
        }

        var best_food = Food(id: "",name: "", fat: 0, sat_fat:0, carbs: 0, chol: 0, sodium: 0, sugar: 0, fiber: 0, prot: 0, restrictions: [String]())
        var best_food_score = Float(0)
        
        Firestore.firestore().collection("food").getDocuments { docs, err in
            if err == nil {
                print("Error getting documents")
            } else {
                for document in docs!.documents{
                    do {
                        let food_item = try document.data(as: Food.self)
                            
                        let f_score = nut_rater(fat: fat + food_item.fat, sat_fat: sat_fat + food_item.sat_fat, chol: chol + food_item.chol, carbs: carbs + food_item.carbs, sodium: sodium + food_item.sodium, fiber: fiber + food_item.fiber, prot: prot + food_item.prot, sugar: sugar + food_item.sugar)[0]
                        var restricted = false
                        for usr_rest in restrictions {
                            for food_rest in food_item.restrictions {
                                if usr_rest == food_rest {
                                    restricted = true
                                }
                            }
                        }
                            
                            
                            
                        var rating = 5 // can make unknown ratings depend on other item's ratings
                            
                        for usr_rate in food_arr {
                            if usr_rate.item == food_item.name {
                                rating = usr_rate.rating
                            }
                        }
                            
                        let weighted_f_score = Float((Float(f_score) - Float(cur_nut_score)) + Float(abs(Float(f_score) - Float(cur_nut_score))) * 0.1 * Float(rating))
                        
                        if weighted_f_score > best_food_score && !restricted {
                            best_food_score = weighted_f_score
                            best_food = food_item
                        }
                             
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        var rec1 = Recommendation(category: "Nutrition", recommendation: "We don't have foods that fit your restrictions")
        if best_food.name != "" {
            rec1 = Recommendation(category: "Nutrition", recommendation: "try to eat more " + best_food.name)
        }

        let vig_t = 0
        let mod_t = 0
        var mus_g = Set<String>() //replace with functions to populate data
        
        let cur_work_score = activ_rater(mod_time: mod_t, vig_time: vig_t, mus_groups: mus_g)[0]

        var best_workout = Workout(name: "", group: false, intensity: "", muscles: [String](), place: "")
        var best_workout_score = Float(0)
        Firestore.firestore().collection("workouts").getDocuments { docs, err in
            if err == nil {
                print("Error getting documents")
            } else {
                for document in docs!.documents{
                    do {
                        let workout_item = try document.data(as: Workout.self)
                            
                        var rating = 5 // can make unknown ratings depend on other item's ratings
                        
                        for usr_rate in workouts_arr {
                            if usr_rate.item == workout_item.name {
                                rating = usr_rate.rating
                            }
                        }
                        
                        let w_score = Float(0)
                        if workout_item.intensity == "moderate" {
                            let w_score = activ_rater(mod_time: mod_t + 60, vig_time: vig_t, mus_groups: mus_g)[0]
                        }
                        if workout_item.intensity == "vigorous" {
                            let w_score = activ_rater(mod_time: mod_t, vig_time: vig_t + 45, mus_groups: mus_g)[0]
                        }
                        if workout_item.intensity == "muscle" {
                            let groups = mus_g
                            for g in workout_item.muscles {
                                mus_g.insert(g)
                            }
                            let w_score = activ_rater(mod_time: mod_t, vig_time: vig_t, mus_groups: groups)[0]
                        }
                        
                        
                        let weighted_w_score = Float((Float(w_score) - Float(cur_work_score)) + Float(abs(Float(w_score) - Float(cur_work_score))) * 0.1 * Float(rating))
                         
                        if weighted_w_score > best_workout_score {
                            best_workout_score = weighted_w_score
                            best_workout = workout_item
                        }
                             
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        var rec2 = Recommendation(category: "Exercise", recommendation: "We don't have workouts that'd help you yet")
        if best_workout.name != "" {
            rec2 = Recommendation(category: "Exercise", recommendation: "Do some " + best_workout.name)
        }

        var rec3 = Recommendation(category: "Sleep", recommendation: "Your sleep is pretty healthy, keep limiting your screen usage before bed")
        let sleep_time = 42 //replace with healthManager func
        let deep_t = 8
        let rem_t = 8

        if ideal_sleeptime - 1 > sleep_time {
            rec3 = Recommendation(category: "Sleep", recommendation: "You should sleep more")
        } else if ideal_sleeptime + 1 < sleep_time {
            rec3 = Recommendation(category: "Sleep", recommendation: "You should sleep a little less")
        } else if Double(rem_t) / Double(sleep_time) < 0.25 {
            rec3 = Recommendation(category: "Sleep", recommendation: "You should try to make your sleep schedule more regular")
        } else if Double(deep_t) / Double(sleep_time) < 0.25 {
            rec3 = Recommendation(category: "Sleep", recommendation: "You should do relaxation exercises or meditate before sleeping")
        }

        
        return [rec1, rec2, rec3]
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

func nut_rater(fat: Int, sat_fat: Int, chol: Int, carbs: Int, sodium: Int, fiber: Int, prot: Int, sugar: Int) -> [Float] {
    let fiber_score = Float(min(max((13 - (28 - Float(fiber))) / 13, 0), max((18 - (Float(fiber) - 28)) / 18, 0)))
    let fat_score = Float(min(max((53 - (78 - Float(fat))) / 53, 0), max((15 - (Float(fat) - 78)) / 15, 0)))
    let sat_fat_score = Float(min(max((15 - (20 - Float(sat_fat))) / 15, 0), max((10 - (Float(sat_fat) - 20)) / 10, 0)))
    let chol_score = Float(min(max((100 - (300 - Float(chol))) / 100, 0), max((25 - (Float(chol) - 300)) / 25, 0)))
    let carbs_score = Float(min(max((175 - (275 - Float(carbs))) / 175, 0), max((75 - (Float(carbs) - 275)) / 75, 0)))
    let sodium_score = Float(min(max((700 - (2300 - Float(sodium))) / 700, 0), max((350 - (Float(sodium) - 2300)) / 350, 0)))
    let prot_score = Float(min(max((15 - (50 - Float(prot))) / 15, 0), max((20 - (Float(prot) - 50)) / 20, 0)))
    let sugar_score = Float(min(max((25 - (50 - Float(sugar))) / 25, 0), max((15 - (Float(sugar) - 50)) / 15, 0)))
    let score = Float(min(0.125 * fiber_score + 0.125 * fat_score + 0.125 * sat_fat_score + 0.125 * chol_score + 0.125 * carbs_score + 0.125 * sodium_score + 0.125 * prot_score + 0.125 * sugar_score, 1))
    return [score, fat_score, sat_fat_score, chol_score, carbs_score, sodium_score, fiber_score, prot_score, sugar_score]
}

func sleep_rater(sleep_time: Double, REM_time: Float, deep_time: Float, ideal_sleeptime: Int, nightsmeasured: Int=7) -> [Float] {
    var sleeptime = Double(sleep_time) / Double(nightsmeasured)
    var tot_time_score = Float(min(max((Float(ideal_sleeptime + 1) - Float(sleeptime)) / Float(ideal_sleeptime - 1), 0), max((Float(sleeptime - 1) - Float(ideal_sleeptime)) / Float(ideal_sleeptime + 1), 0)))
    if Double(ideal_sleeptime - 1) <= sleeptime && Double(ideal_sleeptime + 1) >= sleeptime {
        tot_time_score = 1
    }
    sleeptime = sleeptime * Double(nightsmeasured)
    var REM_score = max(min(max((0.08 - (0.25 - (Float(REM_time)/Float(sleeptime)))) / 0.08, 0), max((0.1 - (Float(REM_time)/Float(sleeptime))) / 0.1, 0)), 1)
    var deep_score = Float(max(min(max((0.08 - (0.25 - (Float(deep_time)/Float(sleeptime)))) / 0.08, 0), max((0.1 - (Float(deep_time)/Float(sleeptime))) / 0.1, 0)), 1))
    var score = Float(min(0.4 * tot_time_score + 0.3 * REM_score + 0.3 * deep_score, 1))
    return [score, tot_time_score, REM_score, deep_score]
}

func activ_rater(mod_time: Int, vig_time: Int, mus_groups: Set<String>) -> [Float] {
    let mod_score = Float(min((Float(mod_time) / 150), 1))
    let vig_score = Float(min((Float(vig_time) / 75), 1))
    let mix_score = Float(min(((Float(mod_time) + 2 * Float(vig_time)) / 150), 1))
    let cardio_score = Float(max(mod_score, vig_score, mix_score))
    let mus_groups_score = Float(max(min(1 - ((7 - mus_groups.count) / 7), 1), 0))
    let score = min(cardio_score * 0.7 + 0.3 * mus_groups_score, 1)
    return [score, cardio_score, mod_score, vig_score, mix_score, mus_groups_score]
}

struct ContentView: View {
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
    
    let healthManager = HealthManager()

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
                        //let steps = healthManager.fetchStepCountWeek()
                        //print(steps, "steps")
                    } label: {
                        Image(systemName: "person").resizable().cornerRadius(10).aspectRatio(contentMode:.fit).frame(width: 80.0, height: 80).foregroundColor(.black).padding(.horizontal)
                    }
                    Text("Profile")
                }
            }
        }
        .onAppear {
            loadAnswers()
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
