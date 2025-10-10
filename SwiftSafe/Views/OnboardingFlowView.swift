//
//  OnboardingFlowView.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var showWelcomeScreen = false
    
    var body: some View {
        ZStack {
            if !showWelcomeScreen {
                // Inicio1: Pantalla con solo el logo
                Inicio1View(showWelcomeScreen: $showWelcomeScreen)
                    .transition(.opacity)
            } else {
                // Marca el onboarding como completado y muestra LoginView
                Color.clear
                    .onAppear {
                        onboardingManager.completeOnboarding()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showWelcomeScreen)
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(OnboardingManager())
}
