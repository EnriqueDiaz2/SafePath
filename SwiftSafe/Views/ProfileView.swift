import SwiftUI

// MARK: - Vista de Perfil
/*
 ProfileView muestra la información del usuario y opciones
 de configuración de la cuenta y preferencias
*/
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appDataManager: AppDataManager
    
    // Estados para controlar la presentación de vistas
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingPrivacy = false
    @State private var showingNotifications = false
    @State private var showingAbout = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Header del Perfil
                    profileHeader
                    
                    // MARK: - Estadísticas del Usuario
                    //userStats
                    
                    // MARK: - Opciones del Perfil
                    profileOptions
                    
                    // MARK: - Configuración
                    settingsSection
                    
                    // MARK: - Información y Soporte
                    supportSection
                    
                    // MARK: - Cerrar Sesión
                    logoutSection
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                NotificationsView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
        }
    }
    
    // MARK: - Componentes de la Vista
    
    /*
     Header con información básica del usuario
    */
    private var profileHeader: some View {
        VStack(spacing: 20) {
            
            // Foto de perfil
            Button(action: { showingEditProfile.toggle() }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "B2EFC0"), Color(hex: "4CE870")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: authManager.currentUser?.profileImage ?? "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    // Indicador de edición
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                        .offset(x: 40, y: 40)
                }
            }
            
            // Información del usuario
            VStack(spacing: 8) {
                Text(authManager.currentUser?.name ?? "Usuario")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authManager.currentUser?.email ?? "usuario@ejemplo.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Badge de usuario
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("Usuario Verificado")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    /*
     Estadísticas del usuario
    */
    /*private var userStats: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tu Actividad")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                UserStatCard(
                    title: "Lugares\nVisitados",
                    value: "24",
                    icon: "map.fill",
                    color: .blue
                )
                
                UserStatCard(
                    title: "Favoritos\nGuardados",
                    value: "\(appDataManager.favoritePlaces.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                UserStatCard(
                    title: "Reseñas\nEscritas",
                    value: "12",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }*/
    
    /*
     Opciones relacionadas con el perfil
    */
    private var profileOptions: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mi Perfil")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                ProfileOptionRow(
                    title: "Editar Perfil",
                    subtitle: "Actualiza tu información personal",
                    icon: "person.crop.circle",
                    color: .blue
                ) {
                    showingEditProfile.toggle()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Mis Lugares",
                    subtitle: "Gestiona tus lugares guardados",
                    icon: "map.circle.fill",
                    color: .green
                ) {
                    // Navegar a lugares guardados
                }
                
                Divider()
                    .padding(.leading, 50)
                
                /*ProfileOptionRow(
                    title: "Historial",
                    subtitle: "Ve tu actividad reciente",
                    icon: "clock",
                    color: .orange
                ) {
                    // Mostrar historial
                }*/
            }
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
    
    /*
     Sección de configuración
    */
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Configuración")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                ProfileOptionRow(
                    title: "Notificaciones",
                    subtitle: "Gestiona tus alertas y avisos",
                    icon: "bell",
                    color: .purple
                ) {
                    showingSettings.toggle()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Privacidad",
                    subtitle: "Controla tu información privada",
                    icon: "shield",
                    color: .blue
                ) {
                    showingPrivacy.toggle()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                /*ProfileOptionRow(
                    title: "Preferencias",
                    subtitle: "Personaliza tu experiencia",
                    icon: "slider.horizontal.3",
                    color: .gray
                ) {
                    showingSettings.toggle()
                }*/
            }
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
    
    /*
     Sección de soporte e información
    */
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Soporte")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                /*ProfileOptionRow(
                    title: "Centro de Ayuda",
                    subtitle: "Encuentra respuestas a tus preguntas",
                    icon: "questionmark.circle",
                    color: .blue
                ) {
                    // Abrir centro de ayuda
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Contactar Soporte",
                    subtitle: "Envía tus comentarios o reporta problemas",
                    icon: "envelope",
                    color: .green
                ) {
                    // Contactar soporte
                }
                
                Divider()
                    .padding(.leading, 50)*/
                
                ProfileOptionRow(
                    title: "Acerca de la App",
                    subtitle: "Información sobre la aplicación",
                    icon: "info.circle",
                    color: .black
                ) {
                    showingAbout.toggle()
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
    
    /*
     Sección para cerrar sesión
    */
    private var logoutSection: some View {
        VStack(spacing: 15) {
            Button(action: { showingLogoutAlert.toggle() }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    Text("Cerrar Sesión")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
            }
            
            Text("Versión 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

// MARK: - Componentes Auxiliares

/*
 Tarjeta de estadística del usuario
*/
struct UserStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

/*
 Fila de opción del perfil
*/
struct ProfileOptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vistas Auxiliares

/*
 Vista para editar el perfil
*/
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userLastName") private var userLastName: String = ""
    @AppStorage("userBio") private var userBio: String = ""
    @AppStorage("userPhone") private var userPhone: String = ""
    @AppStorage("userCity") private var userCity: String = ""
    @AppStorage("userCountry") private var userCountry: String = ""
    @AppStorage("hasDisability") private var hasDisability: Bool = false
    
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var phone: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var disability: Bool = false
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Foto de Perfil
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "B2EFC0"), Color(hex: "4CE870")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 35, y: 35)
                            }
                            
                            Button(action: {
                                // Cambiar foto
                            }) {
                                Text("Cambiar foto de perfil")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        
                        // MARK: - Información Personal
                        VStack(alignment: .leading, spacing: 0) {
                            Text("INFORMACIÓN PERSONAL")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                ProfileTextField(
                                    label: "Nombre",
                                    placeholder: "Tu nombre",
                                    text: $name
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                ProfileTextField(
                                    label: "Apellido",
                                    placeholder: "Tu apellido",
                                    text: $lastName
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                ProfileTextField(
                                    label: "Teléfono",
                                    placeholder: "+52 33 1234 5678",
                                    text: $phone,
                                    keyboardType: .phonePad
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                ProfileTextField(
                                    label: "Email",
                                    placeholder: authManager.currentUser?.email ?? "tu@email.com",
                                    text: .constant(authManager.currentUser?.email ?? ""),
                                    isDisabled: true
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Ubicación
                        VStack(alignment: .leading, spacing: 0) {
                            Text("UBICACIÓN")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                ProfileTextField(
                                    label: "Ciudad",
                                    placeholder: "Guadalajara",
                                    text: $city
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                ProfileTextField(
                                    label: "País",
                                    placeholder: "México",
                                    text: $country
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Biografía
                        VStack(alignment: .leading, spacing: 0) {
                            Text("BIOGRAFÍA")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 8) {
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemBackground))
                                        .frame(minHeight: 100)
                                    
                                    TextEditor(text: $bio)
                                        .padding(8)
                                        .frame(minHeight: 100)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                    
                                    if bio.isEmpty {
                                        Text("Cuéntanos sobre ti...")
                                            .foregroundColor(Color(UIColor.placeholderText))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                Text("\(bio.count)/200 caracteres")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Accesibilidad
                        VStack(alignment: .leading, spacing: 0) {
                            Text("ACCESIBILIDAD")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Tengo alguna discapacidad")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Activar para recibir rutas accesibles")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $disability)
                                        .labelsHidden()
                                        .tint(.green)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Espaciado para el botón
                        Color.clear.frame(height: 100)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Botón de guardar flotante
                VStack {
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Confirmación de guardado
                if showingSaveConfirmation {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Perfil actualizado")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        name = userName
        lastName = userLastName
        bio = userBio
        phone = userPhone
        city = userCity
        country = userCountry
        disability = hasDisability
    }
    
    private func saveChanges() {
        userName = name
        userLastName = lastName
        userBio = bio
        userPhone = phone
        userCity = city
        userCountry = country
        hasDisability = disability
        
        withAnimation {
            showingSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaveConfirmation = false
            }
            dismiss()
        }
    }
}

// MARK: - Campo de texto personalizado para perfil
struct ProfileTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isDisabled: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .font(.body)
                    .disabled(isDisabled)
                    .foregroundColor(isDisabled ? .secondary : .primary)
                    .keyboardType(keyboardType)
            }
            
            if isDisabled {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Vista de Privacidad y Seguridad
struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var showingSaveConfirmation = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Configuraciones de privacidad
    @AppStorage("profileIsPublic") private var profileIsPublic: Bool = true
    @AppStorage("showLocation") private var showLocation: Bool = true
    @AppStorage("allowMessages") private var allowMessages: Bool = true
    @AppStorage("showActivity") private var showActivity: Bool = true
    @AppStorage("twoFactorEnabled") private var twoFactorEnabled: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Cambiar Contraseña
                        VStack(alignment: .leading, spacing: 0) {
                            Text("CAMBIAR CONTRASEÑA")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                // Contraseña actual
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Contraseña actual")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            if showCurrentPassword {
                                                TextField("Ingresa tu contraseña actual", text: $currentPassword)
                                                    .font(.body)
                                                    .autocapitalization(.none)
                                            } else {
                                                SecureField("Ingresa tu contraseña actual", text: $currentPassword)
                                                    .font(.body)
                                            }
                                            
                                            Button(action: {
                                                showCurrentPassword.toggle()
                                            }) {
                                                Image(systemName: showCurrentPassword ? "eye.fill" : "eye.slash.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                
                                Divider().padding(.leading, 20)
                                
                                // Nueva contraseña
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Nueva contraseña")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            if showNewPassword {
                                                TextField("Mínimo 6 caracteres", text: $newPassword)
                                                    .font(.body)
                                                    .autocapitalization(.none)
                                            } else {
                                                SecureField("Mínimo 6 caracteres", text: $newPassword)
                                                    .font(.body)
                                            }
                                            
                                            Button(action: {
                                                showNewPassword.toggle()
                                            }) {
                                                Image(systemName: showNewPassword ? "eye.fill" : "eye.slash.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                
                                Divider().padding(.leading, 20)
                                
                                // Confirmar contraseña
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Confirmar contraseña")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            if showConfirmPassword {
                                                TextField("Repite la nueva contraseña", text: $confirmPassword)
                                                    .font(.body)
                                                    .autocapitalization(.none)
                                            } else {
                                                SecureField("Repite la nueva contraseña", text: $confirmPassword)
                                                    .font(.body)
                                            }
                                            
                                            Button(action: {
                                                showConfirmPassword.toggle()
                                            }) {
                                                Image(systemName: showConfirmPassword ? "eye.fill" : "eye.slash.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // Requisitos de contraseña
                            VStack(alignment: .leading, spacing: 6) {
                                Text("La contraseña debe tener:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                PasswordRequirement(
                                    text: "Mínimo 6 caracteres",
                                    isMet: newPassword.count >= 6
                                )
                                
                                PasswordRequirement(
                                    text: "Las contraseñas coinciden",
                                    isMet: !newPassword.isEmpty && newPassword == confirmPassword
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Botón de cambiar contraseña
                            Button(action: {
                                changePassword()
                            }) {
                                Text("Cambiar Contraseña")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isPasswordValid() ? Color.blue : Color.gray.opacity(0.5))
                                    )
                            }
                            .disabled(!isPasswordValid())
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                        
                        // MARK: - Configuración de Privacidad
                        VStack(alignment: .leading, spacing: 0) {
                            Text("CONFIGURACIÓN DE PRIVACIDAD")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 32)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                PrivacyToggleRow(
                                    title: "Perfil público",
                                    subtitle: "Permite que otros usuarios vean tu perfil",
                                    isOn: $profileIsPublic
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                PrivacyToggleRow(
                                    title: "Compartir ubicación",
                                    subtitle: "Muestra tu ubicación en el mapa",
                                    isOn: $showLocation
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                PrivacyToggleRow(
                                    title: "Permitir mensajes",
                                    subtitle: "Otros usuarios pueden enviarte mensajes",
                                    isOn: $allowMessages
                                )
                                
                                Divider().padding(.leading, 20)
                                
                                PrivacyToggleRow(
                                    title: "Mostrar actividad",
                                    subtitle: "Muestra cuando estás activo",
                                    isOn: $showActivity
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Seguridad
                        VStack(alignment: .leading, spacing: 0) {
                            Text("SEGURIDAD")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 32)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                PrivacyToggleRow(
                                    title: "Autenticación de dos factores",
                                    subtitle: "Agrega una capa extra de seguridad",
                                    isOn: $twoFactorEnabled
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Sesiones Activas
                        VStack(alignment: .leading, spacing: 0) {
                            Text("SESIONES ACTIVAS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 32)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "iphone")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("iPhone actual")
                                            .font(.body)
                                            .fontWeight(.medium)
                                        
                                        Text("Última actividad: Ahora")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Activo")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                .padding(16)
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Espaciado para el botón
                        Color.clear.frame(height: 100)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Botón de guardar flotante
                VStack {
                    Button(action: {
                        savePrivacySettings()
                    }) {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Confirmación de guardado
                if showingSaveConfirmation {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Configuración guardada")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                
                // Error
                if showError {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Privacidad y Seguridad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func isPasswordValid() -> Bool {
        return !currentPassword.isEmpty &&
               !newPassword.isEmpty &&
               !confirmPassword.isEmpty &&
               newPassword.count >= 6 &&
               newPassword == confirmPassword
    }
    
    private func changePassword() {
        guard isPasswordValid() else {
            errorMessage = "Por favor completa todos los campos correctamente"
            withAnimation {
                showError = true
            }
            hideError()
            return
        }
        
        // Aquí implementarías la lógica real de cambio de contraseña
        // Por ahora solo mostramos confirmación
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        
        withAnimation {
            showingSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSaveConfirmation = false
            }
        }
    }
    
    private func savePrivacySettings() {
        withAnimation {
            showingSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaveConfirmation = false
            }
            dismiss()
        }
    }
    
    private func hideError() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showError = false
            }
        }
    }
}

// MARK: - Componente de toggle de privacidad
struct PrivacyToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Componente de requisito de contraseña
struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(isMet ? .green : .secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isMet ? .primary : .secondary)
        }
    }
}

/*
 Vista de notificaciones separada
```
*/
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notifNuevosMensajes") private var notifNuevosMensajes: Bool = true
    @AppStorage("notifMenciones") private var notifMenciones: Bool = true
    @AppStorage("notifMeGusta") private var notifMeGusta: Bool = true
    @AppStorage("notifActualizacionesMapa") private var notifActualizacionesMapa: Bool = true
    @AppStorage("notifAlertasZona") private var notifAlertasZona: Bool = true
    @AppStorage("notifInicioPartidos") private var notifInicioPartidos: Bool = true
    
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notificaciones")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        }
                        
                        // MARK: - Sociales
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Sociales")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 12)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(
                                    title: "Nuevos mensajes en chats",
                                    isOn: $notifNuevosMensajes
                                )
                                
                                Divider()
                                    .padding(.leading, 20)
                                
                                NotificationToggleRow(
                                    title: "Menciones en conversaciones",
                                    isOn: $notifMenciones
                                )
                                
                                Divider()
                                    .padding(.leading, 20)
                                
                                NotificationToggleRow(
                                    title: "Me gusta en tus comentarios",
                                    isOn: $notifMeGusta
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Mapa y reseñas
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Mapa y reseñas")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 12)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(
                                    title: "Actualizaciones en puntos\ndel mapa",
                                    isOn: $notifActualizacionesMapa
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Emergencias
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Emergencias")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 12)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(
                                    title: "Alertas en tu zona",
                                    isOn: $notifAlertasZona
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Mundial
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Mundial")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 12)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(
                                    title: "Inicio de partidos",
                                    isOn: $notifInicioPartidos
                                )
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Espaciado para el botón
                        Color.clear.frame(height: 100)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Botón de guardar flotante
                VStack {
                    Button(action: {
                        withAnimation {
                            showingSaveConfirmation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showingSaveConfirmation = false
                            }
                            dismiss()
                        }
                    }) {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Confirmación de guardado
                if showingSaveConfirmation {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Cambios guardados")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Componente de fila de toggle
struct NotificationToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

/*
 Vista de información sobre la aplicación
*/
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack{
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "EDFBF3"),
                    Color(hex: "8ED9A4")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Logo de la app
                        Image("logo1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 15) {
                            Text("Safe Path")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Versión 1.0.0")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Una aplicación de demostración que muestra las capacidades de SwiftUI incluyendo autenticación, mapas, navegación por pestañas y mucho más.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Características")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                FeatureRow(icon: "person.badge.key.fill", text: "Sistema de autenticación")
                                FeatureRow(icon: "map.fill", text: "Integración con MapKit")
                                FeatureRow(icon: "rectangle.3.group.bubble.fill", text: "Navegación por pestañas")
                                FeatureRow(icon: "person.crop.circle.fill", text: "Gestión de perfil de usuario")
                                FeatureRow(icon: "heart.fill", text: "Sistema de favoritos")
                                FeatureRow(icon: "magnifyingglass", text: "Búsqueda y exploración")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .cornerRadius(15)
                        
                        VStack(spacing: 15) {
                            Text("Desarrollado con")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                TechBadge(name: "SwiftUI", color: .blue)
                                TechBadge(name: "MapKit", color: .red)
                                TechBadge(name: "CoreLocation", color: .orange)
                            }
                            
                            Divider()
                            
                            Text("Desarrollado por")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 15) {
                                TechBadge(name: "Enrique De Jesus Figueroa Diaz", color: .indigo)
                                TechBadge(name: "Diego Miguel Sanchez Cuenca", color: .brown)
                            }
                            
                            HStack(spacing: 15) {
                                TechBadge(name: "Pedro Rafael Mendoza Ruiz", color: .orange)
                                TechBadge(name: "Laura Lizbeth Castro Avila", color: .red)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Acerca de")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

/*
 Fila de característica
*/
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
        }
    }
}

/*
 Badge de tecnología
*/
struct TechBadge: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.footnote)
            .fontWeight(.bold)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}
