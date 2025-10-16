import SwiftUI

struct SignUpView: View {
    @ObservedObject var vm: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Crear cuenta")) {
                TextField("Correo", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Contraseña (8+)", text: $vm.password)
                
                if let msg = vm.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                
                Button {
                    Task { await vm.signUp() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Registrarme")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(vm.email.isEmpty || vm.password.count < 8 || vm.isLoading)
            }
            
            Section {
                Text("Te enviaremos un correo para **verificar tu cuenta**. Hasta verificarla, no podrás acceder a SafePath.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Crear cuenta")
    }
}

#Preview {
    NavigationStack {
        SignUpView(vm: AuthViewModel())
    }
}
