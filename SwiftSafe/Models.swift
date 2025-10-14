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
        Place(name: "Restaurante", subtitle: "Comida tradicional mexicana", latitude: 20.6737, longitude: -103.3444, photos: [], reviews: [
            Review(userName: "Juan Pérez", rating: 4.5, comment: "Excelente comida y buen servicio", date: Date())
        ]),
        Place(name: "Hospital Civil", subtitle: "Hospital principal", latitude: 20.6756, longitude: -103.3467, photos: [], reviews: []),
        Place(name: "Catedral de Guadalajara", subtitle: "Lugar histórico", latitude: 20.6778, longitude: -103.3474, photos: [], reviews: [
            Review(userName: "María García", rating: 5.0, comment: "Hermosa arquitectura, un lugar imperdible", date: Date()),
            Review(userName: "Carlos López", rating: 4.0, comment: "Muy bonito lugar, recomendado para turistas", date: Date())
        ])
    ]
    
    // Método para actualizar un lugar
    func updatePlace(_ place: Place) {
        if let index = favoritePlaces.firstIndex(where: { $0.id == place.id }) {
            favoritePlaces[index] = place
        }
    }
    
    // Lista de lugares de interés cercanos (POI - Points of Interest)
    // Estos son lugares que aparecen en el mapa pero no están guardados por el usuario
    @Published var nearbyPlaces: [Place] = [
        Place(name: "Parque Agua Azul", subtitle: "Parque público con áreas verdes", latitude: 20.6690, longitude: -103.3426, photos: [], reviews: []),
        Place(name: "Teatro Degollado", subtitle: "Teatro neoclásico histórico", latitude: 20.6753, longitude: -103.3467, photos: [], reviews: []),
        Place(name: "Mercado Libertad", subtitle: "Mercado tradicional", latitude: 20.6767, longitude: -103.3443, photos: [], reviews: []),
        Place(name: "Plaza de Armas", subtitle: "Plaza central de Guadalajara", latitude: 20.6763, longitude: -103.3476, photos: [], reviews: []),
        Place(name: "Hospicio Cabañas", subtitle: "Patrimonio de la UNESCO", latitude: 20.6783, longitude: -103.3437, photos: [], reviews: []),
        Place(name: "Parque Revolución", subtitle: "Parque urbano con juegos", latitude: 20.6810, longitude: -103.3510, photos: [], reviews: []),
        Place(name: "Biblioteca Iberoamericana", subtitle: "Biblioteca pública", latitude: 20.6720, longitude: -103.3390, photos: [], reviews: []),
        Place(name: "Museo Regional de Guadalajara", subtitle: "Museo de historia", latitude: 20.6745, longitude: -103.3455, photos: [], reviews: []),
        Place(name: "Rotonda de los Jaliscienses Ilustres", subtitle: "Monumento conmemorativo", latitude: 20.6755, longitude: -103.3480, photos: [], reviews: []),
        Place(name: "Plaza Tapatía", subtitle: "Plaza comercial y recreativa", latitude: 20.6770, longitude: -103.3450, photos: [], reviews: [])
    ]
    
    // Obtener todos los lugares (guardados + cercanos) sin duplicados
    var allPlaces: [Place] {
        let savedIds = Set(favoritePlaces.map { $0.id })
        let nearby = nearbyPlaces.filter { !savedIds.contains($0.id) }
        return favoritePlaces + nearby
    }
    
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
    var name: String
    var subtitle: String
    let latitude: Double
    let longitude: Double
    var photos: [String] = [] // Nombres de imágenes o URLs
    var reviews: [Review] = []
    var rating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        return reviews.map { $0.rating }.reduce(0, +) / Double(reviews.count)
    }
}

// MARK: - Modelo de Reseña
/*
 Estructura que representa una reseña de un lugar
*/
struct Review: Identifiable {
    let id = UUID()
    let userName: String
    let rating: Double // De 1 a 5
    let comment: String
    let date: Date
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
