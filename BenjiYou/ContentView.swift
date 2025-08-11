import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Projects Tab
            NavigationView {
                ProjectListView()
            }
            .tabItem {
                Image(systemName: "folder.fill")
                Text("Projets")
            }
            .tag(0)
            
            // Chat Tab
            NavigationView {
                ChatView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chat")
            }
            .tag(1)
            
            // Tasks Tab
            NavigationView {
                TaskListView()
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Tâches")
            }
            .tag(2)
            
            // Users Tab (Admin only)
            if authManager.isAdmin() {
                NavigationView {
                    UserManagementView()
                }
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Utilisateurs")
                }
                .tag(3)
            }
            
            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profil")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
}

// MARK: - Chat View
struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        VStack {
            // Chat header
            HStack {
                Text("Chat Général")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Message input
            HStack {
                TextField("Tapez votre message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            content: messageText,
            senderId: "currentUser",
            senderName: "Vous",
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.senderId == "currentUser" {
                Spacer()
            }
            
            VStack(alignment: message.senderId == "currentUser" ? .trailing : .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.content)
                    .padding(12)
                    .background(
                        message.senderId == "currentUser" ? Color.blue : Color.gray.opacity(0.2)
                    )
                    .foregroundColor(message.senderId == "currentUser" ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.senderId != "currentUser" {
                Spacer()
            }
        }
    }
}

// MARK: - Task List View
struct TaskListView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Mes Tâches")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Tasks list
            if tasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Aucune tâche pour le moment")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Créez votre première tâche pour commencer")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                List(tasks) { task in
                    TaskRowView(task: task)
                }
            }
        }
        .navigationTitle("Tâches")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                StatusBadge(status: task.status)
            }
            
            Text(task.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                PriorityBadge(priority: task.priority)
                Spacer()
                if let dueDate = task.dueDate {
                    Text("Échéance: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: Task.TaskStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: Project.ProjectPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priority.color.opacity(0.2))
            .foregroundColor(priority.color)
            .cornerRadius(8)
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Project.ProjectPriority.medium
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails de la tâche") {
                    TextField("Titre", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priorité") {
                    Picker("Priorité", selection: $priority) {
                        ForEach(Project.ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Échéance") {
                    DatePicker("Date d'échéance", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Nouvelle Tâche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        // Add task logic here
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 30) {
            // Profile header
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Text(authManager.currentUser?.avatar ?? "👤")
                        .font(.system(size: 60))
                }
                
                VStack(spacing: 8) {
                    Text(authManager.currentUser?.fullName ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(authManager.currentUser?.username ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(authManager.currentUser?.role.displayName ?? "")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(authManager.currentUser?.role.color.opacity(0.2) ?? Color.gray.opacity(0.2))
                        .foregroundColor(authManager.currentUser?.role.color ?? .gray)
                        .cornerRadius(12)
                }
            }
            
            // Profile options
            VStack(spacing: 16) {
                ProfileOptionRow(icon: "person.circle", title: "Modifier le profil", action: {})
                ProfileOptionRow(icon: "bell", title: "Notifications", action: {})
                ProfileOptionRow(icon: "gear", title: "Paramètres", action: {})
                ProfileOptionRow(icon: "questionmark.circle", title: "Aide", action: {})
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Logout button
            Button(action: {
                authManager.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Se déconnecter")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .cornerRadius(25)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Profile Option Row
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
