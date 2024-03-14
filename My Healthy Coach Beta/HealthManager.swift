import Foundation
import HealthKit
import UIKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()

    init() {
        let steps = HKQuantityType(.stepCount)
        let sleepSampleType = HKCategoryType(.sleepAnalysis)
        let sleepTime = HKCategoryValueSleepAnalysis.inBed.rawValue
        let calories = HKQuantityType(.activeEnergyBurned)
        let fat = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)
        let satfat = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)
        let cholesterol = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)
        let carbohydrates = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)
        let sodium = HKSampleType.quantityType(forIdentifier: .dietarySodium)
        let fiber = HKSampleType.quantityType(forIdentifier: .dietaryFiber)
        let protein = HKSampleType.quantityType(forIdentifier: .dietaryProtein)
        let sugar = HKSampleType.quantityType(forIdentifier: .dietarySugar)
        let workouts = HKObjectType.workoutType()
        let healthTypes: Set = [steps, sleepSampleType, calories, fat, satfat, cholestrol, carbohydrates, sodium, fiber, protein, sugar, workouts]

        Task {
            do{
                try await healthStore.requestAuthorization(toShare: [], read:healthTypes)
                fetchStepCount()
                fetchSleep()
                fetchCaloriesBurnedWeek()
                fetchCaloriesBurnedToday()
                fetchFat()
                fetchSatFat()
                fetchCholestrol()
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

    func fetchStepCount(){
        let steps = HKQuantityType(.stepCount)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: pred) { _, result, error in 
            guard let numSteps = result, error == nil else {
                print("error fetching step count")
                return
        }
        let numSteps = result.sumQuantity()
        let stepCount = numSteps.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchSleep(){
        let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKSampleQuery(sampleType: sleep, predicate: pred) { _, result, error in 
            guard let sleepInfo = result, error == nil else {
                print("error fetching sleep")
                return
            }
        let sleepInfo = result.sumQuantity()
        let sleepInfo = sleepInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchCaloriesBurnedWeek(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: pred) { _, result, error in 
            guard let numCalories = result, error == nil else {
                print("error fetching calories")
                return
            }
        let numCalories = result.sumQuantity()
        let caloriesBurned = numCalories.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchCaloriesBurnedToday(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: pred) { _, result, error in 
            guard let numCalories = result, error == nil else {
                print("error fetching calories")
                return
            }
        let numCalories = result.sumQuantity()
        let caloriesBurned = numCalories.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }      

    func fetchFat(){
        let fat = HKQuantityType(.dietaryFatTotal)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: fat, quantitySamplePredicate: pred) { _, result, error in 
            guard let fatInfo = result, error == nil else {
                print("error fetching fat")
                return
            }
        let fatInfo = result.sumQuantity()
        let fatInfo = fatInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchSatFat(){
        let satfat = HKQuantityType(.dietaryFatSaturated)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: satfat, quantitySamplePredicate: pred) { _, result, error in 
            guard let satfatInfo = result, error == nil else {
                print("error fetching sat fat")
                return
            }
        let satfatInfo = result.sumQuantity()
        let satfatInfo = satfatInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchCholestrol(){
        let cholestrol = HKQuantityType(.dietaryCholesterol)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: cholestrol, quantitySamplePredicate: pred) { _, result, error in 
            guard let cholestrolInfo = result, error == nil else {
                print("error fetching cholestrol")
                return
            }
        let cholestrolInfo = result.sumQuantity()
        let cholestrolInfo = cholestrolInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchCarbohydrates(){
        let carbohydrates = HKQuantityType(.dietaryCarbohydrates)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: carbohydrates, quantitySamplePredicate: pred) { _, result, error in 
            guard let carbohydratesInfo = result, error == nil else {
                print("error fetching carbohydrates")
                return
            }
        let carbohydratesInfo = result.sumQuantity()
        let carbohydratesInfo = carbohydratesInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchSodium(){
        let sodium = HKQuantityType(.dietarySodium)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: sodium, quantitySamplePredicate: pred) { _, result, error in 
            guard let sodiumInfo = result, error == nil else {
                print("error fetching sodium")
                return
            }
        let sodiumInfo = result.sumQuantity()
        let sodiumInfo = sodiumInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchFiber(){
        let fiber = HKQuantityType(.dietaryFiber)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: fiber, quantitySamplePredicate: pred) { _, result, error in 
            guard let fiberInfo = result, error == nil else {
                print("error fetching fiber")
                return
            }
        let fiberInfo = result.sumQuantity()
        let fiberInfo = fiberInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchProtein(){
        let protein = HKQuantityType(.dietaryProtein)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: protein, quantitySamplePredicate: pred) { _, result, error in 
            guard let proteinInfo = result, error == nil else {
                print("error fetching protein")
                return
            }
        let proteinInfo = result.sumQuantity()
        let proteinInfo = proteinInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchSugar(){
        let sugar = HKQuantityType(.dietarySugar)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: sugar, quantitySamplePredicate: pred) { _, result, error in 
            guard let sugarInfo = result, error == nil else {
                print("error fetching sugar")
                return
            }
        let sugarInfo = result.sumQuantity()
        let sugarInfo = sugarInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchWorkouts(){
        let workouts = HKSampleType.workoutType()
        let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date())),
            HKQuery.predicateForWorkoutActivities(workoutActivityType: .running)])
        let query = HKSampleQuery(sampleType: workouts, predicate: pred) { _, result, error in 
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