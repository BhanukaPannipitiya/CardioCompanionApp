import SwiftUI
import MapKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutAlert = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var editedAddress: String = ""
    @State private var editedDateOfBirth: Date = Date()
    @State private var showingDatePicker = false
    @State private var showingCardiacCenterMap = false
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()
    private let apiService = APIService.shared
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // User info
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("Welcome Back,")
                        .foregroundColor(.gray)
                    Text(viewModel.profile?.name ?? "Loading...")
                        .font(.headline)
                    
                    if let postOpDay = viewModel.profile?.postOpDay {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Post-Op Day \(postOpDay)")
                        }
                    }
                }
                
                // Cardiac center locator
                NavigationLink(destination: CardiacCenterMapView(), isActive: $showingCardiacCenterMap) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.red)
                        Text("Locate your nearest cardiac center")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Stats
                HStack(spacing: 20) {
                    StatView(value: "\(viewModel.profile?.streak ?? 0)", label: "Day Streak", color: .green)
                    StatView(value: "\(viewModel.profile?.points ?? 0)", label: "Points", color: .orange)
                }
                
                Button("Redeem Rewards") {
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(Color.blue)
                .cornerRadius(12)
                
                // Profile Form
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Profile")
                            .font(.headline)
                        Spacer()
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                saveProfile()
                            }
                            isEditing.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if isEditing {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Enter full name", text: $editedName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Enter email", text: $editedEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Address")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Enter address", text: $editedAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Date of birth")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack {
                                Text(dateFormatter.string(from: editedDateOfBirth))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button(action: {
                                    showingDatePicker.toggle()
                                }) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            if showingDatePicker {
                                DatePicker(
                                    "Select Date of Birth",
                                    selection: $editedDateOfBirth,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                    } else {
                        ProfileField(label: "Full Name", value: viewModel.profile?.name ?? "Not set")
                        ProfileField(label: "Email", value: viewModel.profile?.email ?? "Not set")
                        ProfileField(label: "Address", value: viewModel.profile?.address ?? "Not set")
                        ProfileField(label: "Date of birth", value: formatDateOfBirth(viewModel.profile?.dateOfBirth))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Premium Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Cardio Companion Premium")
                            .font(.headline)
                    }
                    
                    VStack(spacing: 12) {
                        PremiumPlanButton(
                            plan: "Monthly",
                            price: "$4.99",
                            tag: "Most Flexible"
                        )
                        
                        PremiumPlanButton(
                            plan: "Yearly",
                            price: "$39.99",
                            tag: "Best Value"
                        )
                    }
                    
                    Text("Premium features include:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("*Apple Health sync")
                        Text("*Detailed trend analysis")
                        Text("*Advanced visualizations")
                        Text("*Reminders with Apple Calendar")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Settings
                VStack(spacing: 24) {
                    Button(action: {
                        // Add help action here
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Help & Support")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Help Cards
                    VStack(spacing: 20) {
                        HelpCard(
                            icon: "heart.text.square.fill",
                            title: "Health Tracking",
                            description: "Learn how to track your heart health metrics and understand your progress",
                            color: .red
                        )
                        
                        HelpCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress Analysis",
                            description: "Understand your health trends and get insights from your data",
                            color: .blue
                        )
                        
                        HelpCard(
                            icon: "bell.badge.fill",
                            title: "Reminders & Alerts",
                            description: "Set up medication reminders and appointment notifications",
                            color: .orange
                        )
                        
                        HelpCard(
                            icon: "person.2.fill",
                            title: "Support Network",
                            description: "Connect with healthcare providers and get professional guidance",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .padding(.vertical)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                apiService.logout()
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .onAppear {
            viewModel.fetchProfile()
        }
        .onChange(of: viewModel.profile) { newProfile in
            if let profile = newProfile {
                editedName = profile.name
                editedEmail = profile.email
                editedAddress = profile.address ?? ""
                if let dob = profile.dateOfBirth, !dob.isEmpty {
                    editedDateOfBirth = dateFormatter.date(from: dob) ?? Date()
                }
            }
        }
    }
    
    private func formatDateOfBirth(_ dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else {
            return "Not set"
        }
        
        if let date = dateFormatter.date(from: dateString) {
            return dateFormatter.string(from: date)
        }
        return dateString
    }
    
    private func saveProfile() {
        let updatedProfile: [String: Any] = [
            "name": editedName,
            "email": editedEmail,
            "address": editedAddress,
            "dateOfBirth": dateFormatter.string(from: editedDateOfBirth)
        ]
        
        apiService.updateUserProfile(profile: updatedProfile) { result in
            switch result {
            case .success:
                print("✅ Profile updated successfully")
                viewModel.fetchProfile()
            case .failure(let error):
                print("❌ Failed to update profile: \(error.localizedDescription)")
            }
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 8)
                .frame(width: 80, height: 80)
            
            VStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ProfileField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
    }
}

struct PremiumPlanButton: View {
    let plan: String
    let price: String
    let tag: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plan)
                    .font(.headline)
                Text(price)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}

struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
} 