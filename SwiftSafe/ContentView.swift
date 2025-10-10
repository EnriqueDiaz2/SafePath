//
//  ContentView.swift
//  SwiftSafe
//
//  Created by Mac OS lab on 08/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("Logo2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipped()
            
            VStack(spacing: 10) {
                Text("SwiftSafe")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Tu seguridad en cada ruta")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    // Acción principal
                }) {
                    Text("Comenzar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    // Ver mapa
                }) {
                    Text("Ver Mapa")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ContentView()
}
