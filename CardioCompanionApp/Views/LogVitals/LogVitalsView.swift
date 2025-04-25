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
    
    // Color scheme
    private let primaryColor = Color.blue
    private let secondaryColor = Color.purple
    private let accentColor = Color.green
    private let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Log Vitals")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Progress indicator
                    HStack(spacing: 4) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(index < currentStep ? primaryColor : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(index < currentStep ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Text("Step \(currentStep) of 4")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    // Step Content
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 5)
                        
                        switch currentStep {
                        case 1:
                            VitalsDateSelectionView(date: $vitalReadings.date, currentPage: $currentStep)
                        case 2:
                            HeartRateView(heartRate: Binding(
                                get: { self.vitalReadings.heartRate ?? 0 },
                                set: { self.vitalReadings.heartRate = $0 }
                            ), currentPage: $currentStep)
                        case 3:
                            OxygenLevelView(oxygenLevel: Binding(
                                get: { self.vitalReadings.oxygenLevel ?? 0 },
                                set: { self.vitalReadings.oxygenLevel = $0 }
                            ), currentPage: $currentStep)
                        case 4:
                            BloodPressureView(
                                systolic: Binding(
                                    get: { self.vitalReadings.bloodPressureSystolic ?? 0 },
                                    set: { self.vitalReadings.bloodPressureSystolic = $0 }
                                ),
                                diastolic: Binding(
                                    get: { self.vitalReadings.bloodPressureDiastolic ?? 0 },
                                    set: { self.vitalReadings.bloodPressureDiastolic = $0 }
                                ),
                                currentPage: $currentStep,
                                selectedTab: $selectedTab
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
        }
        .onAppear {
            // Reset the state when the view appears
            currentStep = 1
            vitalReadings = VitalReadings()
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
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When did you take these readings?")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            DatePicker("Select Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
            
            Text("Select the date and time when you measured your vitals.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Next button
            Button(action: {
                currentPage += 1
            }) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(16)
            }
            .padding()
        }
        .padding(.vertical)
    }
}

struct HeartRateView: View {
    @Binding var heartRate: Double
    @State private var currentStep = 1
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Step indicator
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < currentStep ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal)
            
            // Step content
            VStack(alignment: .leading, spacing: 20) {
                switch currentStep {
                case 1:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1: Find Your Pulse")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Place your index and middle fingers on your wrist, just below the base of your thumb.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 2:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 2: Count Your Beats")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Image(systemName: "timer")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Count the number of beats you feel for 60 seconds, or count for 30 seconds and multiply by 2.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 3:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 3: Enter Your Reading")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        HStack {
                            TextField("BPM", value: $heartRate, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            Text("BPM")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        
                        Text("Enter the number of beats per minute (BPM) you counted.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                default:
                    EmptyView()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 3)
            .padding(.horizontal)
            
            // Navigation buttons
            HStack {
                if currentStep > 1 {
                    Button(action: { currentStep -= 1 }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                Button(action: {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        currentPage += 1
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .padding(.vertical)
    }
}

struct OxygenLevelView: View {
    @Binding var oxygenLevel: Double
    @State private var currentStep = 1
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Oxygen Level")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Step indicator
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal)
            
            // Step content
            VStack(alignment: .leading, spacing: 20) {
                switch currentStep {
                case 1:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1: Prepare Your Device")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Image(systemName: "pulseoximeter")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Make sure your pulse oximeter is clean and has fresh batteries.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 2:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 2: Position Your Finger")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Place your finger in the device and keep it still. Wait for the reading to stabilize.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 3:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 3: Record Your Reading")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 15)
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(min(oxygenLevel / 100, 1)))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                            
                            TextField("", value: $oxygenLevel, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                                .font(.system(size: 40, weight: .bold))
                            
                            Text("%")
                                .font(.title)
                                .foregroundColor(.blue)
                                .offset(x: 50)
                        }
                        .padding()
                        
                        Text("Enter the oxygen saturation percentage shown on your device.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                default:
                    EmptyView()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 3)
            .padding(.horizontal)
            
            // Navigation buttons
            HStack {
                if currentStep > 1 {
                    Button(action: { currentStep -= 1 }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                Button(action: {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        currentPage += 1
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .padding(.vertical)
    }
}

struct BloodPressureView: View {
    @Binding var systolic: Double
    @Binding var diastolic: Double
    @State private var currentStep = 1
    @Binding var currentPage: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Blood Pressure")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Step indicator
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < currentStep ? Color.purple : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal)
            
            // Step content
            VStack(alignment: .leading, spacing: 20) {
                switch currentStep {
                case 1:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1: Prepare Your Cuff")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Image(systemName: "bandage.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Sit quietly for 5 minutes before measuring. Make sure your cuff is properly sized and positioned.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 2:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 2: Position Yourself")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Image(systemName: "figure.stand")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        
                        Text("Sit with your back supported, feet flat on the floor, and arm supported at heart level.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                case 3:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 3: Record Your Reading")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 20) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 50))
                            
                            HStack(spacing: 20) {
                                VStack {
                                    TextField("Systolic", value: $systolic, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                    Text("Systolic")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                                
                                Text("/")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                
                                VStack {
                                    TextField("Diastolic", value: $diastolic, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                    Text("Diastolic")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                                
                                Text("mmHg")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        
                        Text("Enter both numbers from your blood pressure reading.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                default:
                    EmptyView()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 3)
            .padding(.horizontal)
            
            // Navigation buttons
            HStack {
                if currentStep > 1 {
                    Button(action: { currentStep -= 1 }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                Button(action: {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        // Save vitals and navigate to Trends
                        Task {
                            await saveVitals()
                            selectedTab = 1 // Switch to Trends tab
                        }
                    }
                }) {
                    HStack {
                        Text(currentStep == 3 ? "Done" : "Next")
                        if currentStep < 3 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .padding(.vertical)
    }
    
    private func saveVitals() async {
        // Implement saving logic here
        // This should match the saveVitals function from LogVitalsView
    }
} 