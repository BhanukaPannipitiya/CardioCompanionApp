import SwiftUI

struct ProfileView: View {
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
                    Text("John Doe")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Post-Op Day 14")
                    }
                }
                
                // Cardiac center locator
                Button(action: {}) {
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
                    StatView(value: "14", label: "Day Streak", color: .green)
                    StatView(value: "450", label: "Points", color: .orange)
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
                        Button("Edit") {
                        }
                        .foregroundColor(.blue)
                    }
                    
                    ProfileField(label: "Username")
                    ProfileField(label: "First Name")
                    ProfileField(label: "Last Name")
                    ProfileField(label: "Email")
                    ProfileField(label: "Address")
                    ProfileField(label: "Date of birth")
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
                VStack(spacing: 0) {
                    SettingsButton(icon: "bell.fill", title: "Notifications")
                    SettingsButton(icon: "gear", title: "Settings")
                    SettingsButton(icon: "questionmark.circle", title: "Help")
                    Button(action: {}) {
                        Text("LogOut")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
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
                .stroke(color, lineWidth: 4)
                .frame(width: 60, height: 60)
            
            VStack {
                Text(value)
                    .font(.title3)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
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

struct SettingsButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .foregroundColor(.primary)
    }
} 