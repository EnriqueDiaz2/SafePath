import SwiftUI

// MARK: - Vista Principal con Pestañas Personalizadas
/*
 MainTabView es la vista principal que contiene un TabView personalizado
 con diferentes secciones de la aplicación
*/
struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Estado para controlar qué pestaña está seleccionada
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Contenido de las pestañas
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 1 {
                    MapView()
                } else if selectedTab == 2 {
                    ProfileView()
                }
            }
            
            // TabBar personalizado en la parte inferior
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - TabBar Personalizado
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Línea indicadora superior
            Rectangle()
                .fill(Color.black)
                .frame(height: 4)
                .frame(width: 120)
                .cornerRadius(2)
                .padding(.bottom, 8)
            
            HStack {
                // Botón Inicio
                TabBarButton(
                    icon: "house.fill",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                Spacer()
                
                // Botón Mapa (centro con ícono de ubicación)
                TabBarButton(
                    icon: "mappin.and.ellipse",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                Spacer()
                
                // Botón Perfil
                TabBarButton(
                    icon: "person.fill",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 15)
            .background(
                Color(UIColor.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
        }
    }
}

// MARK: - Botón del TabBar
struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}