import SwiftUI

struct UserManagementView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingAddUser = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("", selection: $selectedTab) {
                Text("Utilisateurs").tag(0)
                Text("En attente").tag(1)
                Text("Statistiques").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Tab content
            TabView(selection: $selectedTab) {
                // Users tab
                UsersTab(searchText: $searchText, showingAddUser: $showingAddUser)
                    .tag(0)
                
                // Pending users tab
                PendingUsersTab()
                    .tag(1)
                
                // Statistics tab
                StatisticsTab()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Gestion des Utilisateurs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddUser = true }) {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView()
        }
    }
}

// MARK: - Users Tab
struct UsersTab: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var searchText: String
    @Binding var showingAddUser: Bool
    @State private var selectedRole: User.UserRole? = nil
    @State private var showingUserDetail = false
    @State private var selectedUser: User?
    
    var filteredUsers: [User] {
        var filtered = authManager.getAllUsers()
        
        if !searchText.isEmpty {
            filtered = filtered.filter { user in
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let role = selectedRole {
            filtered = filtered.filter { $0.role == role }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filters
            VStack(spacing: 16) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Rechercher des utilisateurs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Role filter
                HStack {
                    Menu {
                        Button("Tous les rôles") {
                            selectedRole = nil
                        }
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            Button(role.displayName) {
                                selectedRole = role
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedRole?.displayName ?? "Tous les rôles")
                                .foregroundColor(selectedRole != nil ? .blue : .primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Clear filter button
                    if selectedRole != nil {
                        Button("Effacer") {
                            selectedRole = nil
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            // Users list
            if filteredUsers.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(authManager.getAllUsers().isEmpty ? "Aucun utilisateur pour le moment" : "Aucun utilisateur trouvé")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    if authManager.getAllUsers().isEmpty {
                        Text("Ajoutez votre premier utilisateur pour commencer")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Essayez de modifier vos filtres de recherche")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                Spacer()
            } else {
                List(filteredUsers) { user in
                    UserRowView(user: user)
                        .onTapGesture {
                            selectedUser = user
                            showingUserDetail = true
                        }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $showingUserDetail) {
            if let user = selectedUser {
                UserDetailView(user: user)
            }
        }
    }
}

// MARK: - User Row View
struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(user.role.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(user.avatar)
                    .font(.title2)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if user.role == .admin {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Role badge
            VStack(alignment: .trailing, spacing: 8) {
                Text(user.role.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(user.role.color.opacity(0.2))
                    .foregroundColor(user.role.color)
                    .cornerRadius(8)
                
                Text("Membre depuis \(user.createdAt, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Pending Users Tab
struct PendingUsersTab: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            if authManager.getPendingUsers().isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Aucun utilisateur en attente")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Tous les comptes sont approuvés")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                List(authManager.getPendingUsers()) { user in
                    PendingUserRowView(user: user)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Pending User Row View
struct PendingUserRowView: View {
    @EnvironmentObject var authManager: AuthManager
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(user.avatar)
                    .font(.title2)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Demande reçue le \(user.createdAt, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 8) {
                Button(action: {
                    authManager.approveUser(user)
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                
                Button(action: {
                    authManager.rejectUser(user)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Statistics Tab
struct StatisticsTab: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User count cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Utilisateurs",
                        value: "\(authManager.getAllUsers().count)",
                        icon: "person.3.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "En attente",
                        value: "\(authManager.getPendingUsers().count)",
                        icon: "person.badge.clock",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Administrateurs",
                        value: "\(authManager.getAllUsers().filter { $0.role == .admin }.count)",
                        icon: "crown.fill",
                        color: .yellow
                    )
                    
                    StatCard(
                        title: "Gestionnaires",
                        value: "\(authManager.getAllUsers().filter { $0.role == .manager }.count)",
                        icon: "person.2.fill",
                        color: .purple
                    )
                }
                
                // Role distribution chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Répartition par rôles")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            RoleDistributionRow(
                                role: role,
                                count: authManager.getAllUsers().filter { $0.role == role }.count,
                                total: authManager.getAllUsers().count
                            )
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Recent activity
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activité récente")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ActivityRow(icon: "person.badge.plus", title: "Nouveau compte créé", time: "Il y a 2 heures")
                        ActivityRow(icon: "checkmark.circle.fill", title: "Compte approuvé", time: "Il y a 1 jour")
                        ActivityRow(icon: "person.2.fill", title: "Rôle modifié", time: "Il y a 3 jours")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Role Distribution Row
struct RoleDistributionRow: View {
    let role: User.UserRole
    let count: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Text(role.displayName)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(role.color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 60, height: 6)
        }
    }
}

// MARK: - User Detail View
struct UserDetailView: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedRole = User.UserRole.member
    @State private var showingEditRole = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(user.role.color.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Text(user.avatar)
                                .font(.system(size: 60))
                        }
                        
                        VStack(spacing: 8) {
                            Text(user.fullName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("@\(user.username)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text(user.role.displayName)
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(user.role.color.opacity(0.2))
                                .foregroundColor(user.role.color)
                                .cornerRadius(20)
                        }
                    }
                    
                    // User details
                    VStack(spacing: 16) {
                        DetailRow(title: "Email", value: user.email, icon: "envelope.fill")
                        DetailRow(title: "Rôle actuel", value: user.role.displayName, icon: "person.badge.key.fill")
                        DetailRow(title: "Membre depuis", value: user.createdAt.formatted(date: .long, time: .omitted), icon: "calendar")
                        DetailRow(title: "Statut", value: user.isApproved ? "Approuvé" : "En attente", icon: "checkmark.shield.fill")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Actions
                    if authManager.isAdmin() && user.id != authManager.currentUser?.id {
                        VStack(spacing: 12) {
                            Button(action: { showingEditRole = true }) {
                                HStack {
                                    Image(systemName: "person.badge.key")
                                    Text("Modifier le rôle")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                            
                            if user.isApproved {
                                Button(action: {
                                    // Deactivate user logic
                                }) {
                                    HStack {
                                        Image(systemName: "person.slash")
                                        Text("Désactiver l'utilisateur")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red)
                                    .cornerRadius(25)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Détails de l'utilisateur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditRole) {
            EditUserRoleView(user: user, selectedRole: $selectedRole)
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Edit User Role View
struct EditUserRoleView: View {
    let user: User
    @Binding var selectedRole: User.UserRole
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            Form {
                Section("Modifier le rôle") {
                    Picker("Nouveau rôle", selection: $selectedRole) {
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Text("Cette action modifiera les permissions de l'utilisateur dans l'application.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Modifier le rôle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Modifier") {
                        authManager.updateUserRole(user, newRole: selectedRole)
                        dismiss()
                    }
                    .disabled(selectedRole == user.role)
                }
            }
        }
        .onAppear {
            selectedRole = user.role
        }
    }
}

// MARK: - Add User View
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var username = ""
    @State private var fullName = ""
    @State private var role = User.UserRole.member
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'utilisateur") {
                    TextField("Nom complet", text: $fullName)
                    TextField("Nom d'utilisateur", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Rôle et sécurité") {
                    Picker("Rôle", selection: $role) {
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    SecureField("Mot de passe temporaire", text: $password)
                }
                
                Section {
                    Text("L'utilisateur recevra un email avec ses identifiants de connexion.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Nouvel Utilisateur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Créer") {
                        // Create user logic here
                        dismiss()
                    }
                    .disabled(email.isEmpty || username.isEmpty || fullName.isEmpty || password.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        UserManagementView()
            .environmentObject(AuthManager())
    }
}
