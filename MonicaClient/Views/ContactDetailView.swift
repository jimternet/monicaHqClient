import SwiftUI

struct ContactDetailView: View {
    let contact: ContactEntity
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(contact.initials)
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        )
                    Spacer()
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    DetailSection(title: "Name") {
                        Text(contact.fullName)
                            .font(.title2)
                    }
                    
                    if let email = contact.email {
                        DetailSection(title: "Email") {
                            Link(email, destination: URL(string: "mailto:\(email)")!)
                        }
                    }
                    
                    if let phone = contact.phone {
                        DetailSection(title: "Phone") {
                            Link(phone, destination: URL(string: "tel:\(phone)")!)
                        }
                    }
                    
                    if let birthdate = contact.birthdate {
                        DetailSection(title: "Birthday") {
                            Text(birthdate, style: .date)
                        }
                    }
                    
                    if let address = contact.address {
                        DetailSection(title: "Address") {
                            Text(address)
                        }
                    }
                    
                    if let company = contact.company {
                        DetailSection(title: "Company") {
                            Text(company)
                        }
                    }
                    
                    if let jobTitle = contact.jobTitle {
                        DetailSection(title: "Job Title") {
                            Text(jobTitle)
                        }
                    }
                    
                    if let notes = contact.notes, !notes.isEmpty {
                        DetailSection(title: "Notes") {
                            Text(notes)
                                .font(.body)
                        }
                    }
                    
                    DetailSection(title: "Last Updated") {
                        if let updatedAt = contact.updatedAt {
                            Text(updatedAt, style: .date)
                                .font(.caption)
                        } else {
                            Text("Never")
                                .font(.caption)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(contact.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            Text("Edit functionality coming soon")
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            content()
        }
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: ContactEntity())
    }
}