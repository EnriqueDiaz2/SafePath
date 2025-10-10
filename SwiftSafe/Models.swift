//
//  Models.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Enumeración de rutas de Onboarding
/*
 Define las diferentes pantallas del flujo de onboarding
*/
enum OnboardingPath {
    case inicio1
    case inicio2
    case inicio3
    case inicio4
    case home
}

// MARK: - Gestor de Onboarding
/*
 Clase que maneja el estado del onboarding (pantallas de inicio)
*/
class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentPath: OnboardingPath = .inicio1
    
    init() {
        // Verificar si ya completó el onboarding anteriormente
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentPath = .inicio1
    }
}

// MARK: - Gestor de Autenticación
/*
 AuthenticationManager es una clase que maneja el estado de autenticación
 del usuario. Utiliza @Published para notificar cambios a las vistas.
*/
class AuthenticationManager: ObservableObject {
    // Estado de autenticación - se actualiza automáticamente en la UI
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage = ""
    
    // MARK: - Métodos de Autenticación
    
    /*
     Método para iniciar sesión con email y contraseña
     En una app real, esto haría una llamada a un servidor
    */
    func login(email: String, password: String) {
        // Simulación de validación (en una app real sería más compleja)
        if email.isEmpty || password.isEmpty {
            errorMessage = "Por favor, completa todos los campos"
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Por favor, ingresa un email válido"
            return
        }
        
        // Simulación de login exitoso después de 1 segundo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentUser = User(
                id: UUID(),
                name: "Usuario Demo",
                email: email,
                profileImage: "person.circle.fill"
            )
            self.isAuthenticated = true
            self.errorMessage = ""
        }
    }
    
    /*
     Método para cerrar sesión
    */
    func logout() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = ""
    }
}

// MARK: - Modelo de Usuario
/*
 Estructura que representa la información del usuario
*/
struct User: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let profileImage: String
}

// MARK: - Gestor de Datos de la App
/*
 Clase que maneja los datos generales de la aplicación
*/
class AppDataManager: ObservableObject {
    // Lista de lugares favoritos para mostrar en el mapa
    @Published var favoritePlaces: [Place] = [
        Place(name: "Restaurante", subtitle: "Comida tradicional mexicana", latitude: 20.6737, longitude: -103.3444),
        Place(name: "Hospital Civil", subtitle: "Hospital principal", latitude: 20.6756, longitude: -103.3467),
        Place(name: "Catedral de Guadalajara", subtitle: "Lugar histórico", latitude: 20.6778, longitude: -103.3474)
    ]
    
    // Lista de elementos para la vista principal
    @Published var homeItems: [HomeItem] = [
        HomeItem(title: "Explorar Lugares", subtitle: "Descubre nuevos sitios", icon: "map.fill", color: .blue),
        HomeItem(title: "Perfil", subtitle: "Gestiona tu cuenta", icon: "person.fill", color: .green),
        HomeItem(title: "Configuración", subtitle: "Ajustes de la app", icon: "gear.fill", color: .orange),
        HomeItem(title: "Ayuda", subtitle: "Soporte y preguntas", icon: "questionmark.circle.fill", color: .purple)
    ]
}

// MARK: - Modelo de Lugar
/*
 Estructura que representa un lugar en el mapa
*/
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Modelo de Elemento del Inicio
/*
 Estructura para los elementos de la vista principal
*/
struct HomeItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}
