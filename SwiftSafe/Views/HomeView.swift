import SwiftUI

// MARK: - Vista de Inicio
/*
 HomeView es la vista principal que se muestra cuando el usuario
 accede a la aplicación. Contiene una lista de funciones principales
 y accesos rápidos a diferentes secciones.
*/
struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appDataManager: AppDataManager
    
    // Estado para controlar la navegación
    @State private var showingSettings = false
    @State private var showingNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - Header de Bienvenida
                    welcomeHeader
                    
                    // MARK: - Tarjetas de Acceso Rápido
                    quickAccessSection
                    
                    // MARK: - Estadísticas
                    statisticsSection
                    
                    // MARK: - Lugares Recientes
                    recentPlacesSection
                    
                    // MARK: - Acciones Rápidas
                    quickActionsSection
                    
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                // Simular actualización de datos
                await refreshData()
            }
        }
    }
    
    // MARK: - Componentes de la Vista
    
    /*
     Header de bienvenida con información del usuario
    */
    private var welcomeHeader: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("¡Hola de nuevo!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(authManager.currentUser?.name ?? "Usuario")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Botón de notificaciones
                Button(action: { showingNotifications.toggle() }) {
                    ZStack {
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        // Indicador de notificaciones nuevas
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 8, y: -8)
                    }
                }
                .sheet(isPresented: $showingNotifications) {
                    NotificationsView()
                }
            }
            
            // Mensaje del día o información relevante
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                
                Text("Es un gran día para explorar nuevos lugares")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    /*
     Sección de acceso rápido a funciones principales
    */
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Acceso Rápido")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(appDataManager.homeItems) { item in
                    QuickAccessCard(item: item)
                }
            }
        }
    }
    
    /*
     Sección de estadísticas del usuario
    */
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tus Estadísticas")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Lugares Visitados",
                    value: "24",
                    icon: "mappin.and.ellipse",
                    color: .blue
                )
                
                StatCard(
                    title: "Favoritos",
                    value: "\(appDataManager.favoritePlaces.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Reseñas",
                    value: "12",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }
    
    /*
     Sección de lugares visitados recientemente
    */
    private var recentPlacesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Lugares Recientes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Ver todos") {
                    // Navegar a la vista completa de lugares
                }
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(appDataManager.favoritePlaces.prefix(3)) { place in
                        RecentPlaceCard(place: place)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    /*
     Sección de acciones rápidas
    */
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Acciones Rápidas")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                QuickActionRow(
                    title: "Buscar lugar cercano",
                    subtitle: "Encuentra lugares interesantes cerca de ti",
                    icon: "location.magnifyingglass",
                    color: .green
                ) {
                    // Acción de búsqueda
                }
                
                QuickActionRow(
                    title: "Compartir ubicación",
                    subtitle: "Comparte tu ubicación actual con amigos",
                    icon: "square.and.arrow.up",
                    color: .purple
                ) {
                    // Acción de compartir
                }
                
                QuickActionRow(
                    title: "Configuración",
                    subtitle: "Ajusta las preferencias de la aplicación",
                    icon: "gear",
                    color: .gray
                ) {
                    showingSettings.toggle()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Métodos
    
    /*
     Simula la actualización de datos
    */
    private func refreshData() async {
        // Simular delay de red
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // En una app real, aquí se actualizarían los datos desde el servidor
        print("Datos actualizados")
    }
}

// MARK: - Componentes Auxiliares

/*
 Tarjeta de acceso rápido
*/
struct QuickAccessCard: View {
    let item: HomeItem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 30))
                .foregroundColor(item.color)
            
            VStack(spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

/*
 Tarjeta de estadística
*/
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/*
 Tarjeta de lugar reciente
*/
struct RecentPlaceCard: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 80)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(place.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 140)
    }
}

/*
 Fila de acción rápida
*/
struct QuickActionRow: View {
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
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vistas Auxiliares

/*
 Vista de notificaciones
*/
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Text("No tienes notificaciones nuevas")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Notificaciones")
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
 Vista de configuración
*/
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Cuenta") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(authManager.currentUser?.name ?? "Usuario")
                                .font(.headline)
                            Text(authManager.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section("Configuración") {
                    SettingRow(title: "Notificaciones", icon: "bell", color: .orange)
                    SettingRow(title: "Privacidad", icon: "lock", color: .blue)
                    SettingRow(title: "Ubicación", icon: "location", color: .green)
                }
                
                Section("Soporte") {
                    SettingRow(title: "Ayuda", icon: "questionmark.circle", color: .purple)
                    SettingRow(title: "Contacto", icon: "envelope", color: .gray)
                }
                
                Section {
                    Button(action: {
                        authManager.logout()
                        dismiss()
                    }) {
                        Text("Cerrar Sesión")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Configuración")
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
 Fila de configuración
*/
struct SettingRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}
