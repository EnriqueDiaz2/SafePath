import SwiftUI

// MARK: - Vista de Login con Onboarding integrado
struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentScreen: LoginScreen = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    // Estados para configuración
    @State private var enableNotifications = true
    @State private var enableLocation = true
    @State private var shareLocation = false
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .welcome:
                WelcomeScreenView(currentScreen: $currentScreen)
                    .transition(.opacity)
            case .tutorial:
                TutorialScreenView(currentScreen: $currentScreen)
                    .transition(.opacity)
            case .settings:
                SettingsScreenView(
                    currentScreen: $currentScreen,
                    enableNotifications: $enableNotifications,
                    enableLocation: $enableLocation,
                    shareLocation: $shareLocation
                )
                .transition(.opacity)
            case .login:
                LoginScreenView(
                    currentScreen: $currentScreen,
                    email: $email,
                    password: $password,
                    isLoading: $isLoading,
                    authManager: authManager
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}

// MARK: - Enum para las pantallas
enum LoginScreen {
    case welcome
    case tutorial
    case settings
    case login
}

// MARK: - Pantalla de Bienvenida
struct WelcomeScreenView: View {
    @Binding var currentScreen: LoginScreen
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
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
                            .foregroundColor(Color(hex: "179757"))
                    }
                }
                
                // Descripción
                Text("Tu seguridad es nuestra prioridad")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Opciones
                if showButtons {
                    VStack(spacing: 20) {
                        // Botón para ir directo al login
                        Button(action: {
                            currentScreen = .login
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.title2)
                                Text("Entrar")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                        
                        // Botón para configuración
                        Button(action: {
                            currentScreen = .settings
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                    .font(.title2)
                                Text("Configuración")
                                    .font(.headline)
                            }
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
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Mostrar los botones después de 2.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showButtons = true
                }
            }
        }
    }
}

// MARK: - Pantalla de Tutorial (Registro)
struct TutorialScreenView: View {
    @Binding var currentScreen: LoginScreen
    @State private var nombre = ""
    @State private var apellidos = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hasDisability = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // Header con logo
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Text("Safe")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        Text("Path")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 40)
                    
                    Text("Crear una cuenta")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Ingresa tu correo electrónico para acceder")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Formulario
                VStack(spacing: 18) {
                    // Nombre
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Nombre")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        TextField("Juan Manuel", text: $nombre)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.words)
                    }
                    
                    // Apellidos
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Apellidos")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        TextField("Gomez Diaz", text: $apellidos)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.words)
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        TextField("juanmanugodi@gmail.com", text: $email)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    // Contraseña
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Contraseña")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        SecureField("juan.g123", text: $password)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Confirmar Contraseña
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Confirmar contraseña")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        SecureField("juan.g123", text: $confirmPassword)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Discapacidad Toggle
                    /*VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Discapacidad")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasDisability)
                                .labelsHidden()
                                .tint(.green)
                        }
                        
                        Text("Solo para personas con discapacidad")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }*/
                    .padding(.top, 5)
                }
                .padding(.horizontal, 30)
                
                // Botón de Registrar
                Button(action: {
                    // Aquí iría la lógica de registro
                    currentScreen = .login
                }) {
                    Text("Registrar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("o")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                
                // Botones alternativos
                VStack(spacing: 12) {
                    // Botón de Google
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Continuar con Google")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Botón de Apple
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.title3)
                            Text("Continuar con Apple")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                
                // Footer
                VStack(spacing: 8) {
                    Text("Al hacer clic en continuar, aceptas nuestros Términos de Servicio / Política de privacidad")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Botón para volver al login
                    Button(action: {
                        currentScreen = .login
                    }) {
                        Text("¿Ya tienes cuenta? Inicia sesión")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var isFormValid: Bool {
        !nombre.isEmpty && 
        !apellidos.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        password.count >= 6 &&
        password == confirmPassword
    }
}

// MARK: - Pantalla de Configuración
struct SettingsScreenView: View {
    @Binding var currentScreen: LoginScreen
    @Binding var enableNotifications: Bool
    @Binding var enableLocation: Bool
    @Binding var shareLocation: Bool
    
    var body: some View {
        ZStack {
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
                
                // Icono
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.orange)
                }
                
                // Título
                Text("Configuración")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // Descripción
                Text("Personaliza tu experiencia")
                    .font(.body)
                    .foregroundColor(.gray)
                
                // Opciones de configuración
                VStack(spacing: 20) {
                    ConfigToggleView(
                        icon: "bell.fill",
                        title: "Notificaciones",
                        description: "Recibe alertas importantes",
                        isOn: $enableNotifications
                    )
                    
                    ConfigToggleView(
                        icon: "location.fill",
                        title: "Ubicación",
                        description: "Permite acceso a tu ubicación",
                        isOn: $enableLocation
                    )
                    
                    ConfigToggleView(
                        icon: "person.2.fill",
                        title: "Compartir ubicación",
                        description: "Con contactos de confianza",
                        isOn: $shareLocation
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Botones
                VStack(spacing: 15) {
                    Button(action: {
                        currentScreen = .login
                    }) {
                        Text("Guardar y comenzar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            currentScreen = .welcome
                        }) {
                            Text("Volver")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        Button(action: {
                            currentScreen = .tutorial
                        }) {
                            Text("Ver tutorial")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Pantalla de Login
struct LoginScreenView: View {
    @Binding var currentScreen: LoginScreen
    @Binding var email: String
    @Binding var password: String
    @Binding var isLoading: Bool
    var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Header con Logo
                    VStack(spacing: 20) {
                        // Icono de la aplicación
                        Image("SafePathLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        // Título de bienvenida
                        VStack(spacing: 8) {
                            Text("Iniciar Sesión")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Ingresa tus credenciales")
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
                            
                            TextField("juanmanugodi@gmail.com", text: $email)
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
                            .background(isFormValid ? Color.green : Color.gray)
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
                        
                        // Opciones adicionales
                        VStack(spacing: 12) {
                            // Botón de Registrarse
                            Button(action: {
                                currentScreen = .tutorial
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Registrarse")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Botón de Demo
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
                            
                            // Botón para volver
                            Button(action: {
                                currentScreen = .welcome
                            }) {
                                Text("← Volver al inicio")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 10)
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
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func loginAction() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            authManager.login(email: email, password: password)
            isLoading = false
        }
    }
    
    private func demoLogin() {
        email = "demo@ejemplo.com"
        password = "demo123"
        loginAction()
    }
}

// MARK: - Componentes auxiliares
struct TutorialItemView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

struct ConfigToggleView: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationManager())
    }
}
