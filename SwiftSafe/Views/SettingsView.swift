import SwiftUI

// MARK: - Vista de Configuración
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Cuenta") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(authManager.currentUser?.name ?? "Usuario")
                                .font(.headline)
                            Text(authManager.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section("Preferencias") {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                                .frame(width: 25)
                            Text("Notificaciones")
                        }
                    }
                    
                    Toggle(isOn: $locationEnabled) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                                .frame(width: 25)
                            Text("Ubicación")
                        }
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                                .frame(width: 25)
                            Text("Modo Oscuro")
                        }
                    }
                }
                
                Section("Privacidad y Seguridad") {
                    SettingRow(title: "Privacidad", icon: "lock.fill", color: .blue)
                    SettingRow(title: "Seguridad", icon: "shield.fill", color: .green)
                    SettingRow(title: "Datos y Almacenamiento", icon: "internaldrive.fill", color: .orange)
                }
                
                Section("Soporte") {
                    SettingRow(title: "Ayuda", icon: "questionmark.circle.fill", color: .purple)
                    SettingRow(title: "Contacto", icon: "envelope.fill", color: .gray)
                    SettingRow(title: "Términos y Condiciones", icon: "doc.text.fill", color: .blue)
                }
                
                Section {
                    Button(action: {
                        authManager.logout()
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Cerrar Sesión")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Fila de Configuración
struct SettingRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationManager())
    }
}
