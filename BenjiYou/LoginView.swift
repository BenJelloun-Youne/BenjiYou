import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var fullName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo and title
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 10)
                            
                            Text("B")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        
                        Text("BenjiYou")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Gestion de projets collaborative")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Form container
                    VStack(spacing: 25) {
                        // Mode toggle
                        Picker("Mode", selection: $isLoginMode) {
                            Text("Connexion").tag(true)
                            Text("Inscription").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            if !isLoginMode {
                                // Username field for registration
                                CustomTextField(
                                    text: $username,
                                    placeholder: "Nom d'utilisateur",
                                    icon: "person.fill"
                                )
                                
                                // Full name field for registration
                                CustomTextField(
                                    text: $fullName,
                                    placeholder: "Nom complet",
                                    icon: "person.text.rectangle"
                                )
                            }
                            
                            // Email field
                            CustomTextField(
                                text: $email,
                                placeholder: "Email",
                                icon: "envelope.fill"
                            )
                            
                            // Password field
                            CustomTextField(
                                text: $password,
                                placeholder: "Mot de passe",
                                icon: "lock.fill",
                                isSecure: true
                            )
                        }
                        .padding(.horizontal)
                        
                        // Action button
                        Button(action: {
                            if isLoginMode {
                                authManager.login(email: email, password: password)
                            } else {
                                authManager.register(
                                    email: email,
                                    username: username,
                                    fullName: fullName,
                                    password: password
                                )
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: isLoginMode ? "arrow.right.circle.fill" : "person.badge.plus")
                                    Text(isLoginMode ? "Se connecter" : "S'inscrire")
                                }
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(radius: 5)
                        }
                        .disabled(authManager.isLoading)
                        .padding(.horizontal)
                        
                        // Error message
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Success message for registration
                        if !isLoginMode && authManager.errorMessage?.contains("succès") == true {
                            Text("Compte créé avec succès ! En attente d'approbation par un administrateur.")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 20)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
