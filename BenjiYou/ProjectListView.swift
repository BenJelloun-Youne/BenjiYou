import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var projects: [Project] = []
    @State private var showingAddProject = false
    @State private var searchText = ""
    @State private var selectedStatus: Project.ProjectStatus? = nil
    @State private var selectedPriority: Project.ProjectPriority? = nil
    
    var filteredProjects: [Project] {
        var filtered = projects
        
        if !searchText.isEmpty {
            filtered = filtered.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let status = selectedStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
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
                    
                    TextField("Rechercher des projets...", text: $searchText)
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
                
                // Filters
                HStack(spacing: 12) {
                    // Status filter
                    Menu {
                        Button("Tous les statuts") {
                            selectedStatus = nil
                        }
                        ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
                            Button(status.displayName) {
                                selectedStatus = status
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedStatus?.displayName ?? "Statut")
                                .foregroundColor(selectedStatus != nil ? .blue : .primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Priority filter
                    Menu {
                        Button("Toutes les priorités") {
                            selectedPriority = nil
                        }
                        ForEach(Project.ProjectPriority.allCases, id: \.self) { priority in
                            Button(priority.displayName) {
                                selectedPriority = priority
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPriority?.displayName ?? "Priorité")
                                .foregroundColor(selectedPriority != nil ? .blue : .primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Clear filters button
                    if selectedStatus != nil || selectedPriority != nil {
                        Button("Effacer") {
                            selectedStatus = nil
                            selectedPriority = nil
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            // Projects list
            if filteredProjects.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "folder")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(projects.isEmpty ? "Aucun projet pour le moment" : "Aucun projet trouvé")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    if projects.isEmpty {
                        Text("Créez votre premier projet pour commencer")
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
                List(filteredProjects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectRowView(project: project)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Projets")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddProject = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
        }
        .onAppear {
            loadProjects()
        }
    }
    
    private func loadProjects() {
        // Mock data for demonstration
        projects = [
            Project(
                id: "1",
                name: "Application Mobile BenjiYou",
                description: "Développement d'une application mobile de gestion de projets collaborative",
                status: .inProgress,
                priority: .high,
                assignedUsers: ["user1"],
                subProjects: [],
                createdAt: Date(),
                dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
                createdBy: "admin1"
            ),
            Project(
                id: "2",
                name: "Site Web Corporate",
                description: "Refonte complète du site web de l'entreprise",
                status: .planning,
                priority: .medium,
                assignedUsers: ["user1"],
                subProjects: [],
                createdAt: Date(),
                dueDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                createdBy: "admin1"
            ),
            Project(
                id: "3",
                name: "Système de Gestion des Ventes",
                description: "Mise en place d'un CRM pour la gestion des clients et des ventes",
                status: .completed,
                priority: .critical,
                assignedUsers: ["user1"],
                subProjects: [],
                createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
                dueDate: Date(),
                createdBy: "admin1"
            )
        ]
    }
}

// MARK: - Project Row View
struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(project.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    StatusBadge(status: project.status)
                    PriorityBadge(priority: project.priority)
                }
            }
            
            HStack {
                // Assigned users count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(project.assignedUsers.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Sub-projects count
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(project.subProjects.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Due date
                if let dueDate = project.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Project View
struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var status = Project.ProjectStatus.planning
    @State private var priority = Project.ProjectPriority.medium
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails du projet") {
                    TextField("Nom du projet", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Statut et priorité") {
                    Picker("Statut", selection: $status) {
                        ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
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
            .navigationTitle("Nouveau Projet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Créer") {
                        // Create project logic here
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ProjectListView()
            .environmentObject(AuthManager())
    }
}
