import SwiftUI
import FirebaseAuth

struct AuthGateView: View {
    @StateObject private var vm = AuthViewModel()

    var body: some View {
        NavigationStack {
            if let user = vm.user {
                if user.isEmailVerified {
                    // ✅ Usuario verificado → entra a la app
                    MainTabView()
                        .environmentObject(vm)
                } else {
                    // ⏳ Falta verificación
                    VerifyEmailView(vm: vm)
                }
            } else {
                // No autenticado
                AuthTabs(vm: vm)
            }
        }
        .onAppear {
            // Verificar si hay usuario autenticado al iniciar
            if let currentUser = Auth.auth().currentUser {
                vm.user = currentUser
                vm.isVerified = currentUser.isEmailVerified
                vm.email = currentUser.email ?? ""
            }
        }
    }
}

struct AuthTabs: View {
    @ObservedObject var vm: AuthViewModel
    
    var body: some View {
        TabView {
            SignInView(vm: vm)
                .tabItem { Label("Entrar", systemImage: "person.fill.checkmark") }
            
            SignUpView(vm: vm)
                .tabItem { Label("Crear cuenta", systemImage: "person.badge.plus") }
        }
    }
}

#Preview {
    AuthGateView()
}
