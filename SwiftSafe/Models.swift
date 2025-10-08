//
//  Models.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI
import Foundation
import Combine

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
        Place(name: "Casa", subtitle: "Mi hogar", latitude: 40.7128, longitude: -74.0060),
        Place(name: "Trabajo", subtitle: "Oficina principal", latitude: 40.7589, longitude: -73.9851),
        Place(name: "Parque Central", subtitle: "Lugar favorito para caminar", latitude: 40.7812, longitude: -73.9665)
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
