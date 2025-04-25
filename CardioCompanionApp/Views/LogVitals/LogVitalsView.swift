import SwiftUI
import HealthKit

// Model to store vital readings
struct VitalReadings {
    var date: Date = Date()
    var heartRate: Double?
    var oxygenLevel: Double?
    var bloodPressureSystolic: Double?
    var bloodPressureDiastolic: Double?
}

struct LogVitalsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vitalsManager = VitalsManager.shared
    @Binding var selectedTab: Int
    @State private var currentStep = 1
    @State private var vitalReadings = VitalReadings()
    @State private var showHealthKitPermissionAlert = false
    @State private var errorMessage: String = ""
    @State private var showSavingError = false
    @State private var isSaving = false
    @State private var showStreakReward = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Log Vitals")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Progress indicator
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Text("Step \(currentStep) of 4")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Step Content
            switch currentStep {
            case 1:
                VitalsDateSelectionView(date: $vitalReadings.date)
            case 2:
                HeartRateView(heartRate: Binding(
                    get: { self.vitalReadings.heartRate ?? 0 },
                    set: { self.vitalReadings.heartRate = $0 }
                ))
            case 3:
                OxygenLevelView(oxygenLevel: Binding(
                    get: { self.vitalReadings.oxygenLevel ?? 0 },
                    set: { self.vitalReadings.oxygenLevel = $0 }
                ))
            case 4:
                BloodPressureView(
                    systolic: Binding(
                        get: { self.vitalReadings.bloodPressureSystolic ?? 0 },
                        set: { self.vitalReadings.bloodPressureSystolic = $0 }
                    ),
                    diastolic: Binding(
                        get: { self.vitalReadings.bloodPressureDiastolic ?? 0 },
                        set: { self.vitalReadings.bloodPressureDiastolic = $0 }
                    )
                )
            default:
                EmptyView()
            }
            
            Spacer()
            
            // Navigation buttons
            HStack {
                if currentStep > 1 {
                    Button(action: { currentStep -= 1 }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    if currentStep < 4 {
                        currentStep += 1
                    } else {
                        Task {
                            await saveVitals()
                        }
                    }
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(currentStep == 4 ? "Save" : "Next")
                            if currentStep < 4 {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isSaving)
            }
            .padding()
        }
        .alert("HealthKit Permission", isPresented: $showHealthKitPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enable HealthKit access in Settings to sync your vitals.")
        }
        .alert("Error Saving Vitals", isPresented: $showSavingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showStreakReward) {
            StreakRewardView(streak: vitalsManager.dailyStreak)
        }
        .task {
            let hasPermission = await vitalsManager.requestHealthKitPermission()
            if !hasPermission {
                showHealthKitPermissionAlert = true
            }
        }
    }
    
    private func saveVitals() async {
        isSaving = true
        
        // Validate inputs
        guard let heartRate = vitalReadings.heartRate, heartRate > 0 else {
            errorMessage = "Please enter a valid heart rate"
            showSavingError = true
            isSaving = false
            return
        }
        
        guard let oxygenLevel = vitalReadings.oxygenLevel,
              oxygenLevel > 0, oxygenLevel <= 100 else {
            errorMessage = "Please enter a valid oxygen level (0-100%)"
            showSavingError = true
            isSaving = false
            return
        }
        
        guard let systolic = vitalReadings.bloodPressureSystolic,
              let diastolic = vitalReadings.bloodPressureDiastolic,
              systolic > 0, diastolic > 0 else {
            errorMessage = "Please enter valid blood pressure readings"
            showSavingError = true
            isSaving = false
            return
        }
        
        do {
            try await vitalsManager.saveVitals(vitalReadings)
            
            // Show streak reward if streak is a multiple of 5
            if vitalsManager.dailyStreak > 0 && vitalsManager.dailyStreak % 5 == 0 {
                showStreakReward = true
            }
            
            // Switch to trends tab
            selectedTab = 1
            dismiss()
        } catch {
            print("VitalsManager: Error saving vitals: \(error)")
            errorMessage = "Error: \(error.localizedDescription)"
            showSavingError = true
        }
        
        isSaving = false
    }
}

struct StreakRewardView: View {
    let streak: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("🎉 Congratulations! 🎉")
                .font(.title)
                .bold()
            
            Text("\(streak) Day Streak!")
                .font(.title2)
            
            Text("You've logged your vitals for \(streak) consecutive days. Keep up the great work!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Continue") {
                dismiss()
            }
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .padding()
        }
        .padding()
    }
}

// MARK: - Step Views
struct VitalsDateSelectionView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When did you take these readings?")
                .font(.headline)
                .padding(.horizontal)
            
            DatePicker("Select Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Text("Select the date and time when you measured your vitals.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

struct HeartRateView: View {
    @Binding var heartRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                TextField("BPM", value: $heartRate, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("BPM")
            }
            .padding()
            
            Text("Use a heart rate monitor or count your pulse for 60 seconds.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

struct OxygenLevelView: View {
    @Binding var oxygenLevel: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Oxygen Level")
                .font(.headline)
                .padding(.horizontal)
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(oxygenLevel / 100, 1)))
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                TextField("", value: $oxygenLevel, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .font(.title)
                
                Text("%")
                    .font(.title2)
                    .offset(x: 40)
            }
            .padding()
            
            Text("Use a pulse oximeter to measure your oxygen saturation.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

struct BloodPressureView: View {
    @Binding var systolic: Double
    @Binding var diastolic: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Blood Pressure")
                .font(.headline)
                .padding(.horizontal)
            
            VStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 40))
                
                HStack(spacing: 20) {
                    VStack {
                        TextField("Systolic", value: $systolic, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("Systolic")
                            .font(.caption)
                    }
                    
                    Text("/")
                        .font(.title)
                    
                    VStack {
                        TextField("Diastolic", value: $diastolic, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("Diastolic")
                            .font(.caption)
                    }
                    
                    Text("mmHg")
                }
                .padding()
            }
            
            Text("Use a blood pressure cuff on your upper arm for accurate readings.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
} 