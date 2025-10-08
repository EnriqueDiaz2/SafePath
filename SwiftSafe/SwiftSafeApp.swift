//
//  SwiftSafeApp.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI

@main
struct SwiftSafeApp: App {
    // Crear instancias de los managers globales
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appDataManager = AppDataManager()
    
    var body: some Scene {
        WindowGroup {
            // Decidir qué vista mostrar basado en el estado de autenticación
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            }
        }
    }
}
