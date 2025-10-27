import SwiftUI
import CoreData

struct ContactsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var authManager: AuthenticationManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContactEntity.firstName, ascending: true)],
        animation: .default)
    private var contacts: FetchedResults<ContactEntity>
    
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    var filteredContacts: [ContactEntity] {
        if searchText.isEmpty {
            return Array(contacts)
        } else {
            return contacts.filter { contact in
                let fullName = "\(contact.firstName ?? "") \(contact.lastName ?? "")"
                return fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredContacts) { contact in
                    NavigationLink(destination: ContactDetailView(contact: contact)) {
                        ContactRowView(contact: contact)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshContacts) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        authManager.logout()
                    }
                }
            }
            .refreshable {
                await syncContacts()
            }
        }
        .task {
            await syncContacts()
        }
    }
    
    private func refreshContacts() {
        Task {
            isRefreshing = true
            await syncContacts()
            isRefreshing = false
        }
    }
    
    private func syncContacts() async {
        print("🔄 Starting sync from ContactsListView...")
        do {
            try await dataController.syncManager.syncContacts()
            print("✅ Sync completed successfully")
        } catch {
            print("❌ Failed to sync contacts: \(error)")
        }
    }
}

struct ContactRowView: View {
    let contact: ContactEntity
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(contact.initials)
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text(contact.fullName)
                    .font(.headline)
                if let email = contact.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

extension ContactEntity {
    var fullName: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var initials: String {
        let firstInitial = firstName?.first.map(String.init) ?? ""
        let lastInitial = lastName?.first.map(String.init) ?? ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}

#Preview {
    let authManager = AuthenticationManager()
    let dataController = DataController(authManager: authManager)
    
    return ContactsListView()
        .environment(\.managedObjectContext, dataController.container.viewContext)
        .environmentObject(dataController)
        .environmentObject(authManager)
}