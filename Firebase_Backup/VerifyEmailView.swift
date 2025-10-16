import SwiftUI

struct VerifyEmailView: View {
    @ObservedObject var vm: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "envelope.badge")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Verifica tu correo")
                .font(.title)
                .bold()
            
            Text("Te enviamos un enlace a **\(vm.email)**. Abre tu correo y da clic en **Verificar**.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.secondary)

            if let msg = vm.errorMessage {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    Task { await vm.checkVerification() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Ya verifiqué mi correo")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(vm.isLoading)

                Button {
                    Task { await vm.resendVerification() }
                } label: {
                    Text("Reenviar correo de verificación")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(vm.isLoading)

                Button("Cambiar de cuenta") {
                    vm.signOut()
                }
                .foregroundStyle(.gray)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Confirma tu correo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VerifyEmailView(vm: {
            let vm = AuthViewModel()
            vm.email = "usuario@ejemplo.com"
            return vm
        }())
    }
}
