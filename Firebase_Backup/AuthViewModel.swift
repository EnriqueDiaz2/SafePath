import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isVerified = false
    @Published var user: User?

    private let db = Firestore.firestore()

    func signUp() async {
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            // Envía correo de verificación
            try await result.user.sendEmailVerification()
            // Crea perfil básico en Firestore (opcional)
            try await createUserProfile(uid: result.user.uid, email: email)
        } catch {
            self.errorMessage = mapAuthError(error)
        }
        isLoading = false
    }

    func resendVerification() async {
        guard let u = Auth.auth().currentUser else { return }
        errorMessage = nil
        isLoading = true
        do {
            try await u.sendEmailVerification()
        } catch {
            self.errorMessage = mapAuthError(error)
        }
        isLoading = false
    }

    func checkVerification() async {
        guard let u = Auth.auth().currentUser else { return }
        do {
            try await u.reload()
            self.isVerified = u.isEmailVerified
            self.user = u
        } catch {
            self.errorMessage = "No se pudo actualizar el estado. Intenta de nuevo."
        }
    }

    func signIn() async {
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isVerified = result.user.isEmailVerified
        } catch {
            self.errorMessage = mapAuthError(error)
        }
        isLoading = false
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
        self.isVerified = false
        self.email = ""
        self.password = ""
    }

    private func createUserProfile(uid: String, email: String) async throws {
        try await db.collection("users").document(uid).setData([
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "role": "user",
            "onboardingCompleted": false
        ], merge: true)
    }

    private func mapAuthError(_ error: Error) -> String {
        let ns = error as NSError
        switch AuthErrorCode.Code(rawValue: ns.code) {
        case .emailAlreadyInUse: return "Ese correo ya está registrado."
        case .invalidEmail: return "Correo inválido."
        case .weakPassword: return "La contraseña es muy débil (usa 8+ caracteres)."
        case .networkError: return "Error de red. Revisa tu conexión."
        case .wrongPassword: return "Contraseña incorrecta."
        case .userNotFound: return "No existe una cuenta con ese correo."
        default: return ns.localizedDescription
        }
    }
}
