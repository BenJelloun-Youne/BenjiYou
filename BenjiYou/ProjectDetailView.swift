import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @State private var selectedTab = 0
    @State private var showingAddSubProject = false
    @State private var showingAddTask = false
    @State private var selectedSubProject: SubProject?
    
    var body: some View {
        VStack(spacing: 0) {
            // Project header
            VStack(spacing: 16) {
                // Project info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(project.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            StatusBadge(status: project.status)
                            PriorityBadge(priority: project.priority)
                        }
                    }
                    
                    // Project metadata
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Créé le")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(project.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        if let dueDate = project.dueDate {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Échéance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(dueDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sous-projets")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(project.subProjects.count)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
            .background(Color.white)
            
            // Tab selector
            Picker("", selection: $selectedTab) {
                Text("Vue d'ensemble").tag(0)
                Text("Sous-projets").tag(1)
                Text("Tâches").tag(2)
                Text("Équipe").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Tab content
            TabView(selection: $selectedTab) {
                // Overview tab
                ProjectOverviewTab(project: project)
                    .tag(0)
                
                // Sub-projects tab
                SubProjectsTab(
                    project: project,
                    showingAddSubProject: $showingAddSubProject,
                    selectedSubProject: $selectedSubProject
                )
                .tag(1)
                
                // Tasks tab
                ProjectTasksTab(
                    project: project,
                    showingAddTask: $showingAddTask
                )
                .tag(2)
                
                // Team tab
                ProjectTeamTab(project: project)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Détails du projet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddSubProject = true }) {
                        Label("Ajouter un sous-projet", systemImage: "folder.badge.plus")
                    }
                    
                    Button(action: { showingAddTask = true }) {
                        Label("Ajouter une tâche", systemImage: "checklist.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddSubProject) {
            AddSubProjectView(project: project)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskToProjectView(project: project, subProject: selectedSubProject)
        }
    }
}

// MARK: - Project Overview Tab
struct ProjectOverviewTab: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Progression")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: progressPercentage)
                                    .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            
                            Text("Complété")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ProgressRow(title: "Sous-projets", value: project.subProjects.count, total: 5)
                            ProgressRow(title: "Tâches", value: totalTasks, total: 20)
                            ProgressRow(title: "Membres", value: project.assignedUsers.count, total: 8)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Recent activity
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activité récente")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ActivityRow(icon: "folder.fill", title: "Projet créé", time: "Il y a 2 jours")
                        ActivityRow(icon: "person.2.fill", title: "2 membres ajoutés", time: "Il y a 1 jour")
                        ActivityRow(icon: "checkmark.circle.fill", title: "Première tâche terminée", time: "Il y a 3 heures")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private var progressPercentage: Double {
        let completedSubProjects = project.subProjects.filter { $0.status == .completed }.count
        let totalSubProjects = max(project.subProjects.count, 1)
        return Double(completedSubProjects) / Double(totalSubProjects)
    }
    
    private var progressColor: Color {
        if progressPercentage >= 0.8 { return .green }
        if progressPercentage >= 0.5 { return .yellow }
        if progressPercentage >= 0.2 { return .orange }
        return .red
    }
    
    private var totalTasks: Int {
        project.subProjects.reduce(0) { $0 + $1.tasks.count }
    }
}

// MARK: - Progress Row
struct ProgressRow: View {
    let title: String
    let value: Int
    let total: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("\(value)/\(total)")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Sub Projects Tab
struct SubProjectsTab: View {
    let project: Project
    @Binding var showingAddSubProject: Bool
    @Binding var selectedSubProject: SubProject?
    
    var body: some View {
        VStack {
            if project.subProjects.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "folder")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Aucun sous-projet pour le moment")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Créez votre premier sous-projet pour organiser le travail")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showingAddSubProject = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Ajouter un sous-projet")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                }
                .padding()
                Spacer()
            } else {
                List(project.subProjects) { subProject in
                    SubProjectRowView(subProject: subProject)
                        .onTapGesture {
                            selectedSubProject = subProject
                        }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Sub Project Row View
struct SubProjectRowView: View {
    let subProject: SubProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(subProject.name)
                    .font(.headline)
                Spacer()
                StatusBadge(status: subProject.status)
            }
            
            Text(subProject.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                PriorityBadge(priority: subProject.priority)
                Spacer()
                Text("\(subProject.tasks.count) tâches")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Project Tasks Tab
struct ProjectTasksTab: View {
    let project: Project
    @Binding var showingAddTask: Bool
    
    var allTasks: [Task] {
        project.subProjects.flatMap { $0.tasks }
    }
    
    var body: some View {
        VStack {
            if allTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Aucune tâche pour le moment")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Créez des tâches pour organiser le travail")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showingAddTask = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Ajouter une tâche")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                }
                .padding()
                Spacer()
            } else {
                List(allTasks) { task in
                    TaskRowView(task: task)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Project Team Tab
struct ProjectTeamTab: View {
    let project: Project
    
    var body: some View {
        VStack {
            if project.assignedUsers.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Aucun membre assigné")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Ajoutez des membres à votre équipe")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                List(project.assignedUsers, id: \.self) { userId in
                    TeamMemberRow(userId: userId)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Team Member Row
struct TeamMemberRow: View {
    let userId: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("👤")
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Membre \(userId)")
                    .font(.headline)
                Text("Rôle à définir")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "envelope")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Sub Project View
struct AddSubProjectView: View {
    let project: Project
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var status = Project.ProjectStatus.planning
    @State private var priority = Project.ProjectPriority.medium
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails du sous-projet") {
                    TextField("Nom du sous-projet", text: $name)
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
            .navigationTitle("Nouveau Sous-projet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Créer") {
                        // Create sub-project logic here
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Task to Project View
struct AddTaskToProjectView: View {
    let project: Project
    let subProject: SubProject?
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Project.ProjectPriority.medium
    @State private var dueDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails de la tâche") {
                    TextField("Titre de la tâche", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let subProject = subProject {
                    Section("Sous-projet") {
                        Text(subProject.name)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Priorité et échéance") {
                    Picker("Priorité", selection: $priority) {
                        ForEach(Project.ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
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

#Preview {
    NavigationView {
        ProjectDetailView(project: Project(
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
        ))
    }
}
