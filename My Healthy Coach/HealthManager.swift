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
        let healthTypes: Set = [steps, sleepSampleType, calories]

        Task {
            do{
                try await healthStore.requestAuthorization(toShare: [], read:healthTypes)
                fetchStepCount()
                fetchCalories()
                fetchSleep()
            } catch {
                print("error fetching healthkit data")
            }
        } 
    }

    func fetchStepCount(){
        let steps = HKQuantityType(.stepCount)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
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

    func fetchCalories(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: pred) { _, result, error in 
            guard let numCalories = result, error == nil else {
                print("error fetching calories")
                return
            }
        let numCalories = result.sumQuantity()
        let caloriesBurned = numSteps.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }

    func fetchSleep(){
        let sleep = HKQuantityType(.sleepAnalysis)
        let pred = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: sleep, quantitySamplePredicate: pred) { _, result, error in 
            guard let sleepInfo = result, error == nil else {
                print("error fetching sleep")
                return
            }
        let sleepInfo = result.sumQuantity()
        let sleepInfo = sleepInfo.doubleValue(for: .count())
        }
        healthStore.execute(query)
    }
}