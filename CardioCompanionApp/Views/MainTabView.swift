import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showLogSymptoms = false
    @State private var showLogVitals = false
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            TrendsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Trends")
                }
                .tag(1)
            
            SymptomLogView(userId: authManager.currentUserId ?? "")
                .tabItem {
                    Image(systemName: "clipboard.fill")
                    Text("Log Symptoms")
                }
                .tag(2)
            
            LogVitalsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Log Vitals")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .sheet(isPresented: $showLogSymptoms) {
            SymptomLogView(userId: authManager.currentUserId ?? "")
        }
        .sheet(isPresented: $showLogVitals) {
            LogVitalsView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            // Set tab bar appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .white
            
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
    }
} 
