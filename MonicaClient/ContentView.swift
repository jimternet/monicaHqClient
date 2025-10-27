import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView {
                    ContactsListView()
                        .tabItem {
                            Label("Contacts", systemImage: "person.3")
                        }
                    
                    Text("Settings")
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            } else {
                LoginView()
            }
        }
        .task {
            await authManager.checkAuthenticationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}