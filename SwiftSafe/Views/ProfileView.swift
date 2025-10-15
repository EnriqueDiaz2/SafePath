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
                    // Configurar privacidad
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
    
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var hasDisability: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Información Personal
                Section(header: Text("Editar Perfil").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Carlos Rafael", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Apellido")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Gomez Diaz", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biografía")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Apasionado por el fútbol y los deportes en general ⚽️, ¡siempre listo para la emoción del juego!", text: $bio, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Discapacidad:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Toggle("Solo para personas con alguna discapacidad", isOn: $hasDisability)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    
                    Button(action: {
                        // Guardar cambios
                        dismiss()
                    }) {
                        Text("Guardar Cambios")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                
                /*ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Guardar todos los cambios
                        dismiss()
                    }
                    .fontWeight(.bold)
                }*/
            }
        }
        .onAppear {
            // Cargar datos actuales del usuario
            name = authManager.currentUser?.name ?? ""
        }
    }
}

/*
 Vista de notificaciones separada
*/
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Notificaciones - Sociales
    @State private var notifNuevosMensajes: Bool = true
    @State private var notifMenciones: Bool = true
    @State private var notifMeGusta: Bool = true
    
    // Notificaciones - Mapa y reseñas
    @State private var notifActualizacionesMapa: Bool = true
    
    // Notificaciones - Emergencias
    @State private var notifAlertasZona: Bool = true
    
    // Notificaciones - Mundial
    @State private var notifInicioPartidos: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Notificaciones
                Section(header: Text("Notificaciones").font(.headline)) {
                    // Sociales
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sociales")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Toggle("Nuevos mensajes en chats", isOn: $notifNuevosMensajes)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        
                        Toggle("Menciones en conversaciones", isOn: $notifMenciones)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        
                        Toggle("Me gusta en tus comentarios", isOn: $notifMeGusta)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    .padding(.vertical, 4)
                    
                    // Mapa y reseñas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mapa y reseñas")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Toggle("Actualizaciones en puntos del mapa", isOn: $notifActualizacionesMapa)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    .padding(.vertical, 4)
                    
                    // Emergencias
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emergencias")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Toggle("Alertas en tu zona", isOn: $notifAlertasZona)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    .padding(.vertical, 4)
                    
                    // Mundial
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mundial")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Toggle("Inicio de partidos", isOn: $notifInicioPartidos)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        // Guardar cambios de notificaciones
                        dismiss()
                    }) {
                        Text("Guardar Cambios")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                /*ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Guardar todos los cambios
                        dismiss()
                    }
                    .fontWeight(.bold)
                }*/
            }
        }
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
