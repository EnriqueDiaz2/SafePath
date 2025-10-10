//
//  Inicio1View.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI

struct Inicio1View: View {
    @Binding var showWelcomeScreen: Bool
    
    var body: some View {
        ZStack {
            // Fondo con el color de la app
            Color(red: 0.8, green: 0.95, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image("fondo_sin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Título
                VStack(spacing: 10) {
                    Text("Bienvenido a")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 5) {
                        Text("Safe")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                        Text("Path")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                
                // Descripción
                Text("Tu seguridad es nuestra prioridad")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Botón para continuar
                Button(action: {
                    withAnimation {
                        showWelcomeScreen = true
                    }
                }) {
                    Text("Comenzar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    Inicio1View(showWelcomeScreen: .constant(false))
}
