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

        func fetchStepCountWeek(){
            let steps = HKQuantityType(.stepCount)
            let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
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

        func fetchStepCountToday(){
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

        func fetchSleep(){
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

        func fetchFat(){
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

        func fetchSatFat(){
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

        func fetchCholesterol(){
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

        func fetchCarbohydrates(){
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

        func fetchSodium(){
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

        func fetchFiber(){
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

        func fetchProtein(){
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

        func fetchSugar(){
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

    func fetchWorkouts(){
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
