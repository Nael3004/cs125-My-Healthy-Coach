import Foundation
import HealthKit
import UIKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()

    init() {
        let steps = HKQuantityType(.stepCount)
        let sleepSampleType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
                //let sleepTime = HKCategoryValueSleepAnalysis.inBed.rawValue
        //let calories = HKQuantityType(.activeEnergyBurned)
        let fat = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
        let satfat = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
        let cholesterol = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
        let carbohydrates = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
        let sodium = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
        let fiber = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
        let protein = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
        let sugar = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
        let workouts = HKObjectType.workoutType()
        let healthTypes: Set = [steps, sleepSampleType, fat, satfat, cholesterol, carbohydrates, sodium, fiber, protein, sugar, workouts]

        Task {
            do{
                try await healthStore.requestAuthorization(toShare: [], read:healthTypes)
                fetchStepCountWeek()
                fetchStepCountToday()
                fetchSleep()
                //fetchCaloriesBurnedWeek()
                //fetchCaloriesBurnedToday()
                fetchFat()
                fetchSatFat()
                fetchCholesterol()
                fetchCarbohydrates()
                fetchSodium()
                fetchFiber()
                fetchProtein()
                fetchSugar()
            } catch {
                print("error fetching healthkit data")
            }
        }
    }

    func fetchStepCountWeek() -> Array<Int>{
            return [2051, 3391, 385, 7940, 5831, 1932, 538]
            let steps = HKQuantityType(.stepCount)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: pred) { _, result, error in
                guard let numSteps = result?.sumQuantity(), error == nil else {
                    print("error fetching step count")
            }
            let stepCount = numSteps.doubleValue(for: .count())
            print(stepCount)
            }
            healthStore.execute(query)
        }

        func fetchStepCountToday() -> Int{
            return 538
            let steps = HKQuantityType(.stepCount)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: pred) { _, result, error in
                guard let numSteps = result?.sumQuantity(), error == nil else {
                    print("error fetching step count")
                    return
            }
            let stepCount = numSteps.doubleValue(for: .count())
            print(stepCount)
            }
            healthStore.execute(query)
        }

    func fetchSleep() -> Array<(Int, Int)>{
        return [(6, 30), (7,41), (7,11), (8, 8), (5, 3), (9, 1), (8, 48)]
        let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKSampleQuery(sampleType: sleep, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, result, error in
            guard let sleepInfo = result as? [HKCategorySample], error == nil else {
                print("error fetching sleep")
                return
            }
        //let sleepInfo = result.sumQuantity()
            print(sleepInfo, "sleep info")
        }
        healthStore.execute(query)
    }

    // func fetchCaloriesBurnedWeek(){
        //     let calories = HKQuantityType(.activeEnergyBurned)
        //     let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        //     let query = HKStatisticsCollectionQuery(quantityType: calories, quantitySamplePredicate: pred) { _, result, error in
        //         guard let numCalories = result, error == nil else {
        //             print("error fetching calories")
        //             return
        //         }
        //     let numCalories = result.sumQuantity()
        //     let caloriesBurned = numCalories.doubleValue(for: .count())
        //     }
        //     healthStore.execute(query)
        // }

    // func fetchCaloriesBurnedWeek(){
        //     let calories = HKQuantityType(.activeEnergyBurned)
        //     let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        //     let query = HKStatisticsCollectionQuery(quantityType: calories, quantitySamplePredicate: pred) { _, result, error in
        //         guard let numCalories = result, error == nil else {
        //             print("error fetching calories")
        //             return
        //         }
        //     let numCalories = result.sumQuantity()
        //     let caloriesBurned = numCalories.doubleValue(for: .count())
        //     }
        //     healthStore.execute(query)
        // }

    func fetchFat() -> Array<Int>{
            return [30, 43, 26, 52, 49, 35, 62]
            let fat = HKQuantityType(.dietaryFatTotal)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: fat, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let fatInfo = result as? [HKQuantitySample] else {
                    print("error fetching fat")
                    return
                }
                let fat_Info = fatInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(fat_Info)
            }
            healthStore.execute(query)
        }

        func fetchSatFat() -> Array<Int>{
            return [20, 31, 17, 15, 39, 21, 33]
            let satfat = HKQuantityType(.dietaryFatSaturated)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: satfat, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let satfatInfo = result as? [HKQuantitySample] else {
                    print("error fetching sat fat")
                    return
                }
                let sat_fatInfo = satfatInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(sat_fatInfo)
            }
            healthStore.execute(query)
        }

        func fetchCholesterol() -> Array<Int>{
            return [110, 283, 193, 231, 348, 69, 234] // mg
            let cholesterol = HKQuantityType(.dietaryCholesterol)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: cholesterol, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let cholesterolInfo = result as? [HKQuantitySample] else {
                    print("error fetching cholesterol")
                    return
                }
                let cholesterol_Info = cholesterolInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(cholesterol_Info)
            }
            healthStore.execute(query)
        }

        func fetchCarbohydrates() -> Array<Int>{
            return [170, 150, 132, 79, 253, 196, 180]
            let carbohydrates = HKQuantityType(.dietaryCarbohydrates)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: carbohydrates, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let carbohydratesInfo = result as? [HKQuantitySample] else {
                    print("error fetching carbohydrates")
                    return
                }
                let carbohydrates_Info = carbohydratesInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(carbohydrates_Info)
            }
            healthStore.execute(query)
        }

        func fetchSodium() -> Array<Int>{
            return [729, 1300, 2210, 1832, 1039, 1639, 920] // mg
            let sodium = HKQuantityType(.dietarySodium)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: sodium, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let sodiumInfo = result as? [HKQuantitySample] else {
                    print("error fetching sodium")
                    return
                }
                let sodium_Info = sodiumInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(sodium_Info)
            }
            healthStore.execute(query)
        }

        func fetchFiber() -> Array<Int>{
            return [13, 18, 7, 20, 19, 22, 14]
            let fiber = HKQuantityType(.dietaryFiber)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: fiber, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let fiberInfo = result as? [HKQuantitySample] else {
                    print("error fetching fiber")
                    return
                }
                let fiber_Info = fiberInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(fiber_Info)
            }
            healthStore.execute(query)
        }

        func fetchProtein() -> Array<Int>{
            return [62, 36, 44, 30, 28, 45, 39]
            let protein = HKQuantityType(.dietaryProtein)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: protein, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let proteinInfo = result as? [HKQuantitySample] else {
                    print("error fetching protein")
                    return
                }
                let protein_Info = proteinInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(protein_Info)
            }
            healthStore.execute(query)
        }

        func fetchSugar() -> Array<Int>{
            return [26, 33, 20, 38, 19, 35, 27]
            let sugar = HKQuantityType(.dietarySugar)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date(), options: .strictEndDate)
            let query = HKSampleQuery(sampleType: sugar, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, result, error in
                guard error == nil, let sugarInfo = result as? [HKQuantitySample] else {
                    print("error fetching sugar")
                    return
                }
                let sugar_Info = sugarInfo.reduce(0.0) {$0 + $1.quantity.doubleValue(for: HKUnit.gram())}
                print(sugar_Info)
            }
            healthStore.execute(query)
        }

    func fetchWorkouts() -> Array<(Int, String)>{
        return [(60, "Running"), (38, "Gym"), (0, "None"), (117, "Biking"), (70, "Climbing"), (35, "Walking"), (47, "Running")] //minutes, exercise
        let workouts = HKSampleType.workoutType()
        let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date()),
            HKQuery.predicateForWorkoutActivities(workoutActivityType: .running)])
        let query = HKSampleQuery(sampleType: workouts, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                print("error fetching workouts")
                return
            }
        for workout in workouts{
            print(workout.allStatistics)
            print(workout.workoutActivityType)
            print(workout.duration)
            }
        }
        healthStore.execute(query)
    }
}
