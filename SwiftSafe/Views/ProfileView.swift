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
    @State private var showingAbout = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Header del Perfil
                    profileHeader
                    
                    // MARK: - Estadísticas del Usuario
                    userStats
                    
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
                SettingsView()
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
                                colors: [.blue.opacity(0.3), .blue.opacity(0.6)],
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
    private var userStats: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tu Actividad")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                UserStatCard(
                    title: "Lugares\nVisitados",
                    value: "24",
                    icon: "mappin.and.ellipse",
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
    }
    
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
                    icon: "mappin.circle",
                    color: .green
                ) {
                    // Navegar a lugares guardados
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Historial",
                    subtitle: "Ve tu actividad reciente",
                    icon: "clock",
                    color: .orange
                ) {
                    // Mostrar historial
                }
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
                    // Configurar notificaciones
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Privacidad",
                    subtitle: "Controla tu información privada",
                    icon: "lock.shield",
                    color: .blue
                ) {
                    // Configurar privacidad
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Preferencias",
                    subtitle: "Personaliza tu experiencia",
                    icon: "slider.horizontal.3",
                    color: .gray
                ) {
                    showingSettings.toggle()
                }
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
                ProfileOptionRow(
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
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    title: "Acerca de la App",
                    subtitle: "Información sobre la aplicación",
                    icon: "info.circle",
                    color: .gray
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
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Personal") {
                    TextField("Nombre completo", text: $name)
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Biografía") {
                    TextField("Cuéntanos sobre ti...", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Foto de Perfil") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Cambiar foto")
                                .font(.headline)
                            Text("Toca para seleccionar una nueva imagen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Guardar cambios
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            // Cargar datos actuales del usuario
            name = authManager.currentUser?.name ?? ""
            email = authManager.currentUser?.email ?? ""
        }
    }
}

/*
 Vista de información sobre la aplicación
*/
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Logo de la app
                    Image(systemName: "app.badge.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 15) {
                        Text("AppDemo")
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
                            FeatureRow(icon: "person.badge.key", text: "Sistema de autenticación")
                            FeatureRow(icon: "map", text: "Integración con MapKit")
                            FeatureRow(icon: "rectangle.3.group.bubble", text: "Navegación por pestañas")
                            FeatureRow(icon: "person.crop.circle", text: "Gestión de perfil de usuario")
                            FeatureRow(icon: "heart", text: "Sistema de favoritos")
                            FeatureRow(icon: "magnifyingglass", text: "Búsqueda y exploración")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    VStack(spacing: 15) {
                        Text("Desarrollado con")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            TechBadge(name: "SwiftUI", color: .blue)
                            TechBadge(name: "MapKit", color: .green)
                            TechBadge(name: "CoreLocation", color: .orange)
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
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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