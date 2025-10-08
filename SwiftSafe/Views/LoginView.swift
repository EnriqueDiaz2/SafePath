import SwiftUI

// MARK: - Vista de Inicio de Sesión
/*
 LoginView presenta una interfaz para que el usuario ingrese
 sus credenciales y acceda a la aplicación
*/
struct LoginView: View {
    // Variables de estado para los campos de entrada
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    // Referencia al gestor de autenticación
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Header con Logo
                    VStack(spacing: 20) {
                        // Icono de la aplicación
                        Image(systemName: "app.badge.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        // Título de bienvenida
                        VStack(spacing: 8) {
                            Text("Bienvenido")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Inicia sesión para continuar")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Formulario de Login
                    VStack(spacing: 20) {
                        
                        // Campo de Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correo Electrónico")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("ejemplo@correo.com", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Campo de Contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Ingresa tu contraseña", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Mensaje de error si existe
                        if !authManager.errorMessage.isEmpty {
                            Text(authManager.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Botón de Iniciar Sesión
                        Button(action: loginAction) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isLoading ? "Iniciando sesión..." : "Iniciar Sesión")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isLoading)
                        
                        // Línea divisoria
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("o")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        
                        // Opciones adicionales de login
                        VStack(spacing: 12) {
                            // Botón de Demo (para facilitar las pruebas)
                            Button(action: demoLogin) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("Acceso Demo")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green, lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            
                            // Información sobre el acceso demo
                            Text("Usa el acceso demo para explorar la aplicación")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Propiedades Computadas
    
    /*
     Verifica si el formulario tiene datos válidos
    */
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Métodos
    
    /*
     Acción para iniciar sesión con los datos del formulario
    */
    private func loginAction() {
        isLoading = true
        
        // Simular delay de red
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            authManager.login(email: email, password: password)
            isLoading = false
        }
    }
    
    /*
     Acceso demo con credenciales predefinidas
    */
    private func demoLogin() {
        email = "demo@ejemplo.com"
        password = "demo123"
        loginAction()
    }
}

// MARK: - Preview
/*
 Vista previa para el desarrollo en Xcode
*/
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationManager())
    }
}