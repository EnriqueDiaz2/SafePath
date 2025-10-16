import SwiftUI

struct SignInView: View {
    @ObservedObject var vm: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Iniciar sesión")) {
                TextField("Correo", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Contraseña", text: $vm.password)
                
                if let msg = vm.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                
                Button {
                    Task { await vm.signIn() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Entrar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(vm.email.isEmpty || vm.password.isEmpty || vm.isLoading)
            }
            
            Section {
                Text("Si tu correo **no está verificado**, te pediremos que lo verifiques antes de continuar.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Entrar")
    }
}

#Preview {
    NavigationStack {
        SignInView(vm: AuthViewModel())
    }
}
