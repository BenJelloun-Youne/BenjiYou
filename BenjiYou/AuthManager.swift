import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mock data for demonstration
    private var users: [User] = [
        User(
            id: "admin1",
            email: "admin@benjiyou.com",
            username: "admin",
            fullName: "Administrateur Principal",
            role: .admin,
            isApproved: true,
            avatar: "👑",
            createdAt: Date()
        ),
        User(
            id: "user1",
            email: "user@benjiyou.com",
            username: "user",
            fullName: "Utilisateur Test",
            role: .member,
            isApproved: true,
            avatar: "👤",
            createdAt: Date()
        )
    ]
    
    private var pendingUsers: [User] = []
    
    init() {
        // Check if user is already logged in
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: savedUser) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let user = self.users.first(where: { $0.email == email }) {
                if user.isApproved {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.saveUserToDefaults(user)
                } else {
                    self.errorMessage = "Votre compte n'est pas encore approuvé par un administrateur."
                }
            } else {
                self.errorMessage = "Email ou mot de passe incorrect."
            }
            self.isLoading = false
        }
    }
    
    func register(email: String, username: String, fullName: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Check if email or username already exists
        if users.contains(where: { $0.email == email }) {
            errorMessage = "Cet email est déjà utilisé."
            isLoading = false
            return
        }
        
        if users.contains(where: { $0.username == username }) {
            errorMessage = "Ce nom d'utilisateur est déjà utilisé."
            isLoading = false
            return
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newUser = User(
                id: UUID().uuidString,
                email: email,
                username: username,
                fullName: fullName,
                role: .member,
                isApproved: false,
                avatar: "👤",
                createdAt: Date()
            )
            
            self.pendingUsers.append(newUser)
            self.errorMessage = "Compte créé avec succès ! En attente d'approbation par un administrateur."
            self.isLoading = false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Admin Methods
    
    func approveUser(_ user: User) {
        if let index = pendingUsers.firstIndex(where: { $0.id == user.id }) {
            var approvedUser = user
            approvedUser.isApproved = true
            users.append(approvedUser)
            pendingUsers.remove(at: index)
        }
    }
    
    func rejectUser(_ user: User) {
        pendingUsers.removeAll { $0.id == user.id }
    }
    
    func getPendingUsers() -> [User] {
        return pendingUsers
    }
    
    func getAllUsers() -> [User] {
        return users
    }
    
    func updateUserRole(_ user: User, newRole: User.UserRole) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].role = newRole
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    func isAdmin() -> Bool {
        return currentUser?.role == .admin
    }
    
    func isManager() -> Bool {
        return currentUser?.role == .manager || currentUser?.role == .admin
    }
}
