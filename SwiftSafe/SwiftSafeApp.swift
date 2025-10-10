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
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appDataManager = AppDataManager()
    
    var body: some Scene {
        WindowGroup {
            // Flujo de la aplicación:
            // 1. Si no completó el onboarding, mostrar pantallas de inicio
            // 2. Si completó el onboarding pero no está autenticado, mostrar login
            // 3. Si está autenticado, mostrar la app principal
            
            if !onboardingManager.hasCompletedOnboarding {
                OnboardingFlowView()
                    .environmentObject(onboardingManager)
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            } else if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(onboardingManager)
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            } else {
                LoginView()
                    .environmentObject(onboardingManager)
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            }
        }
    }
}
