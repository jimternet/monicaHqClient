import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var apiURL = ""
    @State private var apiToken = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Monica API Configuration")) {
                    TextField("API URL", text: $apiURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("API Token", text: $apiToken)
                        .textContentType(.password)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: authenticate) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Authenticating...")
                            }
                        } else {
                            Text("Login")
                        }
                    }
                    .disabled(apiURL.isEmpty || apiToken.isEmpty || isLoading)
                }
            }
            .navigationTitle("Monica Login")
        }
    }
    
    private func authenticate() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await authManager.authenticate(apiURL: apiURL, apiToken: apiToken)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}