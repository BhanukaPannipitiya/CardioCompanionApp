import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showLogSymptoms = false
    @State private var showLogVitals = false
    
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
            
            Button(action: { showLogSymptoms = true }) {
                Image(systemName: "clipboard.fill")
                Text("Log Symptoms")
            }
            .tabItem {
                Image(systemName: "clipboard.fill")
                Text("Log Symptoms")
            }
            .tag(2)
            
            Button(action: { showLogVitals = true }) {
                Image(systemName: "heart.fill")
                Text("Log Vitals")
            }
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
            LogSymptomsView()
        }
        .sheet(isPresented: $showLogVitals) {
            LogVitalsView()
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
