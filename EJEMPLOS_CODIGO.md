# 💻 Ejemplos de Código - Extensiones y Personalizaciones

## 📚 Índice
1. [Agregar Más Datos de Ejemplo](#agregar-más-datos-de-ejemplo)
2. [Personalizar Colores](#personalizar-colores)
3. [Agregar Campos a Reseñas](#agregar-campos-a-reseñas)
4. [Filtrar y Ordenar Reseñas](#filtrar-y-ordenar-reseñas)
5. [Editar Reseñas Existentes](#editar-reseñas-existentes)
6. [Eliminar Reseñas](#eliminar-reseñas)
7. [Agregar Validación](#agregar-validación)
8. [Persistencia con UserDefaults](#persistencia-con-userdefaults)

---

## 1. Agregar Más Datos de Ejemplo

### En `Models.swift`, dentro de `AppDataManager`:

```swift
@Published var favoritePlaces: [Place] = [
    // Lugares existentes...
    
    // Nuevo lugar con reseñas
    Place(
        name: "Parque Metropolitano",
        subtitle: "Espacio verde para recreación",
        latitude: 20.6800,
        longitude: -103.3500,
        photos: [],
        reviews: [
            Review(
                userName: "Ana Martínez",
                rating: 5.0,
                comment: "Perfecto para hacer ejercicio y disfrutar la naturaleza",
                date: Date().addingTimeInterval(-86400 * 3) // hace 3 días
            ),
            Review(
                userName: "Pedro Sánchez",
                rating: 4.5,
                comment: "Muy limpio y bien cuidado, ideal para familias",
                date: Date().addingTimeInterval(-86400 * 7) // hace 7 días
            )
        ]
    ),
    
    // Lugar con fotos (simuladas)
    Place(
        name: "Café Literario",
        subtitle: "Cafetería con ambiente cultural",
        latitude: 20.6720,
        longitude: -103.3480,
        photos: ["cafe_1", "cafe_2", "cafe_3"],
        reviews: [
            Review(
                userName: "Laura González",
                rating: 5.0,
                comment: "El mejor café de la ciudad, ambiente acogedor",
                date: Date().addingTimeInterval(-3600 * 5) // hace 5 horas
            )
        ]
    )
]
```

---

## 2. Personalizar Colores

### Crear tu propia paleta de colores:

```swift
// En un archivo nuevo: ColorTheme.swift
extension Color {
    static let customBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let customGreen = Color(red: 0.3, green: 0.7, blue: 0.4)
    static let customOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let cardBackground = Color(UIColor.systemGray6)
}
```

### Usar en `LocationDetailView`:

```swift
Button(action: { showingAddReview = true }) {
    HStack {
        Image(systemName: "star.bubble")
        Text("Agregar Reseña")
    }
    .font(.subheadline)
    .fontWeight(.semibold)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(Color.customBlue) // ← Color personalizado
    .cornerRadius(10)
}
```

---

## 3. Agregar Campos a Reseñas

### Actualizar modelo `Review`:

```swift
struct Review: Identifiable {
    let id = UUID()
    let userName: String
    let rating: Double
    let comment: String
    let date: Date
    
    // Nuevos campos
    var title: String = ""           // Título de la reseña
    var userProfileImage: String?    // Imagen de perfil
    var likeCount: Int = 0           // Número de "me gusta"
    var isVerifiedUser: Bool = false // Usuario verificado
}
```

### Actualizar `AddReviewView`:

```swift
struct AddReviewView: View {
    @Binding var place: Place
    let onSave: (Review) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var userName = "Usuario Actual"
    @State private var rating: Double = 3.0
    @State private var title = ""        // ← Nuevo campo
    @State private var comment = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Sección de título (nueva)
                Section(header: Text("Título")) {
                    TextField("Resume tu experiencia", text: $title)
                }
                
                // Secciones existentes...
                
                Section {
                    Button(action: {
                        let newReview = Review(
                            userName: userName,
                            rating: rating,
                            comment: comment.isEmpty ? "Sin comentarios" : comment,
                            date: Date(),
                            title: title,
                            userProfileImage: nil,
                            likeCount: 0,
                            isVerifiedUser: false
                        )
                        onSave(newReview)
                        dismiss()
                    }) {
                        // Botón de publicar...
                    }
                }
            }
            .navigationTitle("Nueva Reseña")
        }
    }
}
```

### Actualizar `ReviewCard`:

```swift
struct ReviewCard: View {
    let review: Review
    @State private var likes: Int
    
    init(review: Review) {
        self.review = review
        self._likes = State(initialValue: review.likeCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(review.userName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        // Badge de verificado
                        if review.isVerifiedUser {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                Text(formatDate(review.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Título de la reseña (nuevo)
            if !review.title.isEmpty {
                Text(review.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // Comentario
            Text(review.comment)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // Botón de "me gusta" (nuevo)
            HStack {
                Button(action: {
                    likes += 1
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: likes > review.likeCount ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                        Text("\(likes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    // Reportar reseña
                }) {
                    Text("Reportar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
```

---

## 4. Filtrar y Ordenar Reseñas

### Agregar en `LocationDetailView`:

```swift
struct LocationDetailView: View {
    @State var place: Place
    @State private var sortOrder: SortOrder = .newest
    
    enum SortOrder {
        case newest, oldest, highestRating, lowestRating
    }
    
    var sortedReviews: [Review] {
        switch sortOrder {
        case .newest:
            return place.reviews.sorted { $0.date > $1.date }
        case .oldest:
            return place.reviews.sorted { $0.date < $1.date }
        case .highestRating:
            return place.reviews.sorted { $0.rating > $1.rating }
        case .lowestRating:
            return place.reviews.sorted { $0.rating < $1.rating }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Contenido existente...
                    
                    // Sección de reseñas con filtros
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Reseñas")
                                .font(.headline)
                            Spacer()
                            
                            // Menú de ordenamiento
                            Menu {
                                Button("Más recientes") { sortOrder = .newest }
                                Button("Más antiguas") { sortOrder = .oldest }
                                Button("Mejor calificadas") { sortOrder = .highestRating }
                                Button("Peor calificadas") { sortOrder = .lowestRating }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text("Ordenar")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // Mostrar reseñas ordenadas
                        ForEach(sortedReviews) { review in
                            ReviewCard(review: review)
                        }
                    }
                }
            }
        }
    }
}
```

---

## 5. Editar Reseñas Existentes

### Agregar función de edición:

```swift
struct LocationDetailView: View {
    @State var place: Place
    @State private var editingReview: Review?
    @State private var showingEditReview = false
    
    var body: some View {
        // ...
        
        ForEach(place.reviews) { review in
            ReviewCard(review: review, onEdit: {
                editingReview = review
                showingEditReview = true
            })
        }
        
        // ...
        
        .sheet(isPresented: $showingEditReview) {
            if let review = editingReview {
                EditReviewView(review: review) { updatedReview in
                    if let index = place.reviews.firstIndex(where: { $0.id == review.id }) {
                        place.reviews[index] = updatedReview
                        appDataManager.updatePlace(place)
                    }
                }
            }
        }
    }
}

// Nueva vista para editar
struct EditReviewView: View {
    let review: Review
    let onSave: (Review) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Double
    @State private var comment: String
    
    init(review: Review, onSave: @escaping (Review) -> Void) {
        self.review = review
        self.onSave = onSave
        self._rating = State(initialValue: review.rating)
        self._comment = State(initialValue: review.comment)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Similar a AddReviewView pero con datos precargados
                Section(header: Text("Tu Calificación")) {
                    // Selector de estrellas...
                }
                
                Section(header: Text("Tu Reseña")) {
                    TextEditor(text: $comment)
                        .frame(height: 150)
                }
                
                Section {
                    Button("Guardar Cambios") {
                        var updatedReview = review
                        updatedReview.rating = rating
                        updatedReview.comment = comment
                        onSave(updatedReview)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Editar Reseña")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
```

### Actualizar `ReviewCard` con botón de editar:

```swift
struct ReviewCard: View {
    let review: Review
    let onEdit: (() -> Void)?
    
    init(review: Review, onEdit: (() -> Void)? = nil) {
        self.review = review
        self.onEdit = onEdit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Avatar y nombre...
                
                Spacer()
                
                // Botón de editar (solo si es del usuario actual)
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Resto del contenido...
        }
    }
}
```

---

## 6. Eliminar Reseñas

### Agregar función de eliminación:

```swift
struct LocationDetailView: View {
    @State var place: Place
    
    var body: some View {
        // ...
        
        ForEach(place.reviews) { review in
            ReviewCard(review: review, onDelete: {
                deleteReview(review)
            })
        }
    }
    
    private func deleteReview(_ review: Review) {
        // Mostrar alerta de confirmación
        let alert = UIAlertController(
            title: "Eliminar Reseña",
            message: "¿Estás seguro de que quieres eliminar esta reseña?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
            place.reviews.removeAll { $0.id == review.id }
            appDataManager.updatePlace(place)
        })
        
        // Presentar alerta
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}
```

### Con SwiftUI Alert nativo:

```swift
struct LocationDetailView: View {
    @State var place: Place
    @State private var reviewToDelete: Review?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        // ...
        
        ForEach(place.reviews) { review in
            ReviewCard(review: review, onDelete: {
                reviewToDelete = review
                showingDeleteAlert = true
            })
        }
        
        .alert("Eliminar Reseña", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let review = reviewToDelete {
                    place.reviews.removeAll { $0.id == review.id }
                    appDataManager.updatePlace(place)
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta reseña?")
        }
    }
}
```

---

## 7. Agregar Validación

### Validar reseñas antes de guardar:

```swift
struct AddReviewView: View {
    @State private var rating: Double = 3.0
    @State private var comment = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isValid: Bool {
        !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        comment.count >= 10 // Mínimo 10 caracteres
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Secciones existentes...
                
                Section {
                    Button(action: {
                        if validateReview() {
                            saveReview()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Publicar Reseña")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                }
                
                if !isValid && !comment.isEmpty {
                    Section {
                        Text("La reseña debe tener al menos 10 caracteres")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func validateReview() -> Bool {
        // Validar contenido ofensivo
        let prohibitedWords = ["palabra1", "palabra2"]
        for word in prohibitedWords {
            if comment.lowercased().contains(word) {
                errorMessage = "Tu reseña contiene palabras no permitidas"
                showingError = true
                return false
            }
        }
        
        // Validar longitud máxima
        if comment.count > 500 {
            errorMessage = "La reseña no puede tener más de 500 caracteres"
            showingError = true
            return false
        }
        
        return true
    }
    
    private func saveReview() {
        let newReview = Review(
            userName: userName,
            rating: rating,
            comment: comment,
            date: Date()
        )
        onSave(newReview)
        dismiss()
    }
}
```

---

## 8. Persistencia con UserDefaults

### Guardar y cargar lugares con reseñas:

```swift
// En Models.swift, actualizar Place para Codable
struct Place: Identifiable, Codable {
    let id: UUID
    var name: String
    var subtitle: String
    let latitude: Double
    let longitude: Double
    var photos: [String]
    var reviews: [Review]
    
    var rating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        return reviews.map { $0.rating }.reduce(0, +) / Double(reviews.count)
    }
    
    // Necesario para Codable con computed property
    enum CodingKeys: String, CodingKey {
        case id, name, subtitle, latitude, longitude, photos, reviews
    }
}

struct Review: Identifiable, Codable {
    let id: UUID
    let userName: String
    let rating: Double
    let comment: String
    let date: Date
}

// Actualizar AppDataManager
class AppDataManager: ObservableObject {
    @Published var favoritePlaces: [Place] = [] {
        didSet {
            savePlaces()
        }
    }
    
    init() {
        loadPlaces()
    }
    
    private func savePlaces() {
        if let encoded = try? JSONEncoder().encode(favoritePlaces) {
            UserDefaults.standard.set(encoded, forKey: "favoritePlaces")
        }
    }
    
    private func loadPlaces() {
        if let data = UserDefaults.standard.data(forKey: "favoritePlaces"),
           let decoded = try? JSONDecoder().decode([Place].self, from: data) {
            favoritePlaces = decoded
        } else {
            // Datos por defecto si no hay guardados
            favoritePlaces = [
                Place(
                    name: "Restaurante",
                    subtitle: "Comida tradicional mexicana",
                    latitude: 20.6737,
                    longitude: -103.3444,
                    photos: [],
                    reviews: []
                )
            ]
        }
    }
    
    func updatePlace(_ place: Place) {
        if let index = favoritePlaces.firstIndex(where: { $0.id == place.id }) {
            favoritePlaces[index] = place
            // savePlaces() se llama automáticamente por didSet
        }
    }
}
```

---

## 🎨 Bonus: Animaciones Personalizadas

### Animar la aparición de reseñas:

```swift
struct LocationDetailView: View {
    @State private var animateReviews = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Contenido existente...
                
                ForEach(Array(place.reviews.enumerated()), id: \.element.id) { index, review in
                    ReviewCard(review: review)
                        .opacity(animateReviews ? 1 : 0)
                        .offset(y: animateReviews ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateReviews
                        )
                }
            }
        }
        .onAppear {
            animateReviews = true
        }
    }
}
```

### Animar las estrellas en AddReviewView:

```swift
struct AddReviewView: View {
    @State private var rating: Double = 3.0
    
    var body: some View {
        HStack {
            ForEach(1..<6) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        rating = Double(index)
                    }
                }) {
                    Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                        .font(.title)
                        .foregroundColor(index <= Int(rating) ? .orange : .gray)
                        .scaleEffect(index == Int(rating) ? 1.2 : 1.0)
                }
            }
        }
    }
}
```

---

## 📝 Notas Finales

Estos ejemplos son plantillas que puedes adaptar a tus necesidades. Recuerda:

1. ✅ Siempre probar los cambios en el simulador
2. ✅ Mantener el código limpio y comentado
3. ✅ Validar datos del usuario
4. ✅ Manejar errores apropiadamente
5. ✅ Considerar la experiencia del usuario

**¡Buena suerte con tu desarrollo!** 🚀
