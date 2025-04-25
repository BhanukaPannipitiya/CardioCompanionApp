import Foundation
import HealthKit

class VitalsManager: ObservableObject {
    static let shared = VitalsManager()
    private let healthStore = HKHealthStore()
    
    @Published var dailyStreak: Int = 0
    @Published var lastLoggedDate: Date?
    
    private let userDefaults = UserDefaults.standard
    private let streakKey = "vitals_logging_streak"
    private let lastLoggedKey = "last_logged_date"
    
    init() {
        print("VitalsManager: Initializing...")
        loadStreak()
        print("VitalsManager: Initialized with streak: \(dailyStreak), last logged: \(String(describing: lastLoggedDate))")
    }
    
    func requestHealthKitPermission() async -> Bool {
        print("VitalsManager: Requesting HealthKit permissions...")
        guard HKHealthStore.isHealthDataAvailable() else {
            print("VitalsManager: HealthKit not available on this device")
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            print("VitalsManager: HealthKit permissions granted successfully")
            return true
        } catch {
            print("VitalsManager: Error requesting HealthKit authorization: \(error.localizedDescription)")
            print("VitalsManager: Detailed error: \(error)")
            return false
        }
    }
    
    func saveVitals(_ readings: VitalReadings) async throws {
        print("VitalsManager: Starting to save vitals...")
        print("VitalsManager: Readings to save - Date: \(readings.date)")
        if let hr = readings.heartRate { print("VitalsManager: Heart Rate: \(hr) BPM") }
        if let o2 = readings.oxygenLevel { print("VitalsManager: Oxygen Level: \(o2)%") }
        if let sys = readings.bloodPressureSystolic, let dia = readings.bloodPressureDiastolic {
            print("VitalsManager: Blood Pressure: \(sys)/\(dia) mmHg")
        }
        
        // Save to HealthKit if available
        if HKHealthStore.isHealthDataAvailable() {
            print("VitalsManager: HealthKit is available, attempting to save...")
            
            if let heartRate = readings.heartRate {
                print("VitalsManager: Saving heart rate...")
                try await saveHeartRate(heartRate, date: readings.date)
                print("VitalsManager: Heart rate saved successfully")
            }
            
            if let oxygenLevel = readings.oxygenLevel {
                print("VitalsManager: Saving oxygen level...")
                try await saveOxygenLevel(oxygenLevel, date: readings.date)
                print("VitalsManager: Oxygen level saved successfully")
            }
            
            if let systolic = readings.bloodPressureSystolic,
               let diastolic = readings.bloodPressureDiastolic {
                print("VitalsManager: Saving blood pressure...")
                try await saveBloodPressure(systolic: systolic,
                                          diastolic: diastolic,
                                          date: readings.date)
                print("VitalsManager: Blood pressure saved successfully")
            }
            
            print("VitalsManager: All HealthKit data saved successfully")
        } else {
            print("VitalsManager: HealthKit is not available on this device")
        }
        
        // Update streak
        print("VitalsManager: Updating streak...")
        updateStreak(for: readings.date)
        print("VitalsManager: Streak updated successfully. Current streak: \(dailyStreak)")
        
        print("VitalsManager: All vitals saved successfully")
    }
    
    private func saveHeartRate(_ value: Double, date: Date) async throws {
        print("VitalsManager: Creating heart rate sample - Value: \(value) BPM, Date: \(date)")
        let type = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let quantity = HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()),
                                doubleValue: value)
        let sample = HKQuantitySample(type: type,
                                    quantity: quantity,
                                    start: date,
                                    end: date)
        try await healthStore.save(sample)
    }
    
    private func saveOxygenLevel(_ value: Double, date: Date) async throws {
        print("VitalsManager: Creating oxygen level sample - Value: \(value)%, Date: \(date)")
        let type = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        let quantity = HKQuantity(unit: HKUnit.percent(),
                                doubleValue: value / 100.0)
        let sample = HKQuantitySample(type: type,
                                    quantity: quantity,
                                    start: date,
                                    end: date)
        try await healthStore.save(sample)
    }
    
    private func saveBloodPressure(systolic: Double,
                                 diastolic: Double,
                                 date: Date) async throws {
        print("VitalsManager: Creating blood pressure samples - Systolic: \(systolic), Diastolic: \(diastolic), Date: \(date)")
        let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(),
                                        doubleValue: systolic)
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(),
                                         doubleValue: diastolic)
        
        let systolicSample = HKQuantitySample(type: systolicType,
                                            quantity: systolicQuantity,
                                            start: date,
                                            end: date)
        let diastolicSample = HKQuantitySample(type: diastolicType,
                                             quantity: diastolicQuantity,
                                             start: date,
                                             end: date)
        
        try await healthStore.save([systolicSample, diastolicSample])
    }
    
    private func updateStreak(for date: Date) {
        print("VitalsManager: Updating streak for date: \(date)")
        let calendar = Calendar.current
        
        if let lastLogged = lastLoggedDate {
            let daysSinceLastLog = calendar.dateComponents([.day],
                                                         from: calendar.startOfDay(for: lastLogged),
                                                         to: calendar.startOfDay(for: date)).day ?? 0
            
            print("VitalsManager: Days since last log: \(daysSinceLastLog)")
            
            if daysSinceLastLog == 1 {
                // Consecutive day, increment streak
                dailyStreak += 1
                print("VitalsManager: Consecutive day - Streak increased to \(dailyStreak)")
            } else if daysSinceLastLog == 0 {
                // Same day, don't change streak
                print("VitalsManager: Same day log - Maintaining streak at \(dailyStreak)")
                return
            } else {
                // Streak broken
                dailyStreak = 1
                print("VitalsManager: Streak broken - Reset to 1")
            }
        } else {
            // First log
            dailyStreak = 1
            print("VitalsManager: First log - Starting streak at 1")
        }
        
        lastLoggedDate = date
        saveStreak()
        print("VitalsManager: Streak updated and saved - Current streak: \(dailyStreak)")
    }
    
    private func loadStreak() {
        print("VitalsManager: Loading streak data...")
        dailyStreak = userDefaults.integer(forKey: streakKey)
        lastLoggedDate = userDefaults.object(forKey: lastLoggedKey) as? Date
        print("VitalsManager: Loaded streak: \(dailyStreak)")
        if let date = lastLoggedDate {
            print("VitalsManager: Loaded last logged date: \(date)")
        } else {
            print("VitalsManager: No previous logged date found")
        }
    }
    
    private func saveStreak() {
        print("VitalsManager: Saving streak data...")
        userDefaults.set(dailyStreak, forKey: streakKey)
        userDefaults.set(lastLoggedDate, forKey: lastLoggedKey)
        print("VitalsManager: Saved streak: \(dailyStreak)")
        if let date = lastLoggedDate {
            print("VitalsManager: Saved last logged date: \(date)")
        }
    }
    
    func fetchHeartRateData(from startDate: Date, to endDate: Date) async throws -> [VitalDataPoint] {
        print("VitalsManager: Fetching heart rate data from \(startDate) to \(endDate)")
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let descriptor = HKSampleQueryDescriptor(predicates: [.quantitySample(type: heartRateType, predicate: predicate)], sortDescriptors: [SortDescriptor(\.startDate, order: .forward)])
        
        let results = try await descriptor.result(for: healthStore)
        
        return results.map { sample in
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            return VitalDataPoint(date: sample.startDate, value: heartRate)
        }
    }
    
    func fetchOxygenData(from startDate: Date, to endDate: Date) async throws -> [VitalDataPoint] {
        print("VitalsManager: Fetching oxygen data from \(startDate) to \(endDate)")
        let oxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let descriptor = HKSampleQueryDescriptor(predicates: [.quantitySample(type: oxygenType, predicate: predicate)], sortDescriptors: [SortDescriptor(\.startDate, order: .forward)])
        
        let results = try await descriptor.result(for: healthStore)
        
        return results.map { sample in
            let oxygen = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
            return VitalDataPoint(date: sample.startDate, value: oxygen)
        }
    }
    
    func fetchBloodPressureData(from startDate: Date, to endDate: Date) async throws -> [BloodPressureDataPoint] {
        print("VitalsManager: Fetching blood pressure data from \(startDate) to \(endDate)")
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        async let systolicResults = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: systolicType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        ).result(for: healthStore)
        
        async let diastolicResults = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: diastolicType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        ).result(for: healthStore)
        
        let (systolicSamples, diastolicSamples) = try await (systolicResults, diastolicResults)
        
        // Create a dictionary of diastolic readings by date
        let diastolicDict = Dictionary(
            uniqueKeysWithValues: diastolicSamples.map { sample in
                (sample.startDate, sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
            }
        )
        
        // Match systolic with diastolic readings
        return systolicSamples.compactMap { systolicSample in
            if let diastolic = diastolicDict[systolicSample.startDate] {
                let systolic = systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                return BloodPressureDataPoint(
                    date: systolicSample.startDate,
                    systolic: systolic,
                    diastolic: diastolic
                )
            }
            return nil
        }
    }
} 