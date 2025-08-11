import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    var email: String
    var username: String
    var fullName: String
    var role: UserRole
    var isApproved: Bool
    var avatar: String
    var createdAt: Date
    
    enum UserRole: String, Codable, CaseIterable {
        case admin = "admin"
        case manager = "manager"
        case member = "member"
        
        var displayName: String {
            switch self {
            case .admin: return "Administrateur"
            case .manager: return "Gestionnaire"
            case .member: return "Membre"
            }
        }
        
        var color: Color {
            switch self {
            case .admin: return .red
            case .manager: return .blue
            case .member: return .green
            }
        }
    }
}

// MARK: - Project Model
struct Project: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var status: ProjectStatus
    var priority: ProjectPriority
    var assignedUsers: [String] // User IDs
    var subProjects: [SubProject]
    var createdAt: Date
    var dueDate: Date?
    var createdBy: String // User ID
    
    enum ProjectStatus: String, Codable, CaseIterable {
        case planning = "planning"
        case inProgress = "inProgress"
        case review = "review"
        case completed = "completed"
        case onHold = "onHold"
        
        var displayName: String {
            switch self {
            case .planning: return "Planification"
            case .inProgress: return "En cours"
            case .review: return "En révision"
            case .completed: return "Terminé"
            case .onHold: return "En attente"
            }
        }
        
        var color: Color {
            switch self {
            case .planning: return .orange
            case .inProgress: return .blue
            case .review: return .purple
            case .completed: return .green
            case .onHold: return .gray
            }
        }
    }
    
    enum ProjectPriority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var displayName: String {
            switch self {
            case .low: return "Faible"
            case .medium: return "Moyenne"
            case .high: return "Élevée"
            case .critical: return "Critique"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}

// MARK: - SubProject Model
struct SubProject: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var status: Project.ProjectStatus
    var priority: Project.ProjectPriority
    var assignedUsers: [String]
    var tasks: [Task]
    var createdAt: Date
    var dueDate: Date?
    var createdBy: String
}

// MARK: - Task Model
struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var status: TaskStatus
    var priority: Project.ProjectPriority
    var assignedTo: String? // User ID
    var estimatedHours: Double?
    var actualHours: Double?
    var createdAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var createdBy: String
    
    enum TaskStatus: String, Codable, CaseIterable {
        case todo = "todo"
        case inProgress = "inProgress"
        case review = "review"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .todo: return "À faire"
            case .inProgress: return "En cours"
            case .review: return "En révision"
            case .completed: return "Terminé"
            }
        }
        
        var color: Color {
            switch self {
            case .todo: return .gray
            case .inProgress: return .blue
            case .review: return .purple
            case .completed: return .green
            }
        }
    }
}

// MARK: - Message Model (for chat functionality)
struct Message: Identifiable, Codable {
    let id: String
    var content: String
    var senderId: String
    var senderName: String
    var timestamp: Date
    var projectId: String?
    var subProjectId: String?
}

// MARK: - Notification Model
struct Notification: Identifiable, Codable {
    let id: String
    var title: String
    var message: String
    var type: NotificationType
    var userId: String
    var isRead: Bool
    var createdAt: Date
    var relatedId: String? // Project, Task, or User ID
    
    enum NotificationType: String, Codable {
        case projectAssigned = "projectAssigned"
        case taskAssigned = "taskAssigned"
        case projectUpdated = "projectUpdated"
        case userApproved = "userApproved"
        case deadlineApproaching = "deadlineApproaching"
    }
}
