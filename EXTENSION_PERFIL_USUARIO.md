# 👤 Extensión del Perfil de Usuario

## Modelo de Usuario Completo (Opcional)

Si deseas extender el perfil de usuario con más campos, aquí está la implementación completa:

---

## 📝 Modelo de Usuario

```swift
import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String?
    var photoURL: String?
    var phoneNumber: String?
    var bio: String?
    var role: String // "user", "admin", "moderator"
    var onboardingCompleted: Bool
    var createdAt: Date?
    var lastLoginAt: Date?
    var preferences: UserPreferences?
    
    // Estadísticas del usuario
    var reviewsCount: Int
    var placesReportedCount: Int
    var helpfulVotesReceived: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case photoURL = "photo_url"
        case phoneNumber = "phone_number"
        case bio
        case role
        case onboardingCompleted = "onboarding_completed"
        case createdAt = "created_at"
        case lastLoginAt = "last_login_at"
        case preferences
        case reviewsCount = "reviews_count"
        case placesReportedCount = "places_reported_count"
        case helpfulVotesReceived = "helpful_votes_received"
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String // "es", "en", "pt", etc.
    var mapStyle: String // "standard", "satellite", "hybrid"
    var searchRadius: Double // en kilómetros
    
    enum CodingKeys: String, CodingKey {
        case notificationsEnabled = "notifications_enabled"
        case darkModeEnabled = "dark_mode_enabled"
        case language
        case mapStyle = "map_style"
        case searchRadius = "search_radius"
    }
}

extension UserProfile {
    // Valores por defecto
    static var empty: UserProfile {
        UserProfile(
            email: "",
            role: "user",
            onboardingCompleted: false,
            reviewsCount: 0,
            placesReportedCount: 0,
            helpfulVotesReceived: 0
        )
    }
    
    // Perfil de muestra para previews
    static var sample: UserProfile {
        UserProfile(
            id: "sample123",
            email: "usuario@ejemplo.com",
            displayName: "Juan Pérez",
            photoURL: nil,
            phoneNumber: "+52 33 1234 5678",
            bio: "Usuario activo de SafePath",
            role: "user",
            onboardingCompleted: true,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferences: UserPreferences(
                notificationsEnabled: true,
                darkModeEnabled: false,
                language: "es",
                mapStyle: "standard",
                searchRadius: 5.0
            ),
            reviewsCount: 12,
            placesReportedCount: 5,
            helpfulVotesReceived: 34
        )
    }
}
```

---

## 🔧 AuthViewModel Extendido

```swift
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
    @Published var userProfile: UserProfile?

    private let db = Firestore.firestore()

    // ... métodos anteriores (signUp, signIn, etc.) ...
    
    // NUEVO: Cargar perfil completo desde Firestore
    func loadUserProfile() async {
        guard let uid = user?.uid else { return }
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            self.userProfile = try snapshot.data(as: UserProfile.self)
        } catch {
            print("Error cargando perfil: \(error)")
        }
    }
    
    // NUEVO: Actualizar perfil
    func updateProfile(displayName: String?, photoURL: String?, bio: String?) async {
        guard let uid = user?.uid else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            var updates: [String: Any] = [:]
            if let displayName = displayName {
                updates["display_name"] = displayName
            }
            if let photoURL = photoURL {
                updates["photo_url"] = photoURL
            }
            if let bio = bio {
                updates["bio"] = bio
            }
            
            try await db.collection("users").document(uid).updateData(updates)
            await loadUserProfile() // Recargar perfil actualizado
        } catch {
            errorMessage = "Error actualizando perfil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // NUEVO: Actualizar preferencias
    func updatePreferences(_ preferences: UserPreferences) async {
        guard let uid = user?.uid else { return }
        
        do {
            try await db.collection("users").document(uid).updateData([
                "preferences": try Firestore.Encoder().encode(preferences)
            ])
            await loadUserProfile()
        } catch {
            errorMessage = "Error actualizando preferencias: \(error.localizedDescription)"
        }
    }
    
    // NUEVO: Crear perfil completo al registrar
    private func createUserProfile(uid: String, email: String) async throws {
        let profile = UserProfile(
            id: uid,
            email: email,
            role: "user",
            onboardingCompleted: false,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferences: UserPreferences(
                notificationsEnabled: true,
                darkModeEnabled: false,
                language: "es",
                mapStyle: "standard",
                searchRadius: 5.0
            ),
            reviewsCount: 0,
            placesReportedCount: 0,
            helpfulVotesReceived: 0
        )
        
        try await db.collection("users").document(uid).setData([
            "email": email,
            "role": "user",
            "onboarding_completed": false,
            "created_at": FieldValue.serverTimestamp(),
            "last_login_at": FieldValue.serverTimestamp(),
            "preferences": [
                "notifications_enabled": true,
                "dark_mode_enabled": false,
                "language": "es",
                "map_style": "standard",
                "search_radius": 5.0
            ],
            "reviews_count": 0,
            "places_reported_count": 0,
            "helpful_votes_received": 0
        ])
    }
    
    // NUEVO: Actualizar último login
    func updateLastLogin() async {
        guard let uid = user?.uid else { return }
        try? await db.collection("users").document(uid).updateData([
            "last_login_at": FieldValue.serverTimestamp()
        ])
    }
}
```

---

## 🎨 Vista de Edición de Perfil

```swift
import SwiftUI

struct EditProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Personal") {
                    TextField("Nombre completo", text: $displayName)
                    
                    VStack(alignment: .leading) {
                        Text("Biografía")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $bio)
                            .frame(height: 100)
                    }
                }
                
                Section("Foto de Perfil") {
                    HStack {
                        if let photoURL = authVM.userProfile?.photoURL {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Button("Cambiar foto") {
                            showImagePicker = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section("Estadísticas") {
                    LabeledContent("Reseñas publicadas", 
                                 value: "\(authVM.userProfile?.reviewsCount ?? 0)")
                    LabeledContent("Lugares reportados", 
                                 value: "\(authVM.userProfile?.placesReportedCount ?? 0)")
                    LabeledContent("Votos útiles recibidos", 
                                 value: "\(authVM.userProfile?.helpfulVotesReceived ?? 0)")
                }
                .foregroundStyle(.secondary)
                
                if let error = authVM.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            await authVM.updateProfile(
                                displayName: displayName.isEmpty ? nil : displayName,
                                photoURL: nil,
                                bio: bio.isEmpty ? nil : bio
                            )
                            if authVM.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(authVM.isLoading)
                }
            }
            .onAppear {
                displayName = authVM.userProfile?.displayName ?? ""
                bio = authVM.userProfile?.bio ?? ""
            }
        }
    }
}
```

---

## ⚙️ Vista de Preferencias

```swift
import SwiftUI

struct PreferencesView: View {
    @ObservedObject var authVM: AuthViewModel
    
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var language = "es"
    @State private var mapStyle = "standard"
    @State private var searchRadius = 5.0
    
    var body: some View {
        Form {
            Section("Notificaciones") {
                Toggle("Habilitar notificaciones", isOn: $notificationsEnabled)
            }
            
            Section("Apariencia") {
                Toggle("Modo oscuro", isOn: $darkModeEnabled)
            }
            
            Section("Idioma") {
                Picker("Idioma", selection: $language) {
                    Text("🇲🇽 Español").tag("es")
                    Text("🇺🇸 English").tag("en")
                    Text("🇧🇷 Português").tag("pt")
                }
            }
            
            Section("Mapa") {
                Picker("Estilo de mapa", selection: $mapStyle) {
                    Text("Estándar").tag("standard")
                    Text("Satélite").tag("satellite")
                    Text("Híbrido").tag("hybrid")
                }
                
                VStack(alignment: .leading) {
                    Text("Radio de búsqueda: \(Int(searchRadius)) km")
                    Slider(value: $searchRadius, in: 1...20, step: 1)
                }
            }
            
            Section {
                Button("Guardar cambios") {
                    Task {
                        let preferences = UserPreferences(
                            notificationsEnabled: notificationsEnabled,
                            darkModeEnabled: darkModeEnabled,
                            language: language,
                            mapStyle: mapStyle,
                            searchRadius: searchRadius
                        )
                        await authVM.updatePreferences(preferences)
                    }
                }
            }
        }
        .navigationTitle("Preferencias")
        .onAppear {
            if let prefs = authVM.userProfile?.preferences {
                notificationsEnabled = prefs.notificationsEnabled
                darkModeEnabled = prefs.darkModeEnabled
                language = prefs.language
                mapStyle = prefs.mapStyle
                searchRadius = prefs.searchRadius
            }
        }
    }
}
```

---

## 🎯 ProfileView Mejorado

```swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showEditProfile = false
    @State private var showPreferences = false
    
    var body: some View {
        NavigationStack {
            List {
                // Header con foto y nombre
                Section {
                    HStack(spacing: 16) {
                        if let photoURL = authVM.userProfile?.photoURL {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authVM.userProfile?.displayName ?? "Usuario")
                                .font(.title2)
                                .bold()
                            
                            Text(authVM.userProfile?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let bio = authVM.userProfile?.bio {
                                Text(bio)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Estadísticas
                Section("Estadísticas") {
                    HStack {
                        StatItem(
                            icon: "star.fill",
                            value: authVM.userProfile?.reviewsCount ?? 0,
                            label: "Reseñas"
                        )
                        
                        Divider()
                        
                        StatItem(
                            icon: "mappin.circle.fill",
                            value: authVM.userProfile?.placesReportedCount ?? 0,
                            label: "Lugares"
                        )
                        
                        Divider()
                        
                        StatItem(
                            icon: "hand.thumbsup.fill",
                            value: authVM.userProfile?.helpfulVotesReceived ?? 0,
                            label: "Votos útiles"
                        )
                    }
                }
                
                // Acciones
                Section {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Editar perfil", systemImage: "person.crop.circle")
                    }
                    
                    Button {
                        showPreferences = true
                    } label: {
                        Label("Preferencias", systemImage: "gearshape")
                    }
                }
                
                // Cerrar sesión
                Section {
                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Label("Cerrar sesión", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Mi Perfil")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(authVM: authVM)
            }
            .sheet(isPresented: $showPreferences) {
                NavigationStack {
                    PreferencesView(authVM: authVM)
                }
            }
            .task {
                await authVM.loadUserProfile()
            }
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text("\(value)")
                .font(.title3)
                .bold()
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environmentObject({
            let vm = AuthViewModel()
            vm.userProfile = .sample
            return vm
        }())
}
```

---

## 📊 Estructura en Firestore

```json
{
  "users": {
    "uid_del_usuario": {
      "email": "usuario@ejemplo.com",
      "display_name": "Juan Pérez",
      "photo_url": "https://...",
      "phone_number": "+52 33 1234 5678",
      "bio": "Usuario activo de SafePath",
      "role": "user",
      "onboarding_completed": true,
      "created_at": Timestamp,
      "last_login_at": Timestamp,
      "preferences": {
        "notifications_enabled": true,
        "dark_mode_enabled": false,
        "language": "es",
        "map_style": "standard",
        "search_radius": 5.0
      },
      "reviews_count": 12,
      "places_reported_count": 5,
      "helpful_votes_received": 34
    }
  }
}
```

---

## 🔧 Uso en la App

### 1. Actualizar MainTabView

```swift
MainTabView()
    .environmentObject(authVM)
    .task {
        await authVM.loadUserProfile()
        await authVM.updateLastLogin()
    }
```

### 2. Acceder al perfil desde cualquier vista

```swift
@EnvironmentObject var authVM: AuthViewModel

Text("Hola, \(authVM.userProfile?.displayName ?? "Usuario")")
```

---

## ✅ Checklist de Implementación

- [ ] Crear archivo `UserProfile.swift` con los modelos
- [ ] Actualizar `AuthViewModel.swift` con los nuevos métodos
- [ ] Crear `EditProfileView.swift`
- [ ] Crear `PreferencesView.swift`
- [ ] Actualizar `ProfileView.swift`
- [ ] Probar edición de perfil
- [ ] Probar cambio de preferencias
- [ ] Verificar datos en Firestore

---

**✨ ¡Perfil de usuario completo implementado!**

Ahora los usuarios pueden personalizar su experiencia en SafePath. 🎉
