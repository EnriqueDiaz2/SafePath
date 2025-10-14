//
//  Inicio1View.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI

struct Inicio1View: View {
    @Binding var showWelcomeScreen: Bool
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            // Fondo con degradado de blanco a verde claro
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "EDFBF3"),
                    Color(hex: "8ED9A4")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image("logo1")
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
                if showButtons {
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Mostrar los botones después de 2.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showButtons = true
                }
            }
        }
    }
}

#Preview {
    Inicio1View(showWelcomeScreen: .constant(false))
}

// MARK: - Extension para usar colores hexadecimales
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
